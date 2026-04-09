return function(REB4LANCED)
-- Planet Tycoon: each planet card in shop has a 1/odds chance to be Negative
-- extra = 1 nullifies vanilla's planet_rate boost (4*extra); our Negative chance replaces it.
if REB4LANCED.config.planet_tycoon_enhanced then
SMODS.Voucher:take_ownership('planet_tycoon', {
    config = { extra = 1, reb4l_pt_odds = 2 },
    loc_txt = {
        name = 'Planet Tycoon',
        text = {
            '{C:green}1{C:inactive} in {C:green}#1#{} {C:planet}Planet{}',
            'cards in the shop are',
            '{C:dark_edition}Negative',
        },
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'e_negative_consumable', set = 'Edition', config = { extra = 1 } }
        return { vars = { card.ability.reb4l_pt_odds or 2 } }
    end,
    update = function(self, card, dt)
        if G.shop_jokers and G.shop_jokers.cards then
            for _, v in ipairs(G.shop_jokers.cards) do
                if v.ability.set == 'Planet' and not v.tycooned then
                    v.tycooned = true
                    local odds = card.ability.reb4l_pt_odds or 2
                    if pseudorandom(pseudoseed('planet_tycoon_' .. v.sort_id)) < 1 / odds then
                        v:set_edition('e_negative', true)
                    end
                end
            end
        end
    end,
}, false)
end -- REB4LANCED.config.planet_tycoon_enhanced

end
