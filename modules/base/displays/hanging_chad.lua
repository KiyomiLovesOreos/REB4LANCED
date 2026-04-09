return function(REB4LANCED)
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
