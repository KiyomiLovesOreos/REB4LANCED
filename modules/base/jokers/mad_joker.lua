return function(REB4LANCED)
-- Mad Joker: +10 Mult for Two Pair (vanilla: +8)
if REB4LANCED.config.mad_enhanced then
SMODS.Joker:take_ownership('mad', {
    config = { extra = { t_mult = 10, type = 'Two Pair' } },
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
