return function(REB4LANCED)
-- ─── Throwback ────────────────────────────────────────────────────────────────
-- Value is computed dynamically; vanilla definition pointed at card.ability.x_mult
-- which is never updated by the REB4LANCED calculate function.
JokerDisplay.Definitions["j_throwback"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" },
            },
        },
    },
    calc_function = function(card)
        local count = (REB4LANCED.config.throwback_enhanced == 3)
            and (G.GAME and G.GAME.reb4l_tags_gained or 0)
            or (G.GAME and G.GAME.skips or 0)
        local xmult = 1 + card.ability.extra * count
        card.joker_display_values.xmult = string.format("%.2f", xmult)
    end,
}

end
