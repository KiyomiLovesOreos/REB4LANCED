return function(REB4LANCED)
-- 8 Ball: 1/3 chance per 8 scored (vanilla: 1/4)
-- Vanilla's card.lua dispatch reads self.ability.extra as the denominator via
-- SMODS.pseudorandom_probability(self, '8ball', 1, self.ability.extra).
-- We only change config.extra; vanilla handles the rest.
-- add_to_deck migrates old saves where ability.extra was incorrectly set to a table.
if REB4LANCED.config.eight_ball_enhanced then
SMODS.Joker:take_ownership('8_ball', {
    config = { extra = 3 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)
end

end
