return function(REB4LANCED)
-- 8 Ball: 1/3 chance per 8 scored (vanilla: 1/4)
-- Vanilla's card.lua dispatch reads self.ability.extra as the denominator via
-- SMODS.pseudorandom_probability(self, '8ball', 1, self.ability.extra).
-- We only change config.extra; vanilla handles the rest.
-- add_to_deck migrates old saves where ability.extra was incorrectly set to a table.
if REB4LANCED.config.eight_ball_enhanced then
SMODS.Joker:take_ownership('8_ball', {
    config = { extra = 3 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)

    if JokerDisplay then
        -- ─── 8 Ball ───────────────────────────────────────────────────────────────────
        -- Odds changed to 1/2 via config.extra = 2 (vanilla reads ability.extra as denominator).
        -- Vanilla's calculate and loc_vars run unmodified; only display logic overridden here.
        JokerDisplay.Definitions["j_8_ball"] = {
            text = {
                { text = "+" },
                { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
            },
            text_config = { colour = G.C.SECONDARY_SET.Tarot },
            extra = {
                {
                    { text = "(" },
                    { ref_table = "card.joker_display_values", ref_value = "odds" },
                    { text = ")" },
                },
            },
            extra_config = { colour = G.C.GREEN, scale = 0.3 },
            calc_function = function(card)
                local count = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= "Unknown" then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:get_id() and scoring_card:get_id() == 8 then
                            count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.count = count
                local odds = type(card.ability.extra) == "number" and card.ability.extra or 3
                local numerator, denominator = SMODS.get_probability_vars(card, 1, odds, "8ball")
                card.joker_display_values.odds = localize {
                    type = "variable", key = "jdis_odds", vars = { numerator, denominator },
                }
            end,
        }
    end

end

end
