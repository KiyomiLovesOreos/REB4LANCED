return function(REB4LANCED)
-- Justice: enhances up to 2 cards to Glass Cards (vanilla: 1)
if REB4LANCED.config.tarot_enhance_enhanced then
SMODS.Consumable:take_ownership('justice', {
    config = { max_highlighted = 2, mod_conv = 'm_glass' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 2
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
}, false)

end -- REB4LANCED.config.tarot_enhance_enhanced

end
