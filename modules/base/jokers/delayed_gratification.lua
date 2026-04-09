return function(REB4LANCED)
-- Delayed Gratification: mode-selectable rework
-- Mode 1 (Vanilla): $2 per unused discard if no discards used this round
-- Mode 2: $2 per unused discard regardless of discards used
-- Mode 3: $4 per unused discard if no discards used this round
if REB4LANCED.config.delayed_grat_mode and REB4LANCED.config.delayed_grat_mode ~= 1 then
local _mode = REB4LANCED.config.delayed_grat_mode
SMODS.Joker:take_ownership('delayed_grat', {
    loc_txt = {
        name = 'Delayed Gratification',
        text = (_mode == 2) and {
            'Earn {C:money}$2{} for each',
            '{C:attention}Discard{} not used this round',
        } or {
            'Earn {C:money}$4{} for each',
            '{C:attention}Discard{} not used this round',
            'if {C:attention}no discards{} were used',
        },
    },
    calc_dollar_bonus = function(self, card)
        if card.debuff then return end
        local unused = G.GAME.current_round.discards_left or 0
        if _mode == 2 then
            if unused > 0 then return unused * 2 end
        elseif _mode == 3 then
            if (G.GAME.current_round.discards_used or 0) == 0 and unused > 0 then
                return unused * 4
            end
        end
    end,
}, false)
end

end
