return function(REB4LANCED)
-- ─── Constellation ────────────────────────────────────────────────────────────
-- Xmult stored in card.ability.extra (current value); Xmult_mod is the per-level increment.
-- Incremented manually in overrides.lua level_up_hand (vanilla handling disabled by SMODS).
JokerDisplay.Definitions["j_constellation"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" },
            },
        },
    },
    calc_function = function(card)
        card.joker_display_values.xmult = card.ability.extra or 1
    end,
}

end
