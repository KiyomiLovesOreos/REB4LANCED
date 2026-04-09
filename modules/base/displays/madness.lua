return function(REB4LANCED)
-- ─── Madness ──────────────────────────────────────────────────────────────────
-- config.extra = 0.75 (bare xmult_gain); current xmult lives in card.ability.x_mult (vanilla).
JokerDisplay.Definitions["j_madness"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability", ref_value = "x_mult", retrigger_type = "exp" },
            },
        },
    },
}

end
