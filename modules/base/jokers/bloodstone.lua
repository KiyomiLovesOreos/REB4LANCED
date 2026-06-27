return function(REB4LANCED)
-- Bloodstone: 1/3 for X2 Mult on scoring Hearts card (vanilla: 1/2 for X1.5)
if REB4LANCED.config.bloodstone_enhanced then
SMODS.Joker:take_ownership('bloodstone', {
    config = { extra = { odds = 3, Xmult = 2 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, 3, 'reb4l_bloodstone')
        return { vars = { numerator, denominator, 2 } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit("Hearts") then
            if SMODS.pseudorandom_probability(card, 'reb4l_bloodstone', 1, 3) then
                return { xmult = 2 }
            end
        end
    end,
}, false)

    if JokerDisplay then
        -- ─── Bloodstone (enhanced) ────────────────────────────────────────────────────
        -- Odds changed to 1/3, Xmult to X2; SMODS key changed to 'reb4l_bloodstone'.
            JokerDisplay.Definitions["j_bloodstone"] = {
                text = {
                    { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
                    { text = "x", scale = 0.35 },
                    {
                        border_nodes = {
                            { text = "X" },
                            { ref_table = "card.ability.extra", ref_value = "Xmult" },
                        },
                    },
                },
                reminder_text = {
                    { text = "(" },
                    { ref_table = "card.joker_display_values", ref_value = "localized_text" },
                    { text = ")" },
                },
                extra = {
                    {
                        { text = "(" },
                        { ref_table = "card.joker_display_values", ref_value = "odds" },
                        { text = ")" },
                    },
                },
                extra_config = { colour = G.C.GREEN, scale = 0.3 },
                calc_function = function(card)
                    local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                    local count = 0
                    if text ~= "Unknown" then
                        for _, scoring_card in pairs(scoring_hand) do
                            if scoring_card:is_suit("Hearts") then
                                count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                            end
                        end
                    end
                    card.joker_display_values.count = count
                    local odds = card.ability.extra and card.ability.extra.odds or 3
                    local numerator, denominator = SMODS.get_probability_vars(card, 1, odds, "reb4l_bloodstone")
                    card.joker_display_values.odds = localize {
                        type = "variable", key = "jdis_odds", vars = { numerator, denominator },
                    }
                    card.joker_display_values.localized_text = localize("Hearts", "suits_plural")
                end,
                style_function = function(card, text, reminder_text, extra)
                    local suit_node = reminder_text and reminder_text.children and reminder_text.children[2]
                    if suit_node then suit_node.config.colour = lighten(G.C.SUITS["Hearts"], 0.35) end
                end,
            }
        end
    end

end

end
