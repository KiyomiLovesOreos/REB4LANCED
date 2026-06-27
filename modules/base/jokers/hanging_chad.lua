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

    if JokerDisplay then
        -- ─── Hanging Chad ─────────────────────────────────────────────────────────────
        -- Now retriggers the first scoring card 2 times (vanilla: 1).
        -- Vanilla retrigger_function read ability.extra (= 1); hardcode 2 here.
        JokerDisplay.Definitions["j_hanging_chad"] = {
            retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
                if held_in_hand then return 0 end
                local first_card = scoring_hand and JokerDisplay.calculate_leftmost_card(scoring_hand)
                return first_card and playing_card == first_card and
                    2 * JokerDisplay.calculate_joker_triggers(joker_card) or 0
            end,
        }
    end

end

end
