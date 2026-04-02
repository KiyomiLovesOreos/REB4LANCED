-- Only tags that differ from vanilla behavior get take_ownership.
-- Keys use the vanilla identifier WITHOUT the 'tag_' class prefix.

-- Edition Tags (negative, foil, holo, polychrome):
--   Enhanced behavior: buy_card hook in overrides.lua handles edition on purchase.
if REB4LANCED.config.edition_tags_enhanced then

SMODS.Tag:take_ownership('negative', {
    min_ante = 2,
    loc_txt = {
        name = 'Negative Tag',
        text = {
            'Next {C:attention}editionless{} Joker',
            'bought from the {C:attention}shop{}',
            'gains {C:dark_edition}Negative{} edition',
        },
    },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then return true end
        -- buy_card hook in overrides.lua handles edition on purchase; block vanilla store_joker_modify
    end,
    in_pool = function(self, args)
        return G.P_CENTERS["e_negative"].discovered
    end,
}, false)

SMODS.Tag:take_ownership('foil', {
    loc_txt = {
        name = 'Foil Tag',
        text = {
            'Next {C:attention}editionless{} Joker',
            'bought from the {C:attention}shop{}',
            'gains {C:foil}Foil{} edition',
        },
    },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_foil
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then return true end
    end,
    in_pool = function(self, args)
        return G.P_CENTERS["e_foil"].discovered
    end,
}, false)

SMODS.Tag:take_ownership('holo', {
    loc_txt = {
        name = 'Holographic Tag',
        text = {
            'Next {C:attention}editionless{} Joker',
            'bought from the {C:attention}shop{}',
            'gains {C:holo}Holographic{} edition',
        },
    },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then return true end
    end,
    in_pool = function(self, args)
        return G.P_CENTERS["e_holo"].discovered
    end,
}, false)

SMODS.Tag:take_ownership('polychrome', {
    loc_txt = {
        name = 'Polychrome Tag',
        text = {
            'Next {C:attention}editionless{} Joker',
            'bought from the {C:attention}shop{}',
            'gains {C:polychrome}Polychrome{} edition',
        },
    },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then return true end
    end,
    in_pool = function(self, args)
        return G.P_CENTERS["e_polychrome"].discovered
    end,
}, false)

end -- REB4LANCED.config.edition_tags_enhanced

-- Pack Tags (standard, charm, meteor, buffoon, ethereal):
--   Adds mega pack to next shop instead of opening immediately.

if REB4LANCED.config.pack_tags_enhanced then

SMODS.Tag:take_ownership('standard', {
    min_ante = 2,
    loc_txt = {
        name = 'Standard Tag',
        text = {
            'Adds a free {C:attention}Mega Standard Pack{}',
            'to the {C:attention}next shop',
        },
    },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_standard_mega_1
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then return true end
        if context.type == 'shop_final_pass' and G.shop and G.shop_booster then
            tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
                local card = SMODS.add_booster_to_shop('p_standard_mega_1')
                if card then card.ability.couponed = true; card:set_cost() end
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}, false)

SMODS.Tag:take_ownership('charm', {
    loc_txt = {
        name = 'Charm Tag',
        text = {
            'Adds a free {C:attention}Mega Arcana Pack{}',
            'to the {C:attention}next shop',
        },
    },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_arcana_mega_1
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then return true end
        if context.type == 'shop_final_pass' and G.shop and G.shop_booster then
            local key = pseudorandom_element({'p_arcana_mega_1', 'p_arcana_mega_2'}, pseudoseed('reb4l_charm'))
            tag:yep('+', G.C.PURPLE, function()
                local card = SMODS.add_booster_to_shop(key)
                if card then card.ability.couponed = true; card:set_cost() end
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}, false)

SMODS.Tag:take_ownership('meteor', {
    min_ante = 2,
    loc_txt = {
        name = 'Meteor Tag',
        text = {
            'Adds a free {C:attention}Mega Celestial Pack{}',
            'to the {C:attention}next shop',
        },
    },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_celestial_mega_1
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then return true end
        if context.type == 'shop_final_pass' and G.shop and G.shop_booster then
            local key = pseudorandom_element({'p_celestial_mega_1', 'p_celestial_mega_2'}, pseudoseed('reb4l_meteor'))
            tag:yep('+', G.C.SECONDARY_SET.Planet, function()
                local card = SMODS.add_booster_to_shop(key)
                if card then card.ability.couponed = true; card:set_cost() end
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}, false)

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
            tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
                local card = SMODS.add_booster_to_shop('p_buffoon_mega_1')
                if card then card.ability.couponed = true; card:set_cost() end
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}, false)

SMODS.Tag:take_ownership('ethereal', {
    min_ante = 2,
    loc_txt = {
        name = 'Ethereal Tag',
        text = {
            'Adds a free {C:attention}Spectral Pack{}',
            'to the {C:attention}next shop',
        },
    },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_spectral_normal_1
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then return true end
        if context.type == 'shop_final_pass' and G.shop and G.shop_booster then
            tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
                local card = SMODS.add_booster_to_shop('p_spectral_normal_1')
                if card then card.ability.couponed = true; card:set_cost() end
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}, false)

end -- REB4LANCED.config.pack_tags_enhanced

-- Uncommon Tag / Rare Tag: directly spawn a Joker (vanilla: adds one to shop)
if REB4LANCED.config.joker_tags_enhanced then
SMODS.Tag:take_ownership('uncommon', {
    loc_txt = {
        name = 'Uncommon Tag',
        text = {
            'Creates a random',
            '{C:green}Uncommon{} Joker',
            '{C:inactive}(Must have room){}',
        },
    },
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.GREEN, function()
                if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                    SMODS.add_card({ set = 'Joker', rarity = 'Uncommon', key_append = 'uta' })
                end
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}, false)

-- Rare Tag: directly spawns a random Rare Joker (vanilla: adds one to shop)
SMODS.Tag:take_ownership('rare', {
    loc_txt = {
        name = 'Rare Tag',
        text = {
            'Creates a random',
            '{C:red}Rare{} Joker',
            '{C:inactive}(Must have room){}',
        },
    },
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.RED, function()
                if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                    SMODS.add_card({ set = 'Joker', rarity = 'Rare', key_append = 'rta' })
                end
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}, false)
end -- REB4LANCED.config.joker_tags_enhanced

-- Voucher Tag: adds a free Voucher to the next shop
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
end -- REB4LANCED.config.voucher_tag_enhanced

-- Garbage Tag: $2/discard
if REB4LANCED.config.garbage_tag_enhanced then
SMODS.Tag:take_ownership('garbage', {
    min_ante = 2,
    config = { dollars_per_discard = 2 },
    loc_vars = function(self, info_queue, tag)
        return { vars = { 2, 2 * (G.GAME.unused_discards or 0) } }
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.MONEY, function()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            ease_dollars((G.GAME.unused_discards or 0) * 2)
            tag.triggered = true
            return true
        end
    end,
}, false)
end -- REB4LANCED.config.garbage_tag_enhanced

-- Coupon Tag: enhanced adds a free random booster pack
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
                'p_celestial_mega_1', 'p_buffoon_mega_1', 'p_spectral_mega_1'
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
end -- REB4LANCED.config.coupon_tag_enhanced

-- Double Tag: adds reb4l_dt_firing guard so Anaglyph doubling doesn't loop on this tag
if REB4LANCED.config.anaglyph_enhanced then
SMODS.Tag:take_ownership('double', {
    apply = function(self, tag, context)
        if context.type == 'tag_add' and context.tag.key ~= 'tag_double' and context.tag.key ~= 'double' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.BLUE, function()
                if context.tag.ability and context.tag.ability.orbital_hand then
                    G.orbital_hand = context.tag.ability.orbital_hand
                end
                if G.GAME then G.GAME.reb4l_dt_firing = true end
                add_tag(Tag(context.tag.key))
                if G.GAME then G.GAME.reb4l_dt_firing = false end
                G.orbital_hand = nil
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
        end
    end,
}, false)
end -- REB4LANCED.config.anaglyph_enhanced

-- Orbital Tag: 5 levels (vanilla: 3 levels)
if REB4LANCED.config.tag_reworks_enhanced then
SMODS.Tag:take_ownership('orbital', {
    min_ante = 1,
    config = { levels = 5 },
    loc_vars = function(self, info_queue, tag)
        return {
            vars = {
                (tag.ability.orbital_hand == '[' .. localize('k_poker_hand') .. ']') and tag.ability.orbital_hand or
                localize(tag.ability.orbital_hand, 'poker_hands'), 5 }
        }
    end,
    set_ability = function(self, tag)
        if G.orbital_hand then
            tag.ability.orbital_hand = G.orbital_hand
        elseif tag.ability.blind_type then
            if G.GAME.orbital_choices and G.GAME.orbital_choices[G.GAME.round_resets.ante][tag.ability.blind_type] then
                tag.ability.orbital_hand = G.GAME.orbital_choices[G.GAME.round_resets.ante][tag.ability.blind_type]
            end
        end
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            SMODS.upgrade_poker_hands({ from = tag, hands = { tag.ability.orbital_hand }, level_up = 5 })
            tag:yep('+', G.C.MONEY, function()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}, false)
end

-- Economy Tag: max $50 (vanilla: $40)
if REB4LANCED.config.tag_reworks_enhanced then
SMODS.Tag:take_ownership('economy', {
    config = { max = 50 },
    loc_vars = function(self, info_queue, tag)
        return { vars = { 50 } }
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.MONEY, function()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    ease_dollars(math.min(50, math.max(0, G.GAME.dollars)), true)
                    return true
                end
            }))
            tag.triggered = true
            return true
        end
    end,
}, false)
end
