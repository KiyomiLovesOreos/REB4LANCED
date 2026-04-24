return function(REB4LANCED)
if not REB4LANCED.config.draft_deck then return end

-- Deep merge function: adds numbers, recurses tables, overwrites scalars
local function merge(t1, t2)
    local t3 = {}
    for k, v in pairs(t1) do
        t3[k] = type(v) == "table" and merge(v, {}) or v
    end
    for k, v in pairs(t2) do
        local existing = t3[k]
        if type(existing) == "number" and type(v) == "number" then
            t3[k] = k == "ante_scaling" and existing * v or existing + v
        elseif type(existing) == "table" and type(v) == "table" then
            t3[k] = merge(existing, v)
        else
            t3[k] = type(v) == "table" and merge(v, {}) or v
        end
    end
    return t3
end

local function reb4l_draft_apply_selections()
    local back    = G.GAME.selected_back
    local choices = G.GAME.modifiers.reb4l_draft_choices
    G.GAME.reb4l_draft_deck_names = {}

    for i = 1, #choices do
        local deck_key    = choices[i]
        local deck_center = G.P_CENTERS[deck_key]
        if deck_center then
            local display_name = localize({ type = 'name_text', set = 'Back', key = deck_key })
            if not display_name or display_name == deck_key or display_name == "" then
                display_name = deck_center.loc_name or deck_center.name or deck_key
            end
            table.insert(G.GAME.reb4l_draft_deck_names, display_name)

            back.effect.config = merge(back.effect.config, deck_center.config)

            if back.effect.config.voucher then
                back.effect.config.vouchers = back.effect.config.vouchers or {}
                back.effect.config.vouchers[#back.effect.config.vouchers + 1] = back.effect.config.voucher
                back.effect.config.voucher = nil
            end

            local temp_back = Back(deck_center)
            temp_back:apply_to_run()

            local cfg = deck_center.config or {}
            if cfg.hands        then G.GAME.round_resets.hands   = G.GAME.round_resets.hands   + cfg.hands;   G.GAME.current_round.hands_left   = G.GAME.current_round.hands_left   + cfg.hands   end
            if cfg.discards     then G.GAME.round_resets.discards = G.GAME.round_resets.discards + cfg.discards; G.GAME.current_round.discards_left = G.GAME.current_round.discards_left + cfg.discards end
            if cfg.hand_size    then G.hand:change_size(cfg.hand_size) end
            if cfg.dollars      then ease_dollars(cfg.dollars) end
            if cfg.joker_slot   then G.jokers.config.card_limit     = G.jokers.config.card_limit     + cfg.joker_slot end
            if cfg.consumable_slot then G.consumeables.config.card_limit = G.consumeables.config.card_limit + cfg.consumable_slot end
        end
    end

    back.effect.reb4l_drafted = true

    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.7,
        func = function()
            if G.blind_select_opts then
                reb4l_refresh_blind_option('Small')
                reb4l_refresh_blind_option('Big')
                reb4l_refresh_blind_option('Boss')
            end
            return true
        end
    }))
end

local show_draft_picker  -- forward declaration

-- Only show once G.OVERLAY_MENU has been clear for 4 consecutive 0.25s ticks (~1s).
-- If another mod claims the overlay during that window the counter resets,
-- so we always appear after every other run-start overlay has closed.
local function show_draft_picker_when_ready(stable)
    stable = stable or 0
    if G.OVERLAY_MENU and not G.OVERLAY_MENU.reb4l_draft then
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.25,
            func = function() show_draft_picker_when_ready(0); return true end
        }))
        return
    end
    if stable < 4 then
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.25,
            func = function() show_draft_picker_when_ready(stable + 1); return true end
        }))
        return
    end
    show_draft_picker()
end

show_draft_picker = function()
    local round      = G.GAME.modifiers.reb4l_draft_round or 1
    local candidates = G.GAME.modifiers.reb4l_draft_candidates
    local start_idx  = (round - 1) * 3 + 1

    G.reb4l_draft_area = CardArea(
        G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
        3 * G.CARD_W * 1.3, 1.05 * G.CARD_H,
        { card_limit = 3, type = 'consumeable', highlight_limit = 1 }
    )

    for i = 0, 2 do
        local deck_key    = candidates[start_idx + i]
        local deck_center = G.P_CENTERS[deck_key]
        if deck_center then
            local card = Card(
                G.reb4l_draft_area.T.x + G.reb4l_draft_area.T.w / 2,
                G.reb4l_draft_area.T.y,
                G.CARD_W, G.CARD_H,
                G.P_CARDS.empty, deck_center
            )
            card.reb4l_draft_deck_key = deck_key

            local _center   = deck_center
            local _deck_key = deck_key
            card.hover = function(self)
                if self.facing == 'front' and not self.no_ui and not G.debug_tooltip_toggle then
                    local temp_back = Back(_center)
                    local deck_name = localize({ type = 'name_text', set = 'Back', key = _deck_key })
                    if not deck_name or deck_name == "" then deck_name = _center.name or _deck_key end
                    local desc_ui = temp_back:generate_UI(_center)
                    self.config.h_popup = {
                        n = G.UIT.ROOT,
                        config = { align = "cm", colour = G.C.CLEAR, padding = 0.1 },
                        nodes = { {
                            n = G.UIT.C,
                            config = { align = "cm", colour = darken(G.C.JOKER_GREY, 0.2), r = 0.1, padding = 0.1, emboss = 0.05 },
                            nodes = {
                                { n = G.UIT.R, config = { align = "cm", padding = 0.03 }, nodes = {
                                    { n = G.UIT.T, config = { text = deck_name, colour = G.C.WHITE, scale = 0.45, shadow = true } }
                                }},
                                { n = G.UIT.R, config = { align = "cm", padding = 0 }, nodes = desc_ui.nodes }
                            }
                        } }
                    }
                    self.config.h_popup_config = self:align_h_popup()
                    self:juice_up(0.05, 0.03)
                    play_sound('paper1', math.random() * 0.2 + 0.9, 0.35)
                    Node.hover(self)
                else
                    self:juice_up(0.05, 0.03)
                    play_sound('paper1', math.random() * 0.2 + 0.9, 0.35)
                    Node.hover(self)
                end
            end

            G.reb4l_draft_area:emplace(card)
        end
    end

    G.FUNCS.reb4l_draft_can_select = function(e)
        if G.reb4l_draft_area then
            for _, c in ipairs(G.reb4l_draft_area.cards) do
                if c.highlighted then
                    e.config.colour = G.C.RED
                    e.config.button = 'reb4l_draft_select'
                    return true
                end
            end
        end
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
        return true
    end

    G.FUNCS.reb4l_draft_select = function()
        local selected_key = nil
        if G.reb4l_draft_area then
            for _, c in ipairs(G.reb4l_draft_area.cards) do
                if c.highlighted then selected_key = c.reb4l_draft_deck_key; break end
            end
        end
        if not selected_key then return end

        G.GAME.modifiers.reb4l_draft_choices = G.GAME.modifiers.reb4l_draft_choices or {}
        table.insert(G.GAME.modifiers.reb4l_draft_choices, selected_key)

        if G.reb4l_draft_area and G.reb4l_draft_area.cards then
            for j = #G.reb4l_draft_area.cards, 1, -1 do
                local c = G.reb4l_draft_area:remove_card(G.reb4l_draft_area.cards[j])
                if c then c:remove() end
            end
        end

        if G.reb4l_draft_overlay then
            G.reb4l_draft_overlay:remove()
            G.reb4l_draft_overlay = nil
        end
        if G.OVERLAY_MENU and G.OVERLAY_MENU.reb4l_draft then G.OVERLAY_MENU = nil end
        G.reb4l_draft_area = nil

        local current_round = G.GAME.modifiers.reb4l_draft_round or 1
        if current_round < 3 then
            G.GAME.modifiers.reb4l_draft_round = current_round + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.1,
                func = function() show_draft_picker(); return true end
            }))
        else
            G.GAME.modifiers.reb4l_draft_complete = true
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.1,
                func = function() reb4l_draft_apply_selections(); return true end
            }))
        end
    end

    G.OVERLAY_MENU = UIBox({
        definition = create_UIBox_generic_options({
            back_func = nil,
            no_back   = true,
            contents  = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.1 },
                    nodes  = { { n = G.UIT.O, config = { object = DynaText({
                        string   = { "Draft - Round " .. (G.GAME.modifiers.reb4l_draft_round or 1) .. " of 3" },
                        colours  = { G.C.WHITE },
                        shadow   = true,
                        bump     = true,
                        scale    = 0.6,
                        pop_in   = 0.5,
                    }) } } }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05, padding = 0.15 },
                    nodes  = { { n = G.UIT.O, config = { object = G.reb4l_draft_area } } }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.1 },
                    nodes  = { {
                        n = G.UIT.C,
                        config = {
                            align  = "cm", minw = 3, minh = 0.6, padding = 0.15,
                            r = 0.1, hover = true, shadow = true,
                            colour = G.C.UI.BACKGROUND_INACTIVE,
                            button = 'reb4l_draft_select',
                            func   = 'reb4l_draft_can_select',
                        },
                        nodes = { { n = G.UIT.T, config = { text = "Select", scale = 0.5, colour = G.C.WHITE, shadow = true } } }
                    } }
                },
            }
        }),
        config = { align = "cm", offset = { x = 0, y = 0 }, major = G.ROOM_ATTACH }
    })
    G.OVERLAY_MENU.reb4l_draft = true
    G.reb4l_draft_overlay = G.OVERLAY_MENU
end

SMODS.Back({
    key = "draft",
    loc_txt = {
        name = "Draft Deck",
        text = {
            "At run start, {C:attention}draft{} 3 decks",
            "from 3 sets of 3 random options",
            "Gain {C:green}all benefits{} AND {C:red}all drawbacks{}",
            "{C:inactive}Drafted:{}",
            "{C:attention}#1#{}",
            "{C:attention}#2#{}",
            "{C:attention}#3#{}",
        }
    },
    pos    = { x = 6, y = 0 },
    atlas  = "decks",
    config = {},
    apply = function(self, back)
        back = back or G.GAME.selected_back
        G.GAME.modifiers = G.GAME.modifiers or {}
        G.GAME.modifiers.reb4l_draft_active    = true
        G.GAME.modifiers.reb4l_draft_choices   = {}
        G.GAME.modifiers.reb4l_draft_round     = 1
        G.GAME.modifiers.reb4l_draft_complete  = false

        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.5,
            func = function()
                local all_decks = {}
                for k, v in pairs(G.P_CENTERS) do
                    if v.set == "Back" and k ~= "b_reb4l_draft" and k ~= "b_challenge" and k ~= "b_mp_cocktail" and not v.omit then
                        table.insert(all_decks, k)
                    end
                end
                table.sort(all_decks)

                for i = #all_decks, 2, -1 do
                    local j = math.floor(pseudorandom('reb4l_draft_shuffle_' .. i) * i) + 1
                    all_decks[i], all_decks[j] = all_decks[j], all_decks[i]
                end

                local candidates = {}
                for i = 1, math.min(9, #all_decks) do
                    table.insert(candidates, all_decks[i])
                end

                G.GAME.modifiers.reb4l_draft_candidates = candidates
                show_draft_picker_when_ready()
                return true
            end
        }))
    end,
    calculate = function(self, back, context)
        if G.GAME and G.GAME.modifiers.reb4l_draft_choices then
            for i = 1, #G.GAME.modifiers.reb4l_draft_choices do
                local deck_key    = G.GAME.modifiers.reb4l_draft_choices[i]
                local deck_center = G.P_CENTERS[deck_key]
                if deck_center then
                    back:change_to(deck_center)
                    -- Blank center so trigger_effect skips obj.calculate and falls
                    -- through to vanilla self.name checks (e.g. Plasma Deck balance).
                    back.effect.center = {}
                    local ret1, ret2 = back:trigger_effect(context)
                    back:change_to(G.P_CENTERS["b_reb4l_draft"])
                    if ret1 or ret2 then return ret1, ret2 end
                end
            end
        end
    end,
    loc_vars = function(self, info_queue, card)
        if G.GAME and G.GAME.reb4l_draft_deck_names and #G.GAME.reb4l_draft_deck_names > 0 then
            return { vars = {
                G.GAME.reb4l_draft_deck_names[1] or "???",
                G.GAME.reb4l_draft_deck_names[2] or "???",
                G.GAME.reb4l_draft_deck_names[3] or "???",
            } }
        end
        return { vars = { "Drafting...", "", "" } }
    end,
})

-- Preserve merged config across change_to calls
local reb4l_draft_change_to_ref = Back.change_to
function Back:change_to(new_back)
    if self.effect and self.effect.reb4l_drafted then
        local t   = copy_table(self.effect.config)
        local ret = reb4l_draft_change_to_ref(self, new_back)
        self.effect.config       = copy_table(t)
        self.effect.reb4l_drafted = true
        return ret
    end
    return reb4l_draft_change_to_ref(self, new_back)
end

end
