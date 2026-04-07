-- Card:is_suit override
-- Wild Cards resist suit-based debuffs (can never be suit-debuffed).
-- When a suit-debuff blind is active, Wild Cards count as all suits EXCEPT the debuffed suit.
-- Same suit-debuff resistance applies to all cards when Smeared Joker is in play.
function Card:is_suit(suit, bypass_debuff, flush_calc, trying_to_debuff)
    if not flush_calc and self.debuff and not bypass_debuff then
        return nil
    end
    if self.ability.effect == 'Stone Card' then
        return false
    end
    -- Wild Cards resist suit-based debuffs; count as all suits except the active debuffed suit
    if self.ability.name == "Wild Card" then
        if trying_to_debuff then return false end
        local debuffed_suit = G.GAME and G.GAME.blind and G.GAME.blind.debuff and G.GAME.blind.debuff.suit
        if debuffed_suit and suit == debuffed_suit then return false end
        return not flush_calc or not self.debuff
    end
    -- Smeared Joker cards also resist suit-based debuffs
    if REB4LANCED.config.smeared_enhanced then
        local has_smeared = next(find_joker('Smeared Joker'))
        if has_smeared then
            if trying_to_debuff then return false end
            local is_base_red = self.base.suit == 'Hearts' or self.base.suit == 'Diamonds'
            local is_target_red = suit == 'Hearts' or suit == 'Diamonds'
            if is_base_red == is_target_red then return true end
        end
    end
    return self.base.suit == suit
end

-- Blind:debuff_card override
-- Passes trying_to_debuff = true when checking suit debuffs so Wild Cards
-- (and Smeared Joker cards) resist only suit-based debuffs via is_suit.
function Blind:debuff_card(card, from_blind)
    if self.debuff and not self.disabled and card.area ~= G.jokers then
        if self.debuff.suit and card:is_suit(self.debuff.suit, true, nil, true) then
            card:set_debuff(true); return
        end
        if self.debuff.is_face == 'face' and card:is_face(true) then
            card:set_debuff(true); return
        end
        if self.name == 'The Pillar' and card.ability.played_this_ante then
            card:set_debuff(true); return
        end
        if self.debuff.value and self.debuff.value == card.base.value then
            card:set_debuff(true); return
        end
        if self.debuff.nominal and self.debuff.nominal == card.base.nominal then
            card:set_debuff(true); return
        end
    end
    if self.name == 'Crimson Heart' and not self.disabled and card.area == G.jokers then return end
    if self.name == 'Verdant Leaf' and not self.disabled and card.area ~= G.jokers then
        card:set_debuff(true); return
    end
    card:set_debuff(false)
end


-- Edition Tags (enhanced): apply edition to a joker at purchase time
-- Checks next(self.edition) to treat both nil and empty-table as "no edition".
local reb4l_orig_buy_card = Card.buy_card
function Card:buy_card(from_area)
    -- Capture the card's current area BEFORE vanilla moves it out of the shop.
    -- (vanilla calls buy_card with no arguments, so from_area is always nil)
    local was_shop_joker = self.area == G.shop_jokers
    local result = reb4l_orig_buy_card(self, from_area)
    if REB4LANCED.config.edition_tags_enhanced
    and self.ability and self.ability.set == 'Joker'
    and (not self.edition or not next(self.edition))
    and was_shop_joker
    and G.GAME and G.GAME.tags then
        local edition_map = {
            tag_negative   = 'e_negative',   negative   = 'e_negative',
            tag_foil       = 'e_foil',       foil       = 'e_foil',
            tag_holo       = 'e_holo',       holo       = 'e_holo',
            tag_polychrome = 'e_polychrome', polychrome = 'e_polychrome',
        }
        for i = 1, #G.GAME.tags do
            local tag = G.GAME.tags[i]
            if tag and not tag.triggered and edition_map[tag.key] then
                local edition_key = edition_map[tag.key]
                local joker_card = self
                local lock = tag.ID
                G.CONTROLLER.locks[lock] = true
                tag:yep('+', G.C.EDITION, function()
                    joker_card:set_edition(edition_key, true)
                    G.CONTROLLER.locks[lock] = nil
                    return true
                end)
                tag.triggered = true
                break
            end
        end
    end
    return result
end

-- Gold Stake: showdown boss blinds every N antes (controlled by showdown_interval modifier)
-- get_new_boss uses G.GAME.win_ante to determine showdown frequency; we temporarily
-- swap it with showdown_interval so win_ante (run length) stays unaffected.
local reb4l_orig_get_new_boss = get_new_boss
function get_new_boss()
    if not (G.GAME and G.GAME.modifiers and G.GAME.modifiers.showdown_interval) then
        return reb4l_orig_get_new_boss()
    end
    local real_win_ante = G.GAME.win_ante
    G.GAME.win_ante = G.GAME.modifiers.showdown_interval
    local result = reb4l_orig_get_new_boss()
    G.GAME.win_ante = real_win_ante
    return result
end

-- Interest on skip
if REB4LANCED.config.interest_on_skip then
    local reb4l_orig_skip_blind = G.FUNCS.skip_blind
    G.FUNCS.skip_blind = function(e)
        local interest_base = G.GAME.interest_base or 5
        local interest_amount = G.GAME.interest_amount or 1
        local interest_cap = G.GAME.interest_cap or 25
        local dollars = type(G.GAME.dollars) == "number" and G.GAME.dollars or 0
        if dollars >= 1 and not G.GAME.modifiers.no_interest then
            local earned = interest_amount * math.min(math.floor(dollars / interest_base), math.floor(interest_cap / interest_base))
            if earned >= 1 then ease_dollars(earned) end
        end
        return reb4l_orig_skip_blind(e)
    end
end


-- Chicot (modes 2 & 3) and Matador (when matador_enhanced): vanilla card.lua has
-- hardcoded ability.name checks in Card:calculate_joker that bypass take_ownership.
-- Chicot (~2898): fires at setting_blind → disables boss blind.
-- Matador (~debuffed_hand): fires at debuffed_hand → double payout + error.
-- Card:add_to_deck (~783) also has a Chicot check for buying mid-boss-blind.
-- Block all by temporarily masking ability.name so the hardcoded checks fail.
-- SMODS routes calculate_joker via center key, not ability.name, so our
-- take_ownership calculate still fires correctly.
if REB4LANCED.config.chicot_mode ~= 1 then
    local reb4l_orig_add_to_deck = Card.add_to_deck
    function Card:add_to_deck(from_debuff)
        local is_chicot = self.ability and self.ability.name == 'Chicot'
            and G.GAME and G.GAME.blind and G.GAME.blind.boss
        if is_chicot then self.ability.name = 'reb4l_chicot' end
        reb4l_orig_add_to_deck(self, from_debuff)
        if is_chicot then self.ability.name = 'Chicot' end
    end
end

do
    local reb4l_orig_calculate_joker = Card.calculate_joker
    function Card:calculate_joker(context)
        local mask, restore
        if self.ability then
            if self.ability.name == 'Chicot' and REB4LANCED.config.chicot_mode ~= 1
                and context and context.setting_blind then
                mask, restore = 'reb4l_chicot', 'Chicot'
            elseif self.ability.name == 'Matador' and REB4LANCED.config.matador_enhanced
                and context and context.debuffed_hand then
                mask, restore = 'reb4l_matador', 'Matador'
            elseif self.ability.name == 'Bootstraps' and REB4LANCED.config.bootstraps_enhanced then
                mask, restore = 'reb4l_bootstraps', 'Bootstraps'
            elseif self.ability.name == 'Yorick' and REB4LANCED.config.yorick_enhanced then
                mask, restore = 'reb4l_yorick', 'Yorick'
            end
        end
        if mask then self.ability.name = mask end
        local result = reb4l_orig_calculate_joker(self, context)
        if restore then self.ability.name = restore end
        return result
    end
end

-- Chicot Echo Tags (mode 3): intercept add_tag to record tags gained from blind skips
if REB4LANCED.config.chicot_mode == 3 then
    local reb4l_orig_add_tag = add_tag
    function add_tag(tag, ...)
        if G.GAME and G.GAME.reb4l_tracking_skip then
            G.GAME.reb4l_skip_tags = G.GAME.reb4l_skip_tags or {}
            G.GAME.reb4l_skip_tags[#G.GAME.reb4l_skip_tags + 1] = tag.key
        end
        return reb4l_orig_add_tag(tag, ...)
    end
    -- Wrap skip_blind to set tracking flag (wraps the interest override if present)
    local reb4l_chicot_orig_skip = G.FUNCS.skip_blind
    G.FUNCS.skip_blind = function(e)
        if G.GAME then G.GAME.reb4l_tracking_skip = true end
        local result = reb4l_chicot_orig_skip(e)
        if G.GAME then G.GAME.reb4l_tracking_skip = false end
        return result
    end
end

-- ── Fork Tag Vouchers (Branching-style blind tag picker) ─────────────────────
-- T1 (v_reb4l_split_tag): current Small/Big blind shows 3 tag choices; skip grants 1.
-- T2 (v_reb4l_fork_tag): same 3 tag choices, but skip grants 2 selected tags.
if REB4LANCED.config.fork_tag_vouchers then

    local function reb4l_blind_choice_is_current(blind_choice)
        return G.GAME
            and G.GAME.blind_on_deck == blind_choice
            and G.GAME.round_resets
            and G.GAME.round_resets.blind_states
            and G.GAME.round_resets.blind_states[blind_choice] == 'Select'
    end

    local function reb4l_get_fork_pick_count()
        if not (G.GAME and G.GAME.used_vouchers) then return 0 end
        if G.GAME.used_vouchers['v_reb4l_fork_tag'] then return 0 end
        if G.GAME.used_vouchers['v_reb4l_split_tag'] then return 1 end
        return 0
    end

    local function reb4l_t1_active()
        return reb4l_get_fork_pick_count() == 1
    end

    local function reb4l_t2_active()
        return G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers['v_reb4l_fork_tag']
    end

    local function reb4l_is_fork_tag_list(ref_table)
        return type(ref_table) == 'table'
            and type(ref_table[1]) == 'table'
            and (ref_table[1].get_uibox_table or ref_table[1].key)
    end

    local function reb4l_clear_fork_selection(blind_choice)
        if not (G.GAME and G.GAME.round_resets and G.GAME.round_resets.reb4l_blind_tag_choices) then
            if G.GAME then G.GAME.reb4l_fork_selected_index = nil end
            return
        end
        G.GAME.reb4l_fork_selected_index = nil
        if blind_choice then
            local state = G.GAME.round_resets.reb4l_blind_tag_choices[blind_choice]
            if state then state.selected = {} end
            return
        end
        for k, state in pairs(G.GAME.round_resets.reb4l_blind_tag_choices) do
            if k ~= '_ante' and type(state) == 'table' then
                state.selected = {}
            end
        end
    end

    local function reb4l_clear_fork_popups(blind_choice)
        if not (blind_choice and G.blind_select_opts and G.blind_select_opts[string.lower(blind_choice)]) then
            return
        end
        local ui_box = G.blind_select_opts[string.lower(blind_choice)]
        if not ui_box or not ui_box.get_UIE_by_ID then return end

        local tag_row = ui_box:get_UIE_by_ID('tag_' .. blind_choice)
        if tag_row and tag_row.alert then
            tag_row.alert:remove()
            tag_row.alert = nil
        end
        if tag_row and tag_row.children then
            if tag_row.children[2] and tag_row.children[2].alert then
                tag_row.children[2].alert:remove()
                tag_row.children[2].alert = nil
            end
            if tag_row.children[1] and tag_row.children[1].children then
                for i = 1, #tag_row.children[1].children do
                    local child = tag_row.children[1].children[i]
                    if child and child.alert then
                        child.alert:remove()
                        child.alert = nil
                    end
                end
            end
        end
    end

    -- Cache the 3 tag options per blind in round_resets so they survive save/load.
    local function reb4l_get_blind_tag_choice_state(blind_choice)
        local r = G.GAME.round_resets
        r.reb4l_blind_tag_choices = r.reb4l_blind_tag_choices or {}
        if r.reb4l_blind_tag_choices._ante ~= r.ante then
            r.reb4l_blind_tag_choices = { _ante = r.ante }
        end
        local state = r.reb4l_blind_tag_choices[blind_choice]
        if not state or not state.keys or #state.keys < 3 then
            local tag1_key = r.blind_tags and r.blind_tags[blind_choice]
            if not tag1_key then return nil end

            local keys = { tag1_key }
            local seen = { [tag1_key] = true }
            local guard = 0
            while #keys < 3 and guard < 50 do
                local tag_key = get_next_tag_key()
                if tag_key and not seen[tag_key] then
                    keys[#keys + 1] = tag_key
                    seen[tag_key] = true
                end
                guard = guard + 1
            end
            while #keys < 3 do
                keys[#keys + 1] = tag1_key
                guard = guard + 1
            end
            if pseudoshuffle and pseudoseed then
                pseudoshuffle(keys, pseudoseed('reb4l_split_tag_' .. blind_choice .. '_' .. tostring(r.ante)))
            end
            state = { keys = keys, selected = {} }
            r.reb4l_blind_tag_choices[blind_choice] = state
        end
        return state
    end

    local function reb4l_normalize_tag_selection(state, pick_count)
        state.selected = state.selected or {}
        local selected, seen = {}, {}
        for _, idx in ipairs(state.selected) do
            if state.keys[idx] and not seen[idx] then
                selected[#selected + 1] = idx
                seen[idx] = true
            end
        end
        while #selected > pick_count do
            table.remove(selected, #selected)
        end
        table.sort(selected)
        state.selected = selected
    end

    local function reb4l_sync_primary_blind_tag(blind_choice, pick_count)
        local state = reb4l_get_blind_tag_choice_state(blind_choice)
        if not state then return nil end
        reb4l_normalize_tag_selection(state, pick_count)
        if state.selected[1] and state.keys[state.selected[1]] and G.GAME.round_resets.blind_tags then
            G.GAME.round_resets.blind_tags[blind_choice] = state.keys[state.selected[1]]
        end
        local selected_keys = {}
        for _, idx in ipairs(state.selected) do
            selected_keys[#selected_keys + 1] = state.keys[idx]
        end
        return selected_keys, state
    end

    local function reb4l_set_selected_tag(blind_choice, index, pick_count)
        local state = reb4l_get_blind_tag_choice_state(blind_choice)
        if not (state and state.keys[index]) then return end
        reb4l_normalize_tag_selection(state, pick_count)

        if pick_count == 1 then
            if state.selected[1] == index then
                state.selected = {}
                if G.GAME then G.GAME.reb4l_fork_selected_index = nil end
            else
                state.selected = { index }
                if G.GAME then G.GAME.reb4l_fork_selected_index = index end
            end
        else
            local already_selected = false
            for _, idx in ipairs(state.selected) do
                if idx == index then
                    already_selected = true
                    break
                end
            end
            if not already_selected then
                state.selected[#state.selected + 1] = index
                while #state.selected > pick_count do
                    table.remove(state.selected, 1)
                end
                table.sort(state.selected)
            end
        end
        reb4l_sync_primary_blind_tag(blind_choice, pick_count)
    end

    G.FUNCS.reb4l_hover_fork_tag = function(e)
        if not e or not e.parent or not e.parent.states then return end
        if e.states.hover.is and (e.created_on_pause == G.SETTINGS.paused) and not e.alert then
            local tag = e.config.ref_table[2]
            local sprite = tag:get_uibox_table()
            e.alert = UIBox{
                definition = G.UIDEF.card_h_popup(sprite),
                config = {
                    align = "tm",
                    offset = { x = 0, y = -0.1 },
                    major = e,
                    instance_type = 'POPUP',
                },
            }
            sprite:juice_up(0.05, 0.02)
            play_sound('paper1', math.random()*0.1 + 0.55, 0.42)
            play_sound('tarot2', math.random()*0.1 + 0.55, 0.09)
            e.alert.states.collide.can = false
        elseif e.alert and (not e.states.hover.is or e.created_on_pause ~= G.SETTINGS.paused) then
            e.alert:remove()
            e.alert = nil
        end
    end

    G.FUNCS.reb4l_select_fork_tag = function(e)
        if not (e and e.config and e.config.ref_table) then return end
        local index = e.config.ref_table[1]
        local tag = e.config.ref_table[2]
        local blind_choice = e.config.ref_table[3]
        local pick_count = e.config.ref_table[4] or 1
        local other_tags = e.parent and e.parent.parent and e.parent.parent.config and e.parent.parent.config.ref_table
        reb4l_set_selected_tag(blind_choice, index, pick_count)
        local _, state = reb4l_sync_primary_blind_tag(blind_choice, pick_count)

        if other_tags then
            local has_selection = state and state.selected and state.selected[1]
            for i = 1, #other_tags do
                if other_tags[i] and other_tags[i].T then
                    other_tags[i].T.scale = (not has_selection or i == state.selected[1]) and 1 or 0.7
                end
            end
        end
        if tag then
            tag:juice_up()
        end
    end

    local function reb4l_make_branching_tag_ui(blind_choice, pick_count)
        local state = reb4l_get_blind_tag_choice_state(blind_choice)
        if not state then return nil end
        reb4l_normalize_tag_selection(state, pick_count)
        reb4l_sync_primary_blind_tag(blind_choice, pick_count)
        local primary_tag = nil

        local tag_nodes = {}
        local tag_sprites = {}
        local tag_info = {}
        for i, tag_key in ipairs(state.keys) do
            local tag = Tag(tag_key, nil, blind_choice)
            local tag_ui, tag_sprite = tag:generate_UI()
            if tag_ui and tag_ui.nodes and tag_ui.nodes[1] and tag_ui.nodes[1].config then
                if tag_ui.nodes[1].config.w then
                    tag_ui.nodes[1].config.w = tag_ui.nodes[1].config.w * 1.15
                end
                if tag_ui.nodes[1].config.h then
                    tag_ui.nodes[1].config.h = tag_ui.nodes[1].config.h * 1.15
                end
            end
            tag_sprite.states.collide.can = false
            tag_ui.T = tag_ui.T or {}
            tag_info[#tag_info + 1] = tag
            tag_sprites[#tag_sprites + 1] = tag_sprite

            local selected = false
            for _, idx in ipairs(state.selected) do
                if idx == i then
                    selected = true
                    break
                end
            end
            if selected and not primary_tag then
                primary_tag = tag
            end
            tag_ui.T.scale = (#state.selected == 0 or selected) and 1 or 0.7

            tag_nodes[#tag_nodes + 1] = {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.03,
                    hover = true,
                    button = 'reb4l_select_fork_tag',
                    func = 'reb4l_hover_fork_tag',
                    ref_table = { i, tag, blind_choice, pick_count },
                },
                nodes = { tag_ui },
            }
        end
        primary_tag = primary_tag or tag_info[1]

        return {n=G.UIT.R, config={id='tag_container', ref_table=primary_tag, align="cm"}, nodes={
            {n=G.UIT.R, config={
                id='tag_'..blind_choice,
                align="cm",
                r=0.1,
                padding=0.1,
                minw=1,
                can_collide=true,
                ref_table=tag_sprites,
            }, nodes={
                {n=G.UIT.R, config={align="cm", r=0.1, maxw=1}, nodes=tag_nodes},
                {n=G.UIT.R, config={
                    align="cm",
                    colour=G.C.UI.BACKGROUND_INACTIVE,
                    minh=0.8,
                    minw=2,
                    maxw=2,
                    padding=0.07,
                    r=0.1,
                    shadow=true,
                    hover=true,
                    one_press=true,
                    button='skip_blind',
                    func='hover_tag_proxy',
                    ref_table=tag_info,
                }, nodes={
                    {n=G.UIT.T, config={text=localize('b_skip_blind'), scale=0.4, colour=G.C.UI.TEXT_INACTIVE}},
                }},
            }},
            {n=G.UIT.R, config={align="cm", colour=G.C.BLACK, minh=0.001, minw=0.001}, nodes={
                {n=G.UIT.B, config={w=0.001, h=0.001}, nodes={}},
            }},
        }}
    end

    function reb4l_refresh_blind_option(blind_choice)
        if not (blind_choice and G.blind_select_opts and G.blind_select_opts[string.lower(blind_choice)]) then
            return
        end
        local key = string.lower(blind_choice)
        local current_box = G.blind_select_opts[key]
        local parent = current_box and current_box.parent
        if not parent then return end

        current_box:remove()
        G.blind_select_opts[key] = UIBox{
            T = {parent.T.x, 0, 0, 0},
            definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
                UIBox_dyn_container(
                    {create_UIBox_blind_choice(blind_choice, G.SETTINGS.paused)},
                    false,
                    get_blind_main_colour(blind_choice),
                    mix_colours(G.C.BLACK, get_blind_main_colour(blind_choice), 0.8)
                )
            }},
            config = {
                align = "bmi",
                offset = {x = 0, y = G.ROOM.T.y + 9},
                major = parent,
                xy_bond = 'Weak',
            }
        }
        parent.config.object = G.blind_select_opts[key]
        parent.config.object:recalculate()
        G.blind_select_opts[key].parent = parent
        G.blind_select_opts[key].alignment.offset.y = 0
    end

    local function reb4l_refresh_skip_ui(skipped, skip_to)
        if not G.E_MANAGER then return end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            blocking = false,
            func = function()
                reb4l_clear_fork_popups(skipped)
                if skip_to and skip_to ~= skipped then
                    reb4l_clear_fork_popups(skip_to)
                end
                reb4l_refresh_blind_option(skipped)
                if skip_to and skip_to ~= skipped then
                    reb4l_refresh_blind_option(skip_to)
                end
                return true
            end,
        }))
    end

    -- Wrap create_UIBox_blind_tag so the current blind uses a Branching-style picker.
    local reb4l_orig_create_blind_tag = create_UIBox_blind_tag
    function create_UIBox_blind_tag(blind_choice, run_info)
        local result = reb4l_orig_create_blind_tag(blind_choice, run_info)
        if not result or run_info then return result end
        if not (G.GAME and G.GAME.used_vouchers and reb4l_blind_choice_is_current(blind_choice)) then
            return result
        end

        local pick_count = reb4l_get_fork_pick_count()
        if pick_count == 0 then
            return result
        end

        return reb4l_make_branching_tag_ui(blind_choice, pick_count) or result
    end

    local reb4l_orig_hover_tag_proxy = G.FUNCS.hover_tag_proxy
    G.FUNCS.hover_tag_proxy = function(e)
        local pick_count = reb4l_get_fork_pick_count()
        local current_blind = G.GAME and G.GAME.blind_on_deck
        local parent_id = e and e.parent and e.parent.config and e.parent.config.id
        local parent_blind = type(parent_id) == 'string' and string.match(parent_id, '^tag_(.+)$')
        local is_fork_skip_hover = pick_count > 0
            and e and e.config
            and reb4l_is_fork_tag_list(e.config.ref_table)
            and parent_blind

        if not is_fork_skip_hover then
            return reb4l_orig_hover_tag_proxy(e)
        end

        local selected_index = G.GAME and G.GAME.reb4l_fork_selected_index
        local selected_tag = selected_index and e.config.ref_table[selected_index]
        if selected_tag and not selected_tag.get_uibox_table then
            selected_tag = nil
        end

        if e.states and e.states.hover and e.states.hover.is
            and (e.created_on_pause == G.SETTINGS.paused)
            and not e.alert and selected_tag then
            local sprite = selected_tag:get_uibox_table()
            e.alert = UIBox{
                definition = G.UIDEF.card_h_popup(sprite),
                config = {
                    align = "tm",
                    offset = { x = 0, y = -0.1 },
                    major = e.parent,
                    instance_type = 'POPUP',
                },
            }
            sprite:juice_up(0.05, 0.02)
            play_sound('paper1', math.random()*0.1 + 0.55, 0.42)
            play_sound('tarot2', math.random()*0.1 + 0.55, 0.09)
            e.alert.states.collide.can = false
        elseif e.alert and ((not e.states or not e.states.collide or not e.states.collide.is)
            or e.created_on_pause ~= G.SETTINGS.paused) then
            e.alert:remove()
            e.alert = nil
        end

        if selected_tag and parent_blind == current_blind then
            e.config.button = 'skip_blind'
            e.config.hover = true
            e.config.colour = G.C.RED
            if e.children and e.children[1] and e.children[1].config then
                e.children[1].config.colour = G.C.UI.TEXT_LIGHT
            end
        else
            e.config.button = nil
            e.config.hover = false
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            if e.children and e.children[1] and e.children[1].config then
                e.children[1].config.colour = G.C.UI.TEXT_INACTIVE
            end
        end
    end

    local reb4l_orig_toggle_shop = G.FUNCS.toggle_shop
    G.FUNCS.toggle_shop = function(e)
        local result = reb4l_orig_toggle_shop(e)
        reb4l_clear_fork_selection()
        return result
    end

    local reb4l_orig_cash_out_fork = G.FUNCS.cash_out
    G.FUNCS.cash_out = function(e)
        local result = reb4l_orig_cash_out_fork(e)
        reb4l_clear_fork_selection()
        return result
    end

    local reb4l_orig_blind_choice_handler = G.FUNCS.blind_choice_handler
    G.FUNCS.blind_choice_handler = function(e)
        local pick_count = reb4l_get_fork_pick_count()
        if pick_count == 0 or not (e and e.config and e.config.id and G.GAME and G.blind_select_opts) then
            return reb4l_orig_blind_choice_handler(e)
        end

        if not (e.config.id == 'Small' or e.config.id == 'Big') then
            return reb4l_orig_blind_choice_handler(e)
        end

        if not e.config.ref_table.run_info and G.blind_select and G.blind_select.VT.y < 10
            and G.blind_select_opts[string.lower(e.config.id)] then
            if e.UIBox.role.xy_bond ~= 'Weak' then
                e.UIBox:set_role({ xy_bond = 'Weak' })
            end

            if (e.config.ref_table.deck ~= 'on' and e.config.id == G.GAME.blind_on_deck)
                or (e.config.ref_table.deck ~= 'off' and e.config.id ~= G.GAME.blind_on_deck) then
                local blind_choice = G.blind_select_opts[string.lower(e.config.id)]
                local top_button = e.UIBox:get_UIE_by_ID('select_blind_button')
                local border = e.UIBox.UIRoot and e.UIBox.UIRoot.children
                    and e.UIBox.UIRoot.children[1] and e.UIBox.UIRoot.children[1].children
                    and e.UIBox.UIRoot.children[1].children[1]
                local tag_row = e.UIBox:get_UIE_by_ID('tag_' .. e.config.id)
                local tag_container = e.UIBox:get_UIE_by_ID('tag_container')

                if tag_container and not G.SETTINGS.tutorial_complete
                    and not G.SETTINGS.tutorial_progress.completed_parts['shop_1'] then
                    tag_container.states.visible = false
                elseif tag_container then
                    tag_container.states.visible = true
                end

                if e.config.id == G.GAME.blind_on_deck then
                    e.config.ref_table.deck = 'on'
                    e.config.draw_after = false
                    e.config.colour = G.C.CLEAR
                    if border and border.parent and border.parent.config then
                        border.parent.config.outline = 2
                        border.parent.config.outline_colour = G.C.UI.TRANSPARENT_DARK
                    end
                    if border and border.config then
                        border.config.outline_colour = border.config.outline and border.config.outline_colour
                            or get_blind_main_colour(e.config.id)
                        border.config.outline = 1.5
                    end
                    if blind_choice and blind_choice.alignment and blind_choice.alignment.offset then
                        blind_choice.alignment.offset.y = -0.9
                    end
                    if tag_row and tag_container then
                        if tag_container.children and tag_container.children[2] and tag_container.children[2].config then
                            tag_container.children[2].config.draw_after = false
                            tag_container.children[2].config.colour = G.C.BLACK
                        end
                        tag_row.config.outline_colour = adjust_alpha(G.C.BLUE, 0.5)
                        if tag_row.children and tag_row.children[2] and tag_row.children[2].config then
                            tag_row.children[2].config.button = nil
                            tag_row.children[2].config.hover = false
                            tag_row.children[2].config.colour = G.C.UI.BACKGROUND_INACTIVE
                            if tag_row.children[2].children and tag_row.children[2].children[1]
                                and tag_row.children[2].children[1].config then
                                tag_row.children[2].children[1].config.colour = G.C.UI.TEXT_INACTIVE
                            end
                        end
                        if tag_row.children and tag_row.children[1] and tag_row.children[1].children then
                            for i = 1, #tag_row.children[1].children do
                                local node = tag_row.children[1].children[i]
                                local sprite = tag_row.config.ref_table and tag_row.config.ref_table[i]
                                if sprite and sprite.config then
                                    sprite.config.force_focus = nil
                                end
                                if node and node.config then
                                    node.config.button = 'reb4l_select_fork_tag'
                                end
                            end
                        end
                    end
                    if top_button then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.CONTROLLER:snap_to({ node = top_button })
                                return true
                            end,
                        }))
                        if top_button.config.button ~= "mp_toggle_ready" then
                            top_button.config.button = "select_blind"
                        end
                        top_button.config.colour = G.C.FILTER
                        top_button.config.hover = true
                        if top_button.children and top_button.children[1] and top_button.children[1].config then
                            top_button.children[1].config.colour = G.C.WHITE
                        end
                    end
                else
                    e.config.ref_table.deck = 'off'
                    e.config.draw_after = true
                    e.config.colour = adjust_alpha(
                        G.GAME.round_resets.blind_states[e.config.id] == 'Skipped'
                            and mix_colours(G.C.BLUE, G.C.L_BLACK, 0.1) or G.C.L_BLACK,
                        0.5
                    )
                    if border and border.parent and border.parent.config then
                        border.parent.config.outline = nil
                        border.parent.config.outline_colour = nil
                    end
                    if border and border.config then
                        border.config.outline_colour = nil
                        border.config.outline = nil
                    end
                    if blind_choice and blind_choice.alignment and blind_choice.alignment.offset then
                        blind_choice.alignment.offset.y = -0.2
                    end
                    if tag_row and tag_container then
                        if G.GAME.round_resets.blind_states[e.config.id] == 'Skipped'
                            or G.GAME.round_resets.blind_states[e.config.id] == 'Defeated' then
                            if tag_container.children and tag_container.children[2] then
                                tag_container.children[2]:set_role({ xy_bond = 'Weak' })
                                tag_container.children[2]:align(0, 10)
                            end
                            if tag_container.children and tag_container.children[1] then
                                tag_container.children[1]:set_role({ xy_bond = 'Weak' })
                                tag_container.children[1]:align(0, 10)
                            end
                        end
                        if G.GAME.round_resets.blind_states[e.config.id] == 'Skipped' then
                            blind_choice.children.alert = UIBox{
                                definition = create_UIBox_card_alert({
                                    text_rot = -0.35, no_bg = true, text = localize('k_skipped_cap'),
                                    bump_amount = 1, scale = 0.9, maxw = 3.4
                                }),
                                config = {
                                    align = "tmi",
                                    offset = { x = 0, y = 2.2 },
                                    major = blind_choice,
                                    parent = blind_choice
                                }
                            }
                        end
                        if tag_row.children and tag_row.children[2] and tag_row.children[2].config then
                            tag_row.children[2].config.button = nil
                            tag_row.children[2].config.hover = false
                            tag_row.children[2].config.colour = G.C.UI.BACKGROUND_INACTIVE
                            if tag_row.children[2].children and tag_row.children[2].children[1]
                                and tag_row.children[2].children[1].config then
                                tag_row.children[2].children[1].config.colour = G.C.UI.TEXT_INACTIVE
                            end
                        end
                        tag_row.config.outline_colour = G.C.UI.BACKGROUND_INACTIVE
                        if tag_row.children and tag_row.children[1] and tag_row.children[1].children then
                            for i = 1, #tag_row.children[1].children do
                                local node = tag_row.children[1].children[i]
                                local sprite = tag_row.config.ref_table and tag_row.config.ref_table[i]
                                if node and node.config then
                                    node.config.button = nil
                                end
                                if sprite and sprite.config then
                                    sprite.config.force_focus = true
                                end
                            end
                        end
                    end
                    if top_button then
                        top_button.config.colour = G.C.UI.BACKGROUND_INACTIVE
                        top_button.config.button = nil
                        top_button.config.hover = false
                        if top_button.children and top_button.children[1] and top_button.children[1].config then
                            top_button.children[1].config.colour = G.C.UI.TEXT_INACTIVE
                        end
                    end
                end
            end
            return
        end

        return reb4l_orig_blind_choice_handler(e)
    end

    -- Wrap vanilla skip_blind so T1/T2 use the selected Branching-style tags.
    local reb4l_orig_skip_t2 = G.FUNCS.skip_blind
    G.FUNCS.skip_blind = function(e)
        local skipped = G.GAME and G.GAME.blind_on_deck
        local pick_count = reb4l_get_fork_pick_count()
        local selected_keys = nil
        local first_tag_key = G.GAME and G.GAME.round_resets and G.GAME.round_resets.blind_tags
            and skipped and G.GAME.round_resets.blind_tags[skipped]
        local selected_index = G.GAME and G.GAME.reb4l_fork_selected_index

        if skipped and reb4l_t1_active() and selected_index and e and e.UIBox then
            local tag_row = e.UIBox:get_UIE_by_ID('tag_' .. skipped)
            local tag_list = tag_row and tag_row.children and tag_row.children[2]
                and tag_row.children[2].config and tag_row.children[2].config.ref_table
            local selected_tag = tag_list and tag_list[selected_index]
            if selected_tag then
                reb4l_clear_fork_popups(skipped)
                if e.alert then
                    e.alert:remove()
                    e.alert = nil
                end
                if G.CONTROLLER.locks.skip_blind then return end
                stop_use()
                G.CONTROLLER.locks.skip_blind = true
                G.E_MANAGER:add_event(Event({
                    no_delete = true,
                    trigger = 'after',
                    blocking = false,
                    blockable = false,
                    delay = 2.5,
                    timer = 'TOTAL',
                    func = function()
                        G.CONTROLLER.locks.skip_blind = nil
                        return true
                    end,
                }))

                G.GAME.skips = (G.GAME.skips or 0) + 1
                if check_for_unlock then
                    check_for_unlock({ type = 'skip_count' })
                end
                if G.GAME then G.GAME.reb4l_tracking_skip = true end
                add_tag(selected_tag)
                if G.GAME then G.GAME.reb4l_tracking_skip = false end
                reb4l_clear_fork_selection(skipped)

                local skip_to = skipped == 'Small' and 'Big'
                    or skipped == 'Big' and 'Boss'
                    or 'Boss'
                G.GAME.round_resets.blind_states[skipped] = 'Skipped'
                G.GAME.round_resets.blind_states[skip_to] = 'Select'
                G.GAME.blind_on_deck = skip_to
                play_sound('generic1')
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        delay(0.3)
                        SMODS.calculate_context({ skip_blind = true })
                        save_run()
                        for i = 1, #G.GAME.tags do
                            G.GAME.tags[i]:apply_to_run({ type = 'immediate' })
                        end
                        for i = 1, #G.GAME.tags do
                            if G.GAME.tags[i]:apply_to_run({ type = 'new_blind_choice' }) then
                                break
                            end
                        end
                        return true
                    end,
                }))
                reb4l_refresh_skip_ui(skipped, skip_to)
                return
            end
        end

        if skipped and pick_count > 0 then
            selected_keys = reb4l_sync_primary_blind_tag(skipped, pick_count)
        end
        reb4l_orig_skip_t2(e)
        local skip_to = G.GAME and G.GAME.blind_on_deck
        if skipped and pick_count > 0 then
            reb4l_refresh_skip_ui(skipped, skip_to)
        end
        if skipped and reb4l_t2_active() then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    local tag_key = get_next_tag_key()
                    local guard = 0
                    while tag_key == first_tag_key and guard < 20 do
                        guard = guard + 1
                        tag_key = get_next_tag_key('_reb4l_fork_' .. guard)
                    end
                    if G.GAME then G.GAME.reb4l_tracking_skip = true end
                    add_tag(Tag(tag_key, nil, skipped))
                    if G.GAME then G.GAME.reb4l_tracking_skip = false end
                    return true
                end,
            }))
        end
    end

end -- REB4LANCED.config.fork_tag_vouchers

-- Edition Tags: apply pending edition when buying an editionless joker from the shop.
-- The apply function in tags.lua blocks vanilla's new_blind_choice and store_joker_modify
-- contexts (returning true keeps the tag alive without triggering it). This hook fires
-- instead, applying the edition on actual purchase and consuming the tag via yep().
if REB4LANCED.config.edition_tags_enhanced then
    local reb4l_edition_tag_map = {
        tag_negative   = 'e_negative',
        tag_foil       = 'e_foil',
        tag_holo       = 'e_holo',
        tag_polychrome = 'e_polychrome',
    }
    local reb4l_orig_buy_from_shop = G.FUNCS.buy_from_shop
    G.FUNCS.buy_from_shop = function(e)
        local card = e.config.ref_table
        local is_editionless_joker = card and card.ability
            and card.ability.set == 'Joker'
            and not card.edition
            and not card.from_tag
        local result = reb4l_orig_buy_from_shop(e)
        if is_editionless_joker then
            for _, tag in ipairs(G.GAME and G.GAME.tags or {}) do
                local edition_key = reb4l_edition_tag_map[tag.key]
                if edition_key and not tag.triggered then
                    local card_ref = card
                    local ed = edition_key
                    tag:yep('+', G.C.DARK_EDITION, function()
                        card_ref:set_edition(ed, true, false)
                        return true
                    end)
                    tag.triggered = true
                    break
                end
            end
        end
        return result
    end
end

-- Card:set_base wrapper for Checkered and Abandoned deck effects.
-- context.create_card / context.modify_playing_card are CardSleeves-specific contexts
-- injected via their own set_base wrapper, not standard SMODS Back:calculate contexts.
-- We replicate that pattern here so our deck effects fire from the same hook point.
local reb4l_orig_set_base = Card.set_base
function Card:set_base(card, initial)
    local output = reb4l_orig_set_base(self, card, initial)
    if not (G.GAME and G.GAME.reb4l_deck) then return output end
    if not (self.ability and (self.ability.set == "Default" or self.ability.set == "Enhanced")
        and self.config and self.config.card_key) then
        return output
    end

    if G.GAME.reb4l_deck == 'checkered' then
        local remap = { Clubs = 'Spades', Diamonds = 'Hearts' }
        local to_suit = remap[self.base.suit]
        if to_suit then
            local suit_key = SMODS.Suits[to_suit].card_key
            local rank_obj = SMODS.Ranks[self.base.value]
            if suit_key and rank_obj then
                local base_key = suit_key .. "_" .. rank_obj.card_key
                if G.P_CARDS[base_key] then
                    self:set_base(G.P_CARDS[base_key], initial)
                end
            end
        end
    elseif G.GAME.reb4l_deck == 'abandoned' then
        local rank = SMODS.Ranks[self.base.value]
        if rank and rank.face then
            local suit_obj = SMODS.Suits[self.base.suit]
            if suit_obj then
                local candidates = {}
                for _, r in pairs(SMODS.Ranks) do
                    if not r.face then
                        local base_key = suit_obj.card_key .. "_" .. r.card_key
                        if G.P_CARDS[base_key] then
                            candidates[#candidates + 1] = G.P_CARDS[base_key]
                        end
                    end
                end
                if #candidates > 0 then
                    table.sort(candidates, function(a, b) return (a.name or "") < (b.name or "") end)
                    self:set_base(
                        pseudorandom_element(candidates, pseudoseed('reb4l_abandoned')),
                        initial
                    )
                end
            end
        end
    end

    return output
end

-- Game:update safety net: clear suit-based debuffs from Wild Cards each frame
-- Belt-and-suspenders alongside the debuff_card override above.
-- Only runs when the active blind has a suit debuff; other debuffs still apply.
local reb4l_orig_game_update = Game.update
function Game:update(dt)
    reb4l_orig_game_update(self, dt)
    if G.playing_cards and G.GAME and G.GAME.blind and G.GAME.blind.debuff and G.GAME.blind.debuff.suit then
        for _, v in ipairs(G.playing_cards) do
            if v.debuff and v.config.center and v.config.center.key == 'm_wild' then
                v.debuff = false
            end
        end
    end
end

-- Black Deck: apply ante 0 after start_run initializes everything
if REB4LANCED.config.black_deck_enhanced then
    local reb4l_orig_start_run = Game.start_run
    function Game:start_run(args)
        reb4l_orig_start_run(self, args)
        if self.GAME and self.GAME.modifiers and self.GAME.modifiers.reb4l_start_ante_zero
            and not (args and args.savetext) then
            self.GAME.round_resets.ante = 0
            self.GAME.round_resets.ante_disp = number_format(0)
            self.GAME.round_resets.blind_ante = 0
            self.GAME.round_resets.blind_choices.Boss = get_new_boss()
            self.GAME.round_resets.blind_tags.Small = get_next_tag_key()
            self.GAME.round_resets.blind_tags.Big = get_next_tag_key()
        end
    end
end

-- ── Magic Trick / Illusion helpers (modelled after QoL Bundle) ───────────────

local function reb4l_try_apply_enhancement(card, seed_key)
    if not card then return end
    local enh = SMODS.poll_enhancement({ key = seed_key, mod = 2.5, guaranteed = nil })
    if enh then card:set_ability(G.P_CENTERS[enh]) end
end

local function reb4l_try_apply_edition(card, seed_key)
    if not card then return end
    local ed = poll_edition(seed_key, 1, false, false)
    if ed then card:set_edition(ed) end
end

local function reb4l_try_apply_seal(card, seed_key)
    if not card then return end
    local seal = SMODS.poll_seal({ key = seed_key, mod = 10, guaranteed = false })
    if seal then card:set_seal(seal) end
end

local function reb4l_try_apply_clip(card, seed_key)
    if not card or not PB_UTIL or not PB_UTIL.poll_paperclip or not PB_UTIL.set_paperclip then
        return
    end
    if pseudorandom(pseudoseed(seed_key)) > 0.8 then
        local clip_type = PB_UTIL.poll_paperclip(seed_key)
        if clip_type then
            PB_UTIL.set_paperclip(card, clip_type)
        end
    end
end

local function reb4l_recalculate_playing_card_cost(card)
    if not card or not card.ability or (card.ability.set ~= 'Default' and card.ability.set ~= 'Enhanced') then
        return
    end
    local extra = 0
    if card.edition then extra = extra + (card.edition.polychrome and 3 or 2) end
    if card.seal    then extra = extra + 1 end
    if card.ability and card.ability.set == 'Enhanced' then extra = extra + 1 end
    card.cost = math.max(1, math.floor(
        (card.base_cost + extra + 0.5) * (100 - G.GAME.discount_percent) / 100
    ))
    card.sell_cost = math.max(1, math.floor(card.cost / 2)) + (card.ability and card.ability.extra_value or 0)
    card.sell_cost_label = card.sell_cost
end

local function reb4l_apply_enhanced_magic_trick_upgrades(card)
    if not card then return end
    reb4l_try_apply_enhancement(card, 'magic_trick_enh')
    reb4l_try_apply_edition(card, 'magic_trick_shop')
    reb4l_try_apply_seal(card, 'magic_trick_seal')
    reb4l_try_apply_clip(card, 'magic_trick_clip')
end

local function reb4l_apply_new_illusion_logic(card)
    if not card then return nil end
    if not G.playing_cards or #G.playing_cards == 0 then
        reb4l_apply_enhanced_magic_trick_upgrades(card)
        return card
    end

    local deck_card = pseudorandom_element(
        G.playing_cards,
        pseudoseed('illusion_deck' .. (G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante or 1))
    )
    if not deck_card then
        reb4l_apply_enhanced_magic_trick_upgrades(card)
        return card
    end

    card:set_base(G.P_CARDS[deck_card.config.card_key])
    if deck_card.edition then
        card:set_edition(deck_card.edition)
    end
    if deck_card.seal then
        card:set_seal(deck_card.seal)
    end
    if deck_card.config and deck_card.config.center and deck_card.config.center.set == 'Enhanced' then
        card:set_ability(deck_card.config.center)
    end

    reb4l_try_apply_enhancement(card, 'illusion_enh_improve')
    reb4l_try_apply_edition(card, 'illusion_ed_improve')
    reb4l_try_apply_seal(card, 'illusion_seal_improve')
    reb4l_try_apply_clip(card, 'illusion_clip_improve')
    return card
end

-- create_card_for_shop override for Magic Trick / Illusion voucher reworks
-- Magic Trick: upgrades shop playing cards with QoL-style rolls.
-- Illusion: copies a random deck card, then rerolls upgrades while preserving
-- copied ones whenever the reroll for that slot misses.
local reb4l_orig_create_card_for_shop = create_card_for_shop
function create_card_for_shop(area)
    local card = reb4l_orig_create_card_for_shop(area)
    if card and card.ability and (card.ability.set == 'Default' or card.ability.set == 'Enhanced') then
        local has_magic    = G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers['v_magic_trick']
        local has_illusion = G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers['v_illusion']

        if has_illusion then
            card = reb4l_apply_new_illusion_logic(card) or card
            reb4l_recalculate_playing_card_cost(card)
        elseif has_magic then
            reb4l_apply_enhanced_magic_trick_upgrades(card)
            reb4l_recalculate_playing_card_cost(card)
        end
    end

    -- Telescope: 50% chance to replace a shop Planet with most-played hand's planet
    if card and card.ability and card.ability.set == 'Planet'
        and G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers['v_telescope'] then
        if pseudorandom(pseudoseed('reb4l_telescope')) < 0.5 then
            local best_hand, best_tally = nil, 0
            for _, handname in ipairs(G.handlist) do
                if SMODS.is_poker_hand_visible and SMODS.is_poker_hand_visible(handname)
                    and G.GAME.hands[handname] and G.GAME.hands[handname].played > best_tally then
                    best_hand = handname
                    best_tally = G.GAME.hands[handname].played
                end
            end
            if best_hand and best_tally > 0 then
                for _, v in pairs(G.P_CENTER_POOLS['Planet'] or {}) do
                    if v.config and v.config.hand_type == best_hand then
                        card:set_ability(G.P_CENTERS[v.key])
                        break
                    end
                end
            end
        end
    end

    return card
end

-- Card:set_cost override: ensure from_tag couponed cards are always free
local reb4l_orig_set_cost = Card.set_cost
function Card:set_cost()
    reb4l_orig_set_cost(self)
    if self.from_tag and self.ability and self.ability.couponed then
        self.cost = 0
    end
end

-- Per-stake chip scaling and Red Stake payout reduction
-- Maps vanilla stake keys to our internal difficulty index 1-8.
-- G.GAME.stake is a pool index that shifts when mods add stakes; using the key is stable.
local reb4l_stake_index = {
    stake_white  = 1,
    stake_red    = 2,
    stake_green  = 3,
    stake_black  = 4,
    stake_blue   = 5,
    stake_purple = 6,
    stake_orange = 7,
    stake_gold   = 8,
}

-- reb4l_base_chips: Small Blind base values for antes 1-8, indexed [stake][ante]
local reb4l_base_chips = {
    [1] = {  300,   800,  2000,  5000, 11000,  20000,  35000,  50000 },  -- White
    [2] = {  300,   850,  2200,  5600, 12500,  23000,  41000,  60000 },  -- Red
    [3] = {  300,   900,  2400,  6400, 14500,  27000,  49000,  75000 },  -- Green
    [4] = {  300,   950,  2700,  7400, 17000,  32000,  60000,  90000 },  -- Black
    [5] = {  300,  1000,  3000,  8600, 20000,  39000,  75000, 110000 },  -- Blue
    [6] = {  300,  1050,  3400, 10000, 23000,  45000,  85000, 130000 },  -- Purple
    [7] = {  300,  1125,  3900, 12000, 25000,  50000, 100000, 160000 },  -- Orange
    [8] = {  300,  1200,  4500, 14000, 30000,  65000, 130000, 200000 },  -- Gold
}

-- Vanilla White Stake Small Blind values for antes 9-14.
-- Used as the endless-mode growth reference for all stakes:
-- base(stake, ante) = (our_ante8[stake] / 50000) * vanilla_white[ante]
-- This mimics vanilla's ramping but anchored to each stake's ante-8 target.
local reb4l_vw = { 110000, 560000, 7200000, 300000000, 47000000000, 29000000000000 }
--                  ^ante9   ^10       ^11        ^12          ^13          ^14

-- Returns the vanilla White Stake Small Blind base for any ante.
-- For ante > 14, extrapolates via chip(N) ≈ 4 * chip(N-1)^2 / chip(N-2),
-- which matches the observed step-multiplier converging to ×4 per ante.
local function reb4l_vanilla_white(ante)
    if ante <= 8 then return reb4l_base_chips[1][ante] end
    local idx = ante - 8
    if reb4l_vw[idx] then return reb4l_vw[idx] end
    local a, b = reb4l_vw[5], reb4l_vw[6]  -- antes 13 and 14
    for _ = 15, ante do
        a, b = b, 4 * b * b / a
    end
    return b
end

-- Per-stake blind chip scaling: override get_blind_amount so both the blind select
-- screen and Blind:set_blind (which calls this function) see stake-appropriate values.
-- Falls back to vanilla if stake_scaling_enhanced is off, no active game, or mod stake.
local reb4l_orig_get_blind_amount = get_blind_amount
function get_blind_amount(ante)
    if REB4LANCED.config.stake_scaling_enhanced
        and G.GAME and G.GAME.stake then
        local stake = reb4l_stake_index[SMODS.stake_from_index(G.GAME.stake)]
        if stake then
            if ante < 1 then return 100 end
            if ante <= 8 then
                return reb4l_base_chips[stake][ante]
            else
                local vw = reb4l_vanilla_white(ante)
                return math.ceil(reb4l_base_chips[stake][8] / 50000 * vw)
            end
        end
    end
    return reb4l_orig_get_blind_amount(ante)
end

-- Red Stake: also show reduced payout on the blind select screen.
-- The select screen bakes blind_choice.config.dollars (G.P_BLINDS[key].dollars) as a
-- static text node, so temporarily patch the value, call original, then restore it.
local reb4l_orig_UIBox_blind_choice = create_UIBox_blind_choice
function create_UIBox_blind_choice(type, run_info)
    local restored = {}
    if G.GAME and G.GAME.modifiers and G.GAME.modifiers.reb4l_payout_decrease
        and G.GAME.round_resets and G.GAME.round_resets.blind_choices then
        local dec = G.GAME.modifiers.reb4l_payout_decrease
        local key = G.GAME.round_resets.blind_choices[type]
        if key and G.P_BLINDS[key] and _G['type'](G.P_BLINDS[key].dollars) == 'number' then
            restored[key] = G.P_BLINDS[key].dollars
            G.P_BLINDS[key].dollars = math.max(0, G.P_BLINDS[key].dollars - dec)
        end
    end
    local result = reb4l_orig_UIBox_blind_choice(type, run_info)
    for k, v in pairs(restored) do G.P_BLINDS[k].dollars = v end
    return result
end

local reb4l_orig_blind_set_blind = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
    local result = reb4l_orig_blind_set_blind(self, blind, reset, silent)
    if not reset and G.GAME and G.GAME.round_resets then
        -- Red Stake payout reduction (self.dollars is the blind payout field in blind.lua)
        if G.GAME.modifiers and G.GAME.modifiers.reb4l_payout_decrease
            and self.dollars and type(self.dollars) == 'number' then
            self.dollars = math.max(0, self.dollars - G.GAME.modifiers.reb4l_payout_decrease)
            G.GAME.current_round.dollars_to_be_earned =
                self.dollars > 0 and string.rep(localize('$'), self.dollars) or ''
        end
    end
    return result
end

-- Reshuffle discards into deck (reserved for a future custom stake).
-- Activate by setting G.GAME.modifiers.reb4l_reshuffle_discards = true in the stake's modifiers.
-- HTR: Jacks are reshuffled into the deck (always active when hit_the_road_enhanced is on).
--
-- Both features populate tables during pre_discard, then the draw_from_deck_to_hand
-- wrapper below performs the actual move + shuffle. By the time draw_from_deck_to_hand
-- runs, all discard animation events have completed and cards ARE in G.discard.
REB4LANCED.black_reshuffle = REB4LANCED.black_reshuffle or {}

local reb4l_orig_calculate_context = SMODS.calculate_context
SMODS.calculate_context = function(ctx, ...)
    if ctx.pre_discard and ctx.full_hand
        and REB4LANCED.config.stakes_enhanced
        and G.GAME and G.GAME.modifiers
        and G.GAME.modifiers.reb4l_reshuffle_discards then
        for _, c in ipairs(ctx.full_hand) do
            REB4LANCED.black_reshuffle[#REB4LANCED.black_reshuffle + 1] = c
        end
    end
    return reb4l_orig_calculate_context(ctx, ...)
end

-- Wrap draw_from_deck_to_hand: by the time this runs, the discard animation events
-- have all completed and cards are physically in G.discard. Move pending cards to
-- the deck and shuffle before any replacement cards are drawn.
local reb4l_orig_draw_from_deck = G.FUNCS.draw_from_deck_to_hand
G.FUNCS.draw_from_deck_to_hand = function(e)
    local shuffled = false
    -- HTR: reshuffle jacks
    if REB4LANCED.htr_jacks and next(REB4LANCED.htr_jacks) then
        for _, jack_card in pairs(REB4LANCED.htr_jacks) do
            if jack_card.area == G.discard then
                G.discard:remove_card(jack_card)
                G.deck:emplace(jack_card)
                shuffled = true
            end
        end
        REB4LANCED.htr_jacks = {}
    end
    -- Black Stake: reshuffle all discarded cards
    if next(REB4LANCED.black_reshuffle) then
        for _, card in ipairs(REB4LANCED.black_reshuffle) do
            if card.area == G.discard then
                G.discard:remove_card(card)
                G.deck:emplace(card)
                shuffled = true
            end
        end
        REB4LANCED.black_reshuffle = {}
    end
    if shuffled then
        G.deck:shuffle('reb4l_reshuffle_'
            .. (G.GAME.hands_played or 0) .. '_'
            .. (G.GAME.current_round.discards_used or 0))
    end
    return reb4l_orig_draw_from_deck(e)
end

local function reb4l_get_base_reroll_cost()
    local base = 5
    if G.GAME and G.GAME.starting_params and type(G.GAME.starting_params.reroll_cost) == 'number' then
        base = G.GAME.starting_params.reroll_cost
    end
    if G.GAME and G.GAME.modifiers and G.GAME.modifiers.reb4l_base_reroll_cost_bonus then
        base = base + G.GAME.modifiers.reb4l_base_reroll_cost_bonus
    end
    return math.max(0, base)
end

local function reb4l_apply_reroll_cost_overrides()
    if not (G.GAME and G.GAME.current_round and G.GAME.round_resets) then return end

    local active_base = G.GAME.round_resets.temp_reroll_cost
        or G.GAME.round_resets.reroll_cost
        or reb4l_get_base_reroll_cost()

    if G.GAME.modifiers and G.GAME.modifiers.reb4l_fixed_reroll_cost then
        local fixed = reb4l_get_base_reroll_cost()
            + (G.GAME.modifiers.reb4l_fixed_reroll_cost_bonus or 0)
        G.GAME.round_resets.free_rerolls = 0
        G.GAME.current_round.free_rerolls = 0
        G.GAME.current_round.reroll_cost = fixed
        G.GAME.current_round.reroll_cost_increase = fixed - active_base
    elseif G.GAME.modifiers and G.GAME.modifiers.reb4l_base_reroll_cost_bonus then
        G.GAME.current_round.reroll_cost = active_base
            + (G.GAME.current_round.reroll_cost_increase or 0)
            + G.GAME.modifiers.reb4l_base_reroll_cost_bonus
    end
end

-- Reroll cost overrides:
-- Black Stake can still add its extra increment here, then Blue Stake's alternate
-- mode raises the base by $2, and Anchor Deck's fixed-reroll mode clamps the final
-- cost so vouchers/free rerolls cannot move it away from its deck-defined price.
local reb4l_orig_calculate_reroll_cost = calculate_reroll_cost
function calculate_reroll_cost(skip_increment)
    local pre = G.GAME and G.GAME.current_round and (G.GAME.current_round.reroll_cost_increase or 0) or 0
    reb4l_orig_calculate_reroll_cost(skip_increment)
    if REB4LANCED.config.stakes_enhanced
        and G.GAME and G.GAME.modifiers and G.GAME.modifiers.reb4l_reroll_scale
        and G.GAME.current_round and G.GAME.round_resets then
        local post = G.GAME.current_round.reroll_cost_increase or 0
        if post > pre then
            local extra = G.GAME.modifiers.reb4l_reroll_scale - 1
            G.GAME.current_round.reroll_cost_increase = post + extra
            G.GAME.current_round.reroll_cost =
                (G.GAME.round_resets.temp_reroll_cost or G.GAME.round_resets.reroll_cost)
                + G.GAME.current_round.reroll_cost_increase
        end
    end
    reb4l_apply_reroll_cost_overrides()
end

local reb4l_orig_game_update_reroll = Game.update
function Game:update(dt)
    reb4l_orig_game_update_reroll(self, dt)
    reb4l_apply_reroll_cost_overrides()
end


-- Anaglyph deck passive: every tag gained creates one more of itself.
if REB4LANCED.config.anaglyph_enhanced then
    local reb4l_orig_add_tag = add_tag
    function add_tag(_tag, ...)
        reb4l_orig_add_tag(_tag, ...)
        if G.GAME and G.GAME.reb4l_anaglyph_active and not _tag.reb4l_anaglyph_copy then
            if _tag.ability and _tag.ability.orbital_hand then
                G.orbital_hand = _tag.ability.orbital_hand
            end
            local copy = Tag(_tag.key)
            copy.reb4l_anaglyph_copy = true
            reb4l_orig_add_tag(copy)
            G.orbital_hand = nil
        end
    end
end


-- Anchor Deck: lock G.hand size (both card_limit and round_resets.hand_size)
-- by making change_size a no-op on G.hand whenever the anchor deck is active.
local reb4l_orig_change_size = CardArea.change_size
function CardArea:change_size(n)
    if self == G.hand and G.GAME and G.GAME.reb4l_anchor_deck then
        return
    end
    return reb4l_orig_change_size(self, n)
end

local reb4l_orig_level_up_hand = level_up_hand
local reb4l_luh_depth = 0
function level_up_hand(card, hand, instant, amount, statustext)
    local is_top = reb4l_luh_depth == 0
    reb4l_luh_depth = reb4l_luh_depth + 1

    -- Constellation: mask ability.name before vanilla runs so its deferred event skips this joker.
    -- We handle the increment and single popup ourselves; re-masking after our event blocks
    -- any remaining vanilla events queued by later same-frame calls (e.g. Black Hole).
    if is_top and REB4LANCED.config.constellation_enhanced and G.jokers then
        for _, joker in ipairs(G.jokers.cards) do
            if joker.config.center.key == 'j_constellation'
               and joker.ability.name == 'Constellation' then
                joker.ability.name = 'reb4l_constellation'
            end
        end
    end

    reb4l_orig_level_up_hand(card, hand, instant, amount, statustext)

    reb4l_luh_depth = reb4l_luh_depth - 1
    if not is_top then return end

    local levels = tonumber(amount) or 1
    if REB4LANCED.config.constellation_enhanced and G.jokers then
        for _, joker in ipairs(G.jokers.cards) do
            if joker.config.center.key == 'j_constellation' then
                local mod = joker.ability.Xmult_mod or 0.1
                joker.ability.reb4l_const_pending = (joker.ability.reb4l_const_pending or 0) + mod * levels
                if not joker.reb4l_const_event_queued then
                    joker.reb4l_const_event_queued = true
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local gain = joker.ability.reb4l_const_pending or 0
                            joker.ability.reb4l_const_pending = 0
                            if gain > 0 then
                                joker.ability.extra = (joker.ability.extra or 1) + gain
                                local total = math.floor(joker.ability.extra * 10000 + 0.5) / 10000
                                card_eval_status_text(joker, 'extra', nil, nil, nil, {
                                    message = localize{type='variable', key='a_xmult', vars={total}},
                                    colour = G.C.XMULT,
                                })
                                joker:juice_up(0.5, 0.3)
                            end
                            -- Re-mask to silence remaining vanilla events from same-frame calls,
                            -- then queue a trailing unmask event after those have all fired.
                            joker.ability.name = 'reb4l_constellation'
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    joker.ability.name = 'Constellation'
                                    joker.reb4l_const_event_queued = false
                                    return true
                                end
                            }))
                            return true
                        end
                    }))
                end
            end
        end
    end
    if REB4LANCED.config.satellite_mode == 3 then
        SMODS.calculate_context({ satellite_level_up = true, levels = levels })
    end
end
