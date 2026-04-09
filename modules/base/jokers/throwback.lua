return function(REB4LANCED)
-- Throwback: mode-selectable rework
-- Mode 1 (Vanilla): X0.25 per skipped blind
-- Mode 2: X1.0 per skipped blind
-- Mode 3: X0.5 per tag gained this run
if REB4LANCED.config.throwback_enhanced and REB4LANCED.config.throwback_enhanced ~= 1 then
local _mode = REB4LANCED.config.throwback_enhanced
SMODS.Joker:take_ownership('throwback', {
    config = { extra = (_mode == 3) and 0.5 or 1.0 },
    loc_txt = {
        name = 'Throwback',
        text = (_mode == 3) and {
            '{X:mult,C:white} X#1# {} Mult for each',
            '{C:attention}Tag{} obtained this run',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        } or {
            '{X:mult,C:white} X#1# {} Mult for each',
            '{C:attention}Blind{} skipped this run',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local count = (_mode == 3)
            and (G.GAME and G.GAME.reb4l_tags_gained or 0)
            or (G.GAME and G.GAME.skips or 0)
        local current = 1 + card.ability.extra * count
        return { vars = { card.ability.extra, string.format('%.2f', current) } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local count = (_mode == 3)
                and (G.GAME and G.GAME.reb4l_tags_gained or 0)
                or (G.GAME and G.GAME.skips or 0)
            local xmult = 1 + card.ability.extra * count
            if xmult > 1 then
                return { xmult = xmult }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.throwback_enhanced

end
