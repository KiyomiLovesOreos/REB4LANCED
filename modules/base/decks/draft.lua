return function(REB4LANCED)
if not REB4LANCED.config.draft_deck then return end

local draft_mode = REB4LANCED.config.draft_mode or 1

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

            -- Fail-safe: explicitly apply config-based effects that other mods'
            -- apply_to_run overrides might skip
            local cfg = deck_center.config or {}
            if cfg.remove_faces        then G.GAME.starting_params.no_faces = true end
            if cfg.randomize_rank_suit then G.GAME.starting_params.erratic_suits_and_ranks = true end
            if cfg.no_interest         then G.GAME.modifiers.no_interest = true end
            if cfg.extra_hand_bonus    then G.GAME.modifiers.money_per_hand = (G.GAME.modifiers.money_per_hand or 0) + cfg.extra_hand_bonus end
            if cfg.extra_discard_bonus then G.GAME.modifiers.money_per_discard = (G.GAME.modifiers.money_per_discard or 0) + cfg.extra_discard_bonus end
            if cfg.spectral_rate       then G.GAME.spectral_rate = (G.GAME.spectral_rate or 0) + cfg.spectral_rate end
            if cfg.ante_scaling        then G.GAME.starting_params.ante_scaling = (G.GAME.starting_params.ante_scaling or 1) * cfg.ante_scaling end
            if cfg.reroll_discount     then G.GAME.starting_params.reroll_cost = math.max(0, (G.GAME.starting_params.reroll_cost or 5) - cfg.reroll_discount) end
            if cfg.boosters_in_shop    then G.GAME.starting_params.boosters_in_shop = (G.GAME.starting_params.boosters_in_shop or 2) + cfg.boosters_in_shop end
            if cfg.scry                then G.GAME.scry_amount = (G.GAME.scry_amount or 0) + cfg.scry end

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
                for _, v in pairs(G.blind_select_opts) do
                    if type(v) == "table" and v.config and v.config.func then
                        local func = G.FUNCS[v.config.func]
                        if func then func(v) end
                    end
                end
            end
            return true
        end
    }))
end

local show_draft_picker

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

local function reb4l_draft_make_card(deck_key, is_locked, is_forced)
    local deck_center = G.P_CENTERS[deck_key]
    if not deck_center then return nil end
    local card = Card(0, 0, G.CARD_W, G.CARD_H, G.P_CARDS.empty, deck_center)
    card.reb4l_draft_deck_key = deck_key
    card.reb4l_draft_locked = is_locked

    if is_locked then
        card.ability.eternal = true
        -- Locked cards: block clicks entirely
        local orig_click = card.click
        card.click = function(self, ...)
            if self.reb4l_draft_locked then return end
            return orig_click(self, ...)
        end
    end

    local _center = deck_center
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
                    config = { align = "cm", r = 0.1, colour = G.C.JOKER_GREY, padding = 0.05, emboss = 0.05 },
                    nodes = { {
                        n = G.UIT.C,
                        config = { align = "cm", r = 0.08, colour = G.C.L_BLACK, padding = 0.08 },
                        nodes = {
                            { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = {
                                { n = G.UIT.T, config = { text = deck_name, colour = G.C.WHITE, scale = 0.45, shadow = true } }
                            }},
                            { n = G.UIT.R, config = { align = "cm", padding = 0.02, colour = G.C.WHITE, r = 0.05 }, nodes = {
                                { n = G.UIT.C, config = { align = "cm", padding = 0.04 }, nodes = desc_ui.nodes or {} }
                            } },
                        }
                    } }
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

    return card
end

show_draft_picker = function()
    local round = G.GAME.modifiers.reb4l_draft_round or 1
    local choices = G.GAME.modifiers.reb4l_draft_choices or {}
    local candidates = G.GAME.modifiers.reb4l_draft_candidates
    local is_mode2 = draft_mode == 2

    local is_forced = (is_mode2 and round == 3)
    local highlight_limit = 1

    G.reb4l_draft_area = CardArea(
        G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
        3 * G.CARD_W * 1.3, 1.05 * G.CARD_H,
        { card_limit = 3, type = 'consumeable', highlight_limit = 1 }
    )

    if is_mode2 then
        -- Mode 2: slot retention
        -- Round 1: candidates 1-3
        -- Round 2: choice[1] stays (locked), candidates 4-5 fill slots 2-3
        -- Round 3: choice[1] stays (locked), choice[2] stays (locked), candidate 6 fills slot 3
        local function get_deck_for_slot(slot)
            if slot == 1 and round >= 2 and choices[1] then
                return choices[1], true  -- locked
            elseif slot == 2 and round == 3 and choices[2] then
                return choices[2], true  -- locked
            end
            local idx
            if round == 1 then
                idx = slot
            elseif round == 2 then
                idx = slot + 2  -- candidates 4, 5 for slots 2, 3
            else -- round 3
                idx = 6  -- candidate 6 for slot 3
            end
            if candidates[idx] then
                return candidates[idx], false
            end
            return nil, false
        end

        for i = 1, 3 do
            local deck_key, locked = get_deck_for_slot(i)
            if deck_key then
                local card = reb4l_draft_make_card(deck_key, locked, is_forced)
                if card then G.reb4l_draft_area:emplace(card) end
            end
        end
    else
        -- Mode 1: original behavior, 3 fresh candidates per round
        local start_idx = (round - 1) * 3 + 1
        for i = 0, 2 do
            local deck_key = candidates[start_idx + i]
            if deck_key then
                local card = reb4l_draft_make_card(deck_key, false, false)
                if card then G.reb4l_draft_area:emplace(card) end
            end
        end
    end

    G.FUNCS.reb4l_draft_can_select = function(e)
        if G.reb4l_draft_area then
            for _, c in ipairs(G.reb4l_draft_area.cards) do
                if c.highlighted and not c.reb4l_draft_locked then
                    local col = is_forced and G.C.GREEN or G.C.RED
                    e.config.colour = col
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
                if c.highlighted and not c.reb4l_draft_locked then
                    selected_key = c.reb4l_draft_deck_key
                    break
                end
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

    local button_text = is_forced and "Accept" or "Select"

    G.OVERLAY_MENU = UIBox({
        definition = create_UIBox_generic_options({
            back_func = nil,
            no_back   = true,
            contents  = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.1 },
                    nodes  = { { n = G.UIT.O, config = { object = DynaText({
                        string   = { "Draft - Round " .. round .. " of 3" },
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
                        nodes = { { n = G.UIT.T, config = { text = button_text, scale = 0.5, colour = G.C.WHITE, shadow = true } } }
                    } }
                },
            }
        }),
        config = { align = "cm", offset = { x = 0, y = 0 }, major = G.ROOM_ATTACH }
    })
    G.OVERLAY_MENU.reb4l_draft = true
    G.reb4l_draft_overlay = G.OVERLAY_MENU
end

-- Save/load support
local reb4l_draft_orig_reset = SMODS.current_mod.reset_game_globals
SMODS.current_mod.reset_game_globals = function(run_start)
    if reb4l_draft_orig_reset then reb4l_draft_orig_reset(run_start) end
    if G.GAME and G.GAME.modifiers and G.GAME.modifiers.reb4l_draft_active
        and not G.GAME.modifiers.reb4l_draft_complete then
        if run_start then
            -- New run: handled by apply()
        else
            -- Save load mid-draft: re-show the picker
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.8,
                func = function()
                    show_draft_picker()
                    return true
                end
            }))
        end
    end
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
        G.GAME.modifiers.reb4l_draft_revealed  = {}

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

                local need = draft_mode == 2 and 6 or 9
                local candidates = {}
                for i = 1, math.min(need, #all_decks) do
                    table.insert(candidates, all_decks[i])
                end

                G.GAME.modifiers.reb4l_draft_candidates = candidates
                -- Blacklist round 1 candidates immediately (mode 2: no duplicates)
                if draft_mode == 2 then
                    G.GAME.modifiers.reb4l_draft_revealed = {}
                    for i = 1, math.min(3, #candidates) do
                        G.GAME.modifiers.reb4l_draft_revealed[candidates[i]] = true
                    end
                end
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
                    -- Don't blank center — let trigger_effect see the real deck key
                    -- so hardcoded checks (Plasma, Ghost, etc.) work correctly
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
