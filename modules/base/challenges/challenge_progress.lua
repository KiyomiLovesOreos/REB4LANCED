return function(REB4LANCED)
    if not REB4LANCED.config.challenge_stake_selection then return end

    -- ─── Hook win_game to record the stake a challenge was beaten on ──────────
    -- Vanilla stores `true` for completion.  We store the numeric stake level
    -- (1 = White, 2 = Red, ...) so we can display the correct stake sprite.
    -- Must run AFTER the original (which sets completed = true) so our value sticks.
    local orig_win_game = win_game
    win_game = function()
        -- Read stored value BEFORE orig_win_game overwrites it with `true`
        local prev_stake = 1
        if G.GAME.challenge then
            local prev = G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[G.GAME.challenge]
            prev_stake = type(prev) == 'number' and prev or 1
        end
        orig_win_game()
        if G.GAME.challenge then
            G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[G.GAME.challenge] = math.max(prev_stake, G.GAME.stake or 1)
        end
    end

    -- ─── Override the challenge list to show a stake sprite on beaten ones ────
    -- Replaces the generic green checkmark with the actual stake sprite.
    local orig_list_page = G.UIDEF.challenge_list_page
    G.UIDEF.challenge_list_page = function(_page)
        local snapped = false
        local challenge_list = {}
        for k, v in ipairs(G.CHALLENGES) do
            if k > G.CHALLENGE_PAGE_SIZE * (_page or 0) and k <= G.CHALLENGE_PAGE_SIZE * ((_page or 0) + 1) then
                if G.CONTROLLER.focused.target and G.CONTROLLER.focused.target.config.id == 'challenge_page' then
                    snapped = true
                end

                local progress = G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[v.id or '']
                local challenge_completed = progress and (progress == true or type(progress) == 'number')
                local challenge_unlocked = SMODS.challenge_is_unlocked(v, k)

                -- Determine the stake level to display
                -- Legacy: `true` means White Stake (1).  New: a number 1..N
                local stake_level = challenge_completed and (type(progress) == 'number' and progress or 1) or nil

                -- Build the completion icon — stake sprite if beaten, black square if not
                local icon = nil
                if challenge_completed and stake_level then
                    local sc = G.P_CENTER_POOLS.Stake[stake_level]
                    if sc then
                        local sp = Sprite(0, 0, 0.5, 0.5, G.ASSET_ATLAS[sc.atlas], sc.pos)
                        if sc.shiny then
                            sp.draw = function(_sprite)
                                _sprite.ARGS.send_to_shader = _sprite.ARGS.send_to_shader or {}
                                _sprite.ARGS.send_to_shader[1] = math.min(_sprite.VT.r * 3, 1) + G.TIMERS.REAL / 18 + (_sprite.juice and _sprite.juice.r * 20 or 0) + 1
                                _sprite.ARGS.send_to_shader[2] = G.TIMERS.REAL
                                Sprite.draw_self(_sprite, G.C.L_BLACK)
                                Sprite.draw_shader(_sprite, 'negative_shine', nil, _sprite.ARGS.send_to_shader)
                            end
                        end
                        icon = { n = G.UIT.O, config = { object = sp } }
                    end
                end
                if not icon then
                    icon = { n = G.UIT.C, config = {
                        minh = 0.4, minw = 0.4, emboss = 0.05, r = 0.1,
                        colour = challenge_completed and G.C.GREEN or G.C.BLACK,
                    }, nodes = {} }
                end

                challenge_list[#challenge_list + 1] = {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        -- Number
                        { n = G.UIT.C, config = { align = 'cl', minw = 0.8 }, nodes = {
                            { n = G.UIT.T, config = { text = k .. '', scale = 0.4, colour = G.C.WHITE } },
                        }},
                        -- Name button
                        UIBox_button({
                            id = k, col = true,
                            label = {
                                challenge_unlocked and localize(v.id, 'challenge_names') or localize('k_locked'),
                            },
                            button = challenge_unlocked and 'change_challenge_description' or 'nil',
                            text_colour = v.text_colour,
                            colour = challenge_unlocked and (v.button_colour or G.C.RED) or G.C.GREY,
                            minw = 4, scale = 0.4, minh = 0.6,
                            focus_args = { snap_to = not snapped },
                        }),
                        -- Completion icon: stake sprite or black square
                        { n = G.UIT.C, config = { align = 'cm', padding = 0.05, minw = 0.6 }, nodes = {
                            { n = G.UIT.C, config = {
                                minh = 0.5, minw = 0.5, emboss = 0.05, r = 0.1,
                                colour = challenge_completed and G.C.GREEN or G.C.BLACK,
                            }, nodes = { icon } },
                        }},
                    },
                }
                snapped = true
            end
        end
        return { n = G.UIT.ROOT, config = { align = "cm", padding = 0.1, colour = G.C.CLEAR }, nodes = challenge_list }
    end
end
