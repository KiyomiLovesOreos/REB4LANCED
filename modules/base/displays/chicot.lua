return function(REB4LANCED)
-- ─── Chicot (mode 3 only) ─────────────────────────────────────────────────────
-- Mode 1 (vanilla disable): handled correctly by vanilla JokerDisplay definition.
-- Mode 2 (reduce 33%):      vanilla active/inactive display is still accurate.
-- Mode 3 (echo skip tags):  show current skip-tag count instead.
if REB4LANCED.config.chicot_mode == 3 then
    JokerDisplay.Definitions["j_chicot"] = {
        text = {
            { ref_table = "card.joker_display_values", ref_value = "tag_count" },
        },
        text_config = { colour = G.C.ORANGE },
        reminder_text = {
            { text = "(skip tags)", colour = G.C.UI.TEXT_INACTIVE },
        },
        calc_function = function(card)
            card.joker_display_values.tag_count = G.GAME and #(G.GAME.reb4l_skip_tags or {}) or 0
        end,
    }
end

end
