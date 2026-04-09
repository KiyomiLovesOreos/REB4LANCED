return function(REB4LANCED)
-- ─── Satellite ────────────────────────────────────────────────────────────────
-- Pays $ceil(highest_hand_level / 2) per round instead of $1 per planet used.
JokerDisplay.Definitions["j_satellite"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    calc_function = function(card)
        local highest = 0
        for _, hand in pairs(G.GAME and G.GAME.hands or {}) do
            local lv = type(hand.level) == 'number' and hand.level
                or tonumber(tostring(hand.level)) or 0
            if lv > highest then highest = lv end
        end
        card.joker_display_values.dollars = math.ceil(highest / 2)
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
    end,
}

end
