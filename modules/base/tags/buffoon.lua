return function(REB4LANCED)
if REB4LANCED.config.pack_tags_enhanced then
local function reb4l_shop_pack(tag, color, key)
    tag:yep('+', color, function()
        local card = SMODS.add_booster_to_shop(key)
        if card then
            card.ability.couponed = true
            card:set_cost()
        end
        return true
    end)
    tag.triggered = true
    return true
end

SMODS.Tag:take_ownership('buffoon', {
    min_ante = 2,
    loc_txt = {
        name = 'Buffoon Tag',
        text = {
            'Adds a free {C:attention}Mega Buffoon Pack{}',
            'to the {C:attention}next shop',
        },
    },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_buffoon_mega_1
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then return true end
        if context.type == 'shop_final_pass' and G.shop and G.shop_booster then
            return reb4l_shop_pack(tag, G.C.SECONDARY_SET.Spectral, 'p_buffoon_mega_1')
        end
    end,
}, false)
end
end
