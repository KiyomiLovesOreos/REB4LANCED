return function(REB4LANCED)
-- Mult Card: +6 Mult (vanilla: +4)
if REB4LANCED.config.mult_card_enhanced then
SMODS.Enhancement:take_ownership('mult', {
    loc_txt = {
        name = 'Mult Card',
        text = { '+{C:mult}#1#{} Mult' },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 6 } }
    end,
}, false)
end

end
