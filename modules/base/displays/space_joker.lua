return function(REB4LANCED)
-- ─── Space Joker ──────────────────────────────────────────────────────────────
-- Odds changed to 1/3 via config.extra = 3 (vanilla reads ability.extra as bare denominator).
JokerDisplay.Definitions["j_space"] = {
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        },
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local odds = type(card.ability.extra) == "number" and card.ability.extra or 3
        local numerator, denominator = SMODS.get_probability_vars(card, 1, odds, "space")
        card.joker_display_values.odds = localize {
            type = "variable", key = "jdis_odds", vars = { numerator, denominator },
        }
    end,
}

end
