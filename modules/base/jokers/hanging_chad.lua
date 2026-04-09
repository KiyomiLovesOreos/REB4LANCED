return function(REB4LANCED)
-- Hanging Chad: Uncommon/$6, retriggers first scoring card 2 times
if REB4LANCED.config.hanging_chad_enhanced then
SMODS.Joker:take_ownership('hanging_chad', {
    rarity = 2,
    cost = 6,
    loc_txt = {
        name = 'Hanging Chad',
        text = {
            'Retriggers the {C:attention}first{}',
            'scored card {C:attention}#1#{} time(s)',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 2 } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[1] then
            return { repetitions = 2 }
        end
    end,
}, false)
end

end
