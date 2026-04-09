return function(REB4LANCED)
-- ─── Seeing Double ────────────────────────────────────────────────────────────
-- Changed from single X2 (joker_main) to X1.25 per scoring card (individual).
-- Shows total combined xmult across all scoring card triggers.
JokerDisplay.Definitions["j_seeing_double"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult" },
            },
        },
    },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local xmult = type(card.ability.extra) == "number" and card.ability.extra or 1.25
        if text ~= "Unknown" and #scoring_hand >= 2 and SMODS.seeing_double_check(scoring_hand, 'Clubs') then
            local total_triggers = 0
            for _, c in pairs(scoring_hand) do
                total_triggers = total_triggers + JokerDisplay.calculate_card_triggers(c, scoring_hand)
            end
            card.joker_display_values.xmult = string.format("%.2f", xmult ^ total_triggers)
        else
            card.joker_display_values.xmult = "1.00"
        end
    end,
}

end
