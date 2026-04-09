return function(REB4LANCED)
-- ─── Merry Andy ───────────────────────────────────────────────────────────────
-- Gives +3 discards and -1 hand on entering blind; show counts.
-- Uses calc_function so Blueprint/Brainstorm copies display correctly.
JokerDisplay.Definitions["j_merry_andy"] = {
    reminder_text = {
        { text = "(" },
        { text = "+",                                                             colour = G.C.RED },
        { ref_table = "card.joker_display_values", ref_value = "discards",        colour = G.C.RED },
        { text = " Disc / blind | -1 Hand Size)", colour = G.C.UI.TEXT_INACTIVE },
    },
    calc_function = function(card)
        card.joker_display_values.discards =
            (type(card.ability.extra) == "table" and card.ability.extra.discards) or 3
    end,
}

end
