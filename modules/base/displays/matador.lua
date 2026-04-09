return function(REB4LANCED)
-- ─── Matador ──────────────────────────────────────────────────────────────────
-- Now earns $5 on EVERY hand played during a boss blind (vanilla: $8 only when
-- playing the required hand of the boss blind).
JokerDisplay.Definitions["j_matador"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.ability", ref_value = "extra", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { text = "(", colour = G.C.UI.TEXT_INACTIVE },
        { ref_table = "card.joker_display_values", ref_value = "active_text" },
        { text = ")", colour = G.C.UI.TEXT_INACTIVE },
    },
    calc_function = function(card)
        local boss_active = G.GAME.blind and G.GAME.blind.get_type and
            (not G.GAME.blind.disabled) and (G.GAME.blind:get_type() == "Boss")
        card.joker_display_values.active = boss_active
        card.joker_display_values.active_text = localize(boss_active and "jdis_active" or "jdis_inactive")
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children and reminder_text.children[2] then
            reminder_text.children[2].config.colour =
                card.joker_display_values.active and G.C.GREEN or G.C.UI.TEXT_INACTIVE
        end
    end,
}

end
