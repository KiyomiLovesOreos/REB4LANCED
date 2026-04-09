return function(REB4LANCED)
-- ─── Hit the Road ─────────────────────────────────────────────────────────────
-- xmult stored in card.ability.extra.xmult (vanilla used card.ability.x_mult).
-- Gain rate: +0.75 per Jack (vanilla: +0.5). Jacks reshuffled into deck each round.
JokerDisplay.Definitions["j_hit_the_road"] = {
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
