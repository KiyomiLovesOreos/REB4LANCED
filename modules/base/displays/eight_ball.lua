return function(REB4LANCED)
-- ─── 8 Ball ───────────────────────────────────────────────────────────────────
-- Odds changed to 1/2 via config.extra = 2 (vanilla reads ability.extra as denominator).
-- Vanilla's calculate and loc_vars run unmodified; only display logic overridden here.
JokerDisplay.Definitions["j_8_ball"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.SECONDARY_SET.Tarot },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        },
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card:get_id() and scoring_card:get_id() == 8 then
                    count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                end
            end
        end
        card.joker_display_values.count = count
        local odds = type(card.ability.extra) == "number" and card.ability.extra or 3
        local numerator, denominator = SMODS.get_probability_vars(card, 1, odds, "8ball")
        card.joker_display_values.odds = localize {
            type = "variable", key = "jdis_odds", vars = { numerator, denominator },
        }
    end,
}

end
