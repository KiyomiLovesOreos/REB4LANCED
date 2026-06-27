return function(REB4LANCED)
-- Superposition: generates The Fool if straight + ace in full played hand (Four Fingers synergy)
if REB4LANCED.config.superposition_enhanced then
SMODS.Joker:take_ownership('superposition', {
    loc_txt = {
        name = 'Superposition',
        text = {
            'If {C:attention}played hand{} contains',
            'a {C:attention}Straight{} and an {C:attention}Ace{},',
            'create {C:tarot}The Fool{}',
            '{C:inactive}(if room)',
        },
    },
    calculate = function(self, card, context)
        if context.joker_main and context.scoring_name == 'Straight' then
            local has_ace = false
            for i = 1, #G.play.cards do
                if G.play.cards[i]:get_id() == 14 then
                    has_ace = true
                    break
                end
            end
            if has_ace and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local fool = SMODS.add_card({ key = 'c_fool', key_append = 'reb4l_superposition' })
                        G.GAME.consumeable_buffer = 0
                        if fool then fool:juice_up(0.3, 0.5) end
                        return true
                    end
                }))
                return { message = localize('k_plus_tarot') }
            end
        end
    end,
}, false)

    if JokerDisplay then
        -- ─── Superposition ────────────────────────────────────────────────────────────
        -- Now checks the full played hand (not just scoring cards) for an Ace.
        -- JokerDisplay.current_hand holds all currently selected cards.
        JokerDisplay.Definitions["j_superposition"] = {
            text = {
                { text = "+" },
                { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
            },
            text_config = { colour = G.C.SECONDARY_SET.Tarot },
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "localized_text_ace",      colour = G.C.ORANGE },
                { text = "+" },
                { ref_table = "card.joker_display_values", ref_value = "localized_text_straight", colour = G.C.ORANGE },
                { text = ")" },
            },
            calc_function = function(card)
                local is_superposition = false
                local _, poker_hands, _ = JokerDisplay.evaluate_hand()
                if poker_hands["Straight"] and next(poker_hands["Straight"]) then
                    -- REB4LANCED checks the full played hand, not just scoring cards.
                    for _, played_card in pairs(JokerDisplay.current_hand or {}) do
                        if played_card:get_id() and played_card:get_id() == 14 then
                            is_superposition = true
                            break
                        end
                    end
                end
                card.joker_display_values.count = is_superposition and 1 or 0
                card.joker_display_values.localized_text_straight = localize("Straight", "poker_hands")
                card.joker_display_values.localized_text_ace = localize("Ace", "ranks")
            end,
        }
    end

end -- REB4LANCED.config.superposition_enhanced

end
