return function(REB4LANCED)
-- ─── Erosion ──────────────────────────────────────────────────────────────────
-- Changed from +Mult to XMult; now compares against 52 (not starting_deck_size);
-- gain is X0.15 per missing card instead of +4 per missing card.
JokerDisplay.Definitions["j_erosion"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" },
            },
        },
    },
    calc_function = function(card)
        local missing = math.max(0, 52 - (G.playing_cards and #G.playing_cards or 52))
        card.joker_display_values.xmult = string.format("%.2f", 1 + 0.15 * missing)
    end,
}

end
