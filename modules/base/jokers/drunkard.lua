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
end -- REB4LANCED.config.drunkard_enhanced

end
