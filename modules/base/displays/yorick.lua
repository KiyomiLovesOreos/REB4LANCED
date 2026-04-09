return function(REB4LANCED)
-- ─── Yorick ───────────────────────────────────────────────────────────────────
-- Completely reworked: retriggers all played cards N times where
-- N = 1 + floor(hands_played / 23).  Vanilla tracked discards to upgrade.
JokerDisplay.Definitions["j_yorick"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "retriggers", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.ORANGE },
    reminder_text = {
        { text = "(next in ",                              colour = G.C.UI.TEXT_INACTIVE },
        { ref_table = "card.joker_display_values", ref_value = "next_in" },
        { text = ")",                                      colour = G.C.UI.TEXT_INACTIVE },
    },
    calc_function = function(card)
        local played = G.GAME and G.GAME.hands_played or 0
        card.joker_display_values.retriggers = 1 + math.floor(played / 23)
        card.joker_display_values.next_in    = 23 - (played % 23)
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand then return 0 end
        local played = G.GAME and G.GAME.hands_played or 0
        local retriggers = 1 + math.floor(played / 23)
        return retriggers * JokerDisplay.calculate_joker_triggers(joker_card)
    end,
}

end
