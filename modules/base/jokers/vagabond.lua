return function(REB4LANCED)
-- Vagabond: triggers at $8 or less (vanilla: $4 or less)
-- Vanilla's dispatch reads self.ability.extra as the bare dollar threshold.
if REB4LANCED.config.vagabond_enhanced then
SMODS.Joker:take_ownership('vagabond', {
    config = { extra = 8 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)
end

end
