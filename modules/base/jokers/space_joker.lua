return function(REB4LANCED)
-- Space Joker: 1/3 chance (vanilla: 1/4)
-- Vanilla's dispatch reads self.ability.extra as the bare odds denominator.
if REB4LANCED.config.space_joker_enhanced then
SMODS.Joker:take_ownership('space', {
    config = { extra = 3 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)
end

end
