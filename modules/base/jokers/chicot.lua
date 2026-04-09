return function(REB4LANCED)
-- Chicot mode 2: reduces all blind chip requirements by 33%, Blueprint/Brainstorm copyable
if REB4LANCED.config.chicot_mode == 2 then
SMODS.Joker:take_ownership('chicot', {
    blueprint_compat = true,
    loc_txt = {
        name = 'Chicot',
        text = {
            'When entering a {C:attention}Blind{},',
            'chip requirement reduced by {C:attention}33%',
        },
    },
    calculate = function(self, card, context)
        if context.setting_blind then
            -- Only the first non-debuffed Chicot in the joker area drives the events.
            -- It queues one reduction event *per Chicot* in order, so each event reads
            -- the value already reduced by the previous one (true diminishing returns).
            -- Other Chicots bail out here to avoid queuing duplicate events.
            if G.jokers then
                for _, joker in ipairs(G.jokers.cards) do
                    if joker.config.center.key == 'j_chicot' and not joker.debuff then
                        if joker ~= card then return nil end
                        break
                    end
                end
            end
            local count = 0
            if G.jokers then
                for _, joker in ipairs(G.jokers.cards) do
                    if joker.config.center.key == 'j_chicot' and not joker.debuff then
                        count = count + 1
                    end
                end
            end
            for _ = 1, count do
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.GAME.blind.chips = math.ceil(G.GAME.blind.chips * (2 / 3))
                        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                        if G.HUD_blind then G.HUD_blind:recalculate() end
                        return true
                    end
                }))
            end
            return nil
        end
    end,
}, false)
end

-- Chicot mode 3: on defeating a boss blind, gain a copy of every tag gained from blind skips this run
if REB4LANCED.config.chicot_mode == 3 then
SMODS.Joker:take_ownership('chicot', {
    blueprint_compat = true,
    loc_txt = {
        name = 'Chicot',
        text = {
            'On defeating a {C:attention}Boss Blind{},',
            'gain a copy of every {C:attention}Tag{}',
            'gained from {C:attention}Blind Skips{} this run',
            '{C:inactive}(Currently {C:attention}#1#{C:inactive} skip tags)',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME and #(G.GAME.reb4l_skip_tags or {}) or 0 } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            return nil
        end
        if context.end_of_round and context.game_over == false and context.main_eval
            and context.beat_boss then
            local skip_tags = G.GAME and G.GAME.reb4l_skip_tags or {}
            if #skip_tags > 0 then
                local snapshot = {}
                for _, key in ipairs(skip_tags) do
                    snapshot[#snapshot + 1] = key
                end
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for _, key in ipairs(snapshot) do
                            add_tag(Tag(key))
                            play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                        end
                        return true
                    end
                }))
                return { message = 'Echo!', colour = G.C.GREEN }
            end
        end
    end,
}, false)
end

end
