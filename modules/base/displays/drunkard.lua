return function(REB4LANCED)
-- ─── Drunkard ─────────────────────────────────────────────────────────────────
-- Gives +1 discard on entering blind; show count with round indicator.
-- Uses calc_function so Blueprint/Brainstorm copies display correctly.
JokerDisplay.Definitions["j_drunkard"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "discards" },
        { text = " / blind)", colour = G.C.UI.TEXT_INACTIVE },
    },
    calc_function = function(card)
        card.joker_display_values.discards =
            (type(card.ability.extra) == "table" and card.ability.extra.discards) or 1
    end,
}

end
