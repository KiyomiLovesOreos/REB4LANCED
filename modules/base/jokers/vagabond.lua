return function(REB4LANCED)
-- Vagabond: triggers at $8 or less (vanilla: $4 or less)
-- Vanilla's dispatch reads self.ability.extra as the bare dollar threshold.
if REB4LANCED.config.vagabond_enhanced then
SMODS.Joker:take_ownership('vagabond', {
    config = { extra = 6 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)

    if JokerDisplay then
        -- ─── Vagabond ─────────────────────────────────────────────────────────────────
        -- Triggers at $8 or less (vanilla: $4) via config.extra = 8 (bare number).
        JokerDisplay.Definitions["j_vagabond"] = {
            text = {
                { text = "+" },
                { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
            },
            text_config = { colour = G.C.SECONDARY_SET.Tarot },
            calc_function = function(card)
                local threshold = type(card.ability.extra) == "number" and card.ability.extra or 8
                card.joker_display_values.active = (G.GAME.dollars or 0) <= threshold
                card.joker_display_values.count = card.joker_display_values.active and 1 or 0
            end,
        }
    end

end

end
