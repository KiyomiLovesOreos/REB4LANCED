return function(REB4LANCED)
-- Golden Joker: $6/round, cost $8 (vanilla: $4/round, cost $6)
-- Cost patched in src/patches.lua
if REB4LANCED.config.golden_enhanced then
SMODS.Joker:take_ownership('golden', {
    config = { extra = 6 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calc_dollar_bonus = function(self, card)
        return card.ability.extra
    end,
}, false)
end -- REB4LANCED.config.golden_enhanced

end
