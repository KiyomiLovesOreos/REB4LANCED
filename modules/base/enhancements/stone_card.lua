return function(REB4LANCED)
-- Stone Card: +75 Chips (vanilla: +50)
if REB4LANCED.config.stone_card_enhanced then
SMODS.Enhancement:take_ownership('stone', {
    replace_base_card = true,
    loc_txt = {
        name = 'Stone Card',
        text = { '+{C:chips}#1#{} Chips, {C:attention}no rank or suit' },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 75 } }
    end,
}, false)
end

end
