return function(REB4LANCED)
-- Crazy Joker: +18 Mult for Straight (vanilla: +12)
if REB4LANCED.config.crazy_enhanced then
SMODS.Joker:take_ownership('crazy', {
    config = { extra = { t_mult = 18, type = 'Straight' } },
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
