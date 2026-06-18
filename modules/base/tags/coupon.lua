return function(REB4LANCED)
if REB4LANCED.config.coupon_tag_enhanced then
SMODS.Tag:take_ownership('coupon', {
    loc_txt = {
        name = 'Coupon Tag',
        text = {
            'All items in the next {C:attention}Shop{} are free,',
            'Adds a free random {C:attention}Pack{}',
        },
    },
    apply = function(self, tag, context)
        if context.type == 'shop_final_pass' and G.shop and not G.GAME.shop_free then
            G.GAME.shop_free = true
            local pack_keys = {
                'p_standard_mega_1', 'p_arcana_mega_1',
                'p_celestial_mega_1', 'p_buffoon_mega_1', 'p_spectral_mega_1',
            }
            local pack_key = pseudorandom_element(pack_keys, pseudoseed('reb4l_coupon'))
            tag:yep('+', G.C.GREEN, function()
                if G.shop_jokers and G.shop_booster then
                    for _, card in pairs(G.shop_jokers.cards) do
                        card.ability.couponed = true
                        card:set_cost()
                    end
                    for _, booster in pairs(G.shop_booster.cards) do
                        booster.ability.couponed = true
                        booster:set_cost()
                    end
                end
                local extra_booster = SMODS.add_booster_to_shop(pack_key)
                if extra_booster then
                    extra_booster.ability.couponed = true
                    extra_booster:set_cost()
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
