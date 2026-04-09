return function(REB4LANCED)
-- ─── Superposition ────────────────────────────────────────────────────────────
-- Now checks the full played hand (not just scoring cards) for an Ace.
-- JokerDisplay.current_hand holds all currently selected cards.
JokerDisplay.Definitions["j_superposition"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.SECONDARY_SET.Tarot },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text_ace",      colour = G.C.ORANGE },
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text_straight", colour = G.C.ORANGE },
        { text = ")" },
    },
    calc_function = function(card)
        local is_superposition = false
        local _, poker_hands, _ = JokerDisplay.evaluate_hand()
        if poker_hands["Straight"] and next(poker_hands["Straight"]) then
            -- REB4LANCED checks the full played hand, not just scoring cards.
            for _, played_card in pairs(JokerDisplay.current_hand or {}) do
                if played_card:get_id() and played_card:get_id() == 14 then
                    is_superposition = true
                    break
                end
            end
        end
        card.joker_display_values.count = is_superposition and 1 or 0
        card.joker_display_values.localized_text_straight = localize("Straight", "poker_hands")
        card.joker_display_values.localized_text_ace = localize("Ace", "ranks")
    end,
}

end
