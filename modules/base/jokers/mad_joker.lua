return function(REB4LANCED)
-- Mad Joker: +10 Mult for Two Pair (vanilla: +8)
if REB4LANCED.config.mad_enhanced then
SMODS.Joker:take_ownership('mad', {
    config = { extra = { t_mult = 10, type = 'Two Pair' } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.t_mult, localize(card.ability.extra.type, 'poker_hands') } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
            return { mult = card.ability.extra.t_mult }
        end
    end,
}, false)

    if JokerDisplay then
        local function hand_type_mult_calc(card)
            local mult = 0
            local _, poker_hands, _ = JokerDisplay.evaluate_hand()
            local hand_type = card.ability.extra and card.ability.extra.type or card.ability.type
            if hand_type and poker_hands[hand_type] and next(poker_hands[hand_type]) then
                mult = (card.ability.extra and card.ability.extra.t_mult) or card.ability.t_mult or 0
            end
            card.joker_display_values.mult = mult
            card.joker_display_values.localized_text = hand_type and localize(hand_type, "poker_hands") or ""
        end
        
        JokerDisplay.Definitions["j_mad"] = {
            text = {
                { text = "+" },
                { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" },
            },
            text_config = { colour = G.C.MULT },
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.ORANGE },
                { text = ")" },
            },
            calc_function = hand_type_mult_calc,
        }
    end

end

end
