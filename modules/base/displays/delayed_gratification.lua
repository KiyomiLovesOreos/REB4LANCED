return function(REB4LANCED)
-- ─── Delayed Gratification ────────────────────────────────────────────────────
-- Mode 1 (Vanilla): $2/unused discard, only if no discards used this round
-- Mode 2: $2/unused discard regardless of discards used
-- Mode 3: $4/unused discard, only if no discards used this round
JokerDisplay.Definitions["j_delayed_grat"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    calc_function = function(card)
        local mode  = REB4LANCED.config.delayed_grat_mode or 1
        local unused = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        local used   = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_used) or 0
        local rate   = (mode == 3) and 4 or card.ability.extra
        local payout = (mode == 2 or used == 0) and (unused * rate) or 0
        card.joker_display_values.dollars = payout
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
    end,
}

end
