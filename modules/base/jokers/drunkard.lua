return function(REB4LANCED)
-- Drunkard: +1 discard on entering blind; copyable by Blueprint/Brainstorm
-- Vanilla fires setting_blind with `not context.blueprint`, blocking copies.
if REB4LANCED.config.drunkard_enhanced then
SMODS.Joker:take_ownership('drunkard', {
    blueprint_compat = true,
    config = { extra = { discards = 1 } },
    loc_txt = {
        name = 'Drunkard',
        text = {
            'When {C:attention}Blind{} is entered,',
            'gain {C:red}+#1#{} Discard this round',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.discards } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            ease_discard(self.config.extra.discards)
            return { message = localize{type='variable', key='a_discards', vars={self.config.extra.discards}}, colour = G.C.RED }
        end
    end,
}, false)

    if JokerDisplay then
        -- ─── Drunkard ─────────────────────────────────────────────────────────────────
        -- Gives +1 discard on entering blind; show count with round indicator.
        -- Uses calc_function so Blueprint/Brainstorm copies display correctly.
        JokerDisplay.Definitions["j_drunkard"] = {
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "discards" },
                { text = " / blind)", colour = G.C.UI.TEXT_INACTIVE },
            },
            calc_function = function(card)
                card.joker_display_values.discards =
                    (type(card.ability.extra) == "table" and card.ability.extra.discards) or 1
            end,
        }
    end

end -- REB4LANCED.config.drunkard_enhanced

end
