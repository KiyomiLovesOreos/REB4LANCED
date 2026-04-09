return function(REB4LANCED)
-- The Empress: enhances up to 3 cards to Mult Cards (vanilla: 2)
if REB4LANCED.config.tarot_enhance_enhanced then
SMODS.Consumable:take_ownership('empress', {
    config = { max_highlighted = 3, mod_conv = 'm_mult' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 3
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
}, false)

end

end
