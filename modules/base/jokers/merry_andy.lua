return function(REB4LANCED)
-- Merry Andy: +3 discards and -1 hand on entering blind; copyable by Blueprint/Brainstorm
-- config added explicitly because vanilla merry_andy does not store discards in config.extra
-- Merry Andy: discards given on entering blind (copyable); -1 hand size is vanilla passive (not copied)
if REB4LANCED.config.merry_andy_enhanced then
SMODS.Joker:take_ownership('merry_andy', {
    blueprint_compat = true,
    config = { extra = { discards = 3 }, d_size = 0, h_size = -1 },
    loc_txt = {
        name = 'Merry Andy',
        text = {
            'When {C:attention}Blind{} is entered,',
            '{C:red}+#1#{} Discards this round',
            '{C:red}-1{} Hand Size',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.discards } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            ease_discard(card.ability.extra.discards)
            return { message = localize{type='variable', key='a_discards', vars={card.ability.extra.discards}}, colour = G.C.RED }
        end
    end,
}, false)
end -- REB4LANCED.config.merry_andy_enhanced

end
