return function(REB4LANCED)
-- Bloodstone: 1/3 for X2 Mult on scoring Hearts card (vanilla: 1/2 for X1.5)
if REB4LANCED.config.bloodstone_enhanced then
SMODS.Joker:take_ownership('bloodstone', {
    config = { extra = { odds = 3, Xmult = 2 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, 3, 'reb4l_bloodstone')
        return { vars = { numerator, denominator, 2 } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit("Hearts") then
            if SMODS.pseudorandom_probability(card, 'reb4l_bloodstone', 1, 3) then
                return { xmult = 2 }
            end
        end
    end,
}, false)
end

end
