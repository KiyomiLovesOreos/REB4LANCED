return function(REB4LANCED)
-- Magic Trick: playing cards in shop may appear with enhancements, editions, seals,
-- or paper clips when Paperback is present (behavior in overrides.lua create_card_for_shop)
if REB4LANCED.config.magic_trick_enhanced then
SMODS.Voucher:take_ownership('magic_trick', {
    loc_txt = {
        name = 'Magic Trick',
        text = {
            '{C:attention}Playing cards{} in shop',
            'may appear with {C:attention}enhancements{},',
            '{C:dark_edition}editions{}, {C:attention}seals{}, or',
            '{C:attention}paper clips{} {C:inactive}(Paperback)',
        },
    },
}, false)
end -- REB4LANCED.config.magic_trick_enhanced

end
