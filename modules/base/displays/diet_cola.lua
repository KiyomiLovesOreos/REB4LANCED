return function(REB4LANCED)
-- ─── Diet Cola (enhanced) ─────────────────────────────────────────────────────
-- Creates Double Tag at end of round (3 uses then self-destructs).
-- Vanilla definition was empty; show remaining uses in reminder text.
if REB4LANCED.config.diet_cola_enhanced then
    JokerDisplay.Definitions["j_diet_cola"] = {
        reminder_text = {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "uses_remaining" },
            { text = " uses)", colour = G.C.UI.TEXT_INACTIVE },
        },
        calc_function = function(card)
            card.joker_display_values.uses_remaining =
                (card.ability and card.ability.extra and card.ability.extra.tags_remaining) or 0
        end,
    }
end

end
