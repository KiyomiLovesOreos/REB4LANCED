return function(REB4LANCED)
-- Observatory: X2 Mult per Planet card used (vanilla: X1.5)
-- SMODS's own calculate returns { x_mult = card.ability.extra }, so extra must stay a plain number.
if REB4LANCED.config.observatory_enhanced then
SMODS.Voucher:take_ownership('observatory', {
    config = { extra = 2 },
    loc_txt = {
        name = 'Observatory',
        text = {
            '{C:planet}Planet{} cards in your',
            '{C:attention}consumable{} area give',
            '{X:red,C:white} X#1# {} Mult for their',
            'specified {C:attention}poker hand',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
}, false)
end -- REB4LANCED.config.observatory_enhanced

end
