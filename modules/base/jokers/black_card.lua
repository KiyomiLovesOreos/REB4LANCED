return function(REB4LANCED)
-- Black Card: Uncommon, +$1 whenever you gain money.
if REB4LANCED.config.black_card_enhanced then
SMODS.Joker({
    key    = 'black_card',
    atlas  = 'reb4l_jokers',
    pos    = { x = 0, y = 1 },
    rarity = 2,
    cost   = 5,
    blueprint_compat = true,
    eternal_compat   = true,
    loc_txt = {
        name = 'Black Card',
        text = {
            'Whenever you gain {C:money}money{},',
            'gain an additional {C:money}$1{}',
        },
    },
    calculate = function(self, card, context)
        if context.reb4l_money_gain then
            ease_dollars(1)
            return {
                message = '+$1',
                colour  = G.C.MONEY,
            }
        end
    end,
})
end -- REB4LANCED.config.black_card_enhanced

end
