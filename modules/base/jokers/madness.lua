return function(REB4LANCED)
-- Madness: xmult_gain +0.75 per blind (vanilla: +0.5)
-- Vanilla's dispatch reads self.ability.extra as bare xmult_gain; current xmult in ability.x_mult.
if REB4LANCED.config.madness_enhanced then
SMODS.Joker:take_ownership('madness', {
    config = { extra = 0.75 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.x_mult = card.ability.extra.xmult or 1
            card.ability.extra = self.config.extra
        end
    end,
}, false)
end

end
