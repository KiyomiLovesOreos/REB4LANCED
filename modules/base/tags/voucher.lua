return function(REB4LANCED)
if REB4LANCED.config.voucher_tag_enhanced then
SMODS.Tag:take_ownership('voucher', {
    loc_txt = {
        name = 'Voucher Tag',
        text = {
            'Adds a free {C:voucher}Voucher',
            'to the next shop',
        },
    },
    apply = function(self, tag, context)
        if context.type == 'voucher_add' then
            tag:yep('+', G.C.SECONDARY_SET.Voucher, function()
                local voucher = SMODS.add_voucher_to_shop()
                if voucher then
                    voucher.from_tag = true
                    voucher.ability.couponed = true
                    voucher:set_cost()
                end
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}, false)
end
end
