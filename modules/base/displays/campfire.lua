return function(REB4LANCED)
-- ─── Campfire ────────────────────────────────────────────────────────────────
-- xmult moved from card.ability.x_mult to card.ability.extra.xmult.
JokerDisplay.Definitions["j_campfire"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" },
            },
        },
    },
}

end
