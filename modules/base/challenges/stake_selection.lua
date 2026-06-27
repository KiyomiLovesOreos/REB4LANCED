return function(REB4LANCED)
    -- ─── State ─────────────────────────────────────────────────────────────────
    REB4LANCED.challenge_stakes = REB4LANCED.challenge_stakes or {}
    REB4LANCED.challenge_stake_page = REB4LANCED.challenge_stake_page or {}

    local PAGE_SIZE = 24

    -- Helper: refresh just the tab contents area (no full rebuild, no flicker)
    local function refresh_tab_contents(_id)
        if not G.OVERLAY_MENU then return end
        local tc = G.OVERLAY_MENU:get_UIE_by_ID('tab_contents')
        if not tc then return end
        tc.config.object:remove()
        tc.config.object = UIBox{
            definition = G.UIDEF.reb4l_challenge_stake_tab({ _id = _id }),
            config = { offset = {x=0,y=0}, parent = tc, type = 'cm' }
        }
        tc.UIBox:recalculate()
    end

    -- ─── Galdur-exact stake selector tab content ──────────────────────────────
    G.UIDEF.reb4l_challenge_stake_tab = function(args)
        local _id = args and args._id
        if not _id then
            return { n = G.UIT.ROOT, config = { align = "cm", colour = G.C.CLEAR }, nodes = {} }
        end
        local num_stakes = #G.P_CENTER_POOLS.Stake
        if num_stakes == 0 then
            return { n = G.UIT.ROOT, config = { align = "cm", colour = G.C.CLEAR }, nodes = {} }
        end
        local selected = REB4LANCED.challenge_stakes[_id] or 1
        local total_pages = math.ceil(num_stakes / PAGE_SIZE)

        if not REB4LANCED.challenge_stake_page[_id] or REB4LANCED.challenge_stake_page[_id] > total_pages then
            REB4LANCED.challenge_stake_page[_id] = 1
        end
        local page = REB4LANCED.challenge_stake_page[_id]
        local first_stake = (page - 1) * PAGE_SIZE + 1
        local last_stake = math.min(page * PAGE_SIZE, num_stakes)
        local stakes_on_page = last_stake - first_stake + 1

        local chip_scale = 3.4 * 14 / 41
        local deck_center = G.P_CENTERS.b_red

        -- Create CardAreas for stakes on this page
        local stake_areas = {}
        for idx = first_stake, last_stake do
            local i = idx - first_stake + 1
            local sc = G.P_CENTER_POOLS.Stake[idx]
            if sc then
                local area = CardArea(0, 0, chip_scale, chip_scale, {
                    card_limit = 1, type = 'deck', highlight_limit = 0, stake_select = true,
                })

                local card = Card(area.T.x, area.T.y, chip_scale, chip_scale,
                    deck_center, deck_center,
                    { stake_chip = true, stake = idx, galdur_selector = true })

                card.facing = 'back'
                card.sprite_facing = 'back'

                local stake_sprite = Sprite(area.T.x, area.T.y, chip_scale, chip_scale,
                    G.ASSET_ATLAS[sc.atlas], sc.pos)
                stake_sprite.states.drag.can = false

                if sc.shiny then
                    stake_sprite.draw = function(_sprite)
                        _sprite.ARGS.send_to_shader = _sprite.ARGS.send_to_shader or {}
                        _sprite.ARGS.send_to_shader[1] = math.min(_sprite.VT.r * 3, 1) + G.TIMERS.REAL / 18 + (_sprite.juice and _sprite.juice.r * 20 or 0) + 1
                        _sprite.ARGS.send_to_shader[2] = G.TIMERS.REAL
                        Sprite.draw_self(_sprite, G.C.L_BLACK)
                        Sprite.draw_shader(_sprite, 'negative_shine', nil, _sprite.ARGS.send_to_shader)
                    end
                end

                card.children.back = stake_sprite
                card.children.back.states.hover = card.states.hover
                card.children.back.states.click = card.states.click
                card.children.back.states.drag = card.states.drag
                card.states.collide.can = false
                card.children.back:set_role({ major = card, role_type = 'Glued', draw_major = card })

                if idx == selected then card.highlighted = true end

                card.click = function(self)
                    REB4LANCED.challenge_stakes[_id] = idx
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after', delay = 0,
                        func = function()
                            refresh_tab_contents(_id)
                            return true
                        end
                    }))
                end

                area:emplace(card)
                stake_areas[i] = area
            end
        end

        -- Grid layout
        local rows_ui = {}
        local count = 1
        local min_rows = math.ceil(stakes_on_page / 8)
        for r = 1, math.min(3, min_rows) do
            local row = { n = G.UIT.R, config = { align = "cl", padding = 0.04 }, nodes = {} }
            for j = 1, 8 do
                if count > stakes_on_page then break end
                row.nodes[#row.nodes + 1] = {
                    n = G.UIT.O,
                    config = {
                        object = stake_areas[count],
                        r = 0.1,
                        id = "reb4l_stake_" .. (first_stake + count - 1),
                        count = first_stake + count - 1,
                        outline_colour = G.C.YELLOW,
                    },
                }
                count = count + 1
            end
            rows_ui[#rows_ui + 1] = row
        end

        -- Page nav
        local nav = nil
        if total_pages > 1 then
            local page_opts = {}
            for i = 1, total_pages do
                page_opts[#page_opts + 1] = localize('k_page') .. ' ' .. i .. '/' .. total_pages
            end
            local cb = 'reb4l_stake_page_' .. _id
            G.FUNCS[cb] = function(e)
                if not e or not e.cycle_config then return end
                local opt = e.cycle_config.current_option
                if type(opt) == 'number' then
                    REB4LANCED.challenge_stake_page[_id] = opt
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after', delay = 0,
                        func = function()
                            refresh_tab_contents(_id)
                            return true
                        end
                    }))
                end
            end
            nav = {
                n = G.UIT.R,
                config = { align = "cm", padding = 0 },
                nodes = { SMODS.GUI.createOptionSelector({
                    label = '', scale = 0.38,
                    options = page_opts, opt_callback = cb,
                    no_pips = true,
                    current_option = localize('k_page') .. ' ' .. page .. '/' .. total_pages,
                    config = { align = "cm", padding = 0, minw = 2.8 },
                })},
            }
        end

        local box_nodes = {}
        for _, r in ipairs(rows_ui) do
            box_nodes[#box_nodes + 1] = r
        end
        if nav then
            box_nodes[#box_nodes + 1] = nav
        end

        return {
            n = G.UIT.ROOT,
            config = { align = "tl", padding = 0.1, colour = G.C.CLEAR },
            nodes = {{
                n = G.UIT.C,
                config = {
                    align = "tl", colour = G.C.L_BLACK,
                    padding = 0.1, r = 0.1, emboss = 0.05,
                },
                nodes = box_nodes,
            }},
        }
    end

    -- ─── Override challenge_description ─────────────────────────────────────────
    local orig_challenge_description = G.UIDEF.challenge_description
    G.UIDEF.challenge_description = function(_id, daily, is_row)
        if not REB4LANCED.config.challenge_stake_selection or daily or is_row or not _id then
            return orig_challenge_description(_id, daily, is_row)
        end
        local challenge = G.CHALLENGES[_id]
        if not challenge then
            return orig_challenge_description(_id, daily, is_row)
        end

        if not REB4LANCED.challenge_stakes[_id] then
            REB4LANCED.challenge_stakes[_id] = 1
        end

        local t = orig_challenge_description(_id, daily, is_row)
        if not (t and t.nodes) then return t end

        local tab_wrapper = t.nodes[2]
        if not (tab_wrapper and tab_wrapper.nodes and tab_wrapper.nodes[1]) then return t end

        local tab_root = tab_wrapper.nodes[1]
        if not (tab_root.nodes and tab_root.nodes[1]) then return t end
        local btn_container = nil
        for k, v in pairs(tab_root.nodes[1].nodes or {}) do
            if type(k) == 'number' and v and v.config and
                (v.config.id == 'no_shoulders' or v.config.id == 'tab_shoulders') then
                btn_container = v
                break
            end
        end
        if not (btn_container and btn_container.nodes) then return t end

        local stake_tab = {
            label = "Stake",
            chosen = false,
            tab_definition_function = G.UIDEF.reb4l_challenge_stake_tab,
            tab_definition_function_args = { _id = _id },
        }

        table.insert(btn_container.nodes, UIBox_button({
            id = 'tab_but_Stake',
            ref_table = stake_tab,
            button = 'change_tab',
            label = { stake_tab.label },
            minh = 0.8 * 0.85,
            minw = 2.5 * 0.85,
            col = true, choice = true,
            scale = 0.36, chosen = false,
            colour = G.C.RED,
            focus_args = { type = 'none' },
        }))

        return t
    end

    -- ─── Override start_challenge_run ───────────────────────────────────────────
    local orig_start_challenge_run = G.FUNCS.start_challenge_run
    G.FUNCS.start_challenge_run = function(e)
        if REB4LANCED.config.challenge_stake_selection and e and e.config and e.config.id then
            local id = e.config.id
            local stake = REB4LANCED.challenge_stakes[id] or 1
            G.FUNCS.start_run(e, { stake = stake, challenge = G.CHALLENGES[id] })
        else
            orig_start_challenge_run(e)
        end
    end
end
