return function(REB4LANCED)
-- Droll Joker: +15 Mult for Flush (vanilla: +10)
if REB4LANCED.config.droll_enhanced then
SMODS.Joker:take_ownership('droll', {
    config = { extra = { t_mult = 15, type = 'Flush' } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.t_mult, localize(card.ability.extra.type, 'poker_hands') } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
            return { mult = card.ability.extra.t_mult }
        end
    end,
}, false)
end

end
