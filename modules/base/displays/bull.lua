return function(REB4LANCED)
-- ─── Bull ─────────────────────────────────────────────────────────────────────
-- Now restricted to Spades/Clubs; +1 Chip per $5 (vanilla: +1 per $1, all suits).
-- config.extra is NOT changed (vanilla code reads it directly), so hardcode divisor of 5.
JokerDisplay.Definitions["j_bull"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function(card)
        local chips_per_card = 3 * math.floor(
            math.max(0, (G.GAME and G.GAME.dollars or 0) + (G.GAME and G.GAME.dollar_buffer or 0)) / 5
        )
        local total = 0
        if chips_per_card > 0 then
            local _, _, scoring_hand = JokerDisplay.evaluate_hand()
            if scoring_hand then
                for _, c in ipairs(scoring_hand) do
                    if c:is_suit('Spades') or c:is_suit('Clubs') then
                        total = total + chips_per_card * JokerDisplay.calculate_card_triggers(c, scoring_hand)
                    end
                end
            end
        end
        card.joker_display_values.chips = total
    end,
}

end
