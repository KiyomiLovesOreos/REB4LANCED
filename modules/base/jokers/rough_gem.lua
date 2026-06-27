return function(REB4LANCED)
-- Rough Gem: $2 per scoring Diamond (vanilla: $1)
if REB4LANCED.config.rough_gem_enhanced then
SMODS.Joker:take_ownership('rough_gem', {
    config = { extra = 2 },
    loc_txt = {
        name = 'Rough Gem',
        text = {
            'Played cards with',
            '{C:diamonds}Diamond{} suit earn',
            '{C:money}$#1#{} when scored',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
}, false)

    if JokerDisplay then
        -- ─── Rough Gem ────────────────────────────────────────────────────────────────
        -- Payout changed to $2 per scoring Diamond (vanilla: $1).
        -- Vanilla JokerDisplay may reference card.ability.extra as a bare number (old API);
        -- this override reads card.ability.extra.dollars to match SMODS 1.x storage.
        JokerDisplay.Definitions["j_rough_gem"] = {
            text = {
                { text = "+$" },
                { ref_table = "card.joker_display_values", ref_value = "dollars" },
            },
            text_config = { colour = G.C.GOLD },
            calc_function = function(card)
                local total = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= "Unknown" then
                    local dollars = (type(card.ability.extra) == "number") and card.ability.extra or 2
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:is_suit("Diamonds") then
                            total = total + dollars * JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.dollars = total
            end,
        }
    end

end -- REB4LANCED.config.rough_gem_enhanced

end
