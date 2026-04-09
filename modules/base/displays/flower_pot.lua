return function(REB4LANCED)
-- ─── Flower Pot ───────────────────────────────────────────────────────────────
-- Each scoring Wild Card gives +extra Chips per Wild Card in played hand (context.individual).
-- Display sums chips across all wild triggers, accounting for card retriggers.
JokerDisplay.Definitions["j_flower_pot"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local chips = 0
        if text ~= "Unknown" then
            local wild_count = 0
            for _, c in ipairs(scoring_hand) do
                if c.config.center.key == "m_wild" then wild_count = wild_count + 1 end
            end
            if wild_count > 0 then
                for _, c in ipairs(scoring_hand) do
                    if c.config.center.key == "m_wild" then
                        chips = chips + card.ability.extra * wild_count *
                            JokerDisplay.calculate_card_triggers(c, scoring_hand)
                    end
                end
            end
        end
        card.joker_display_values.chips = chips
    end,
}

end
