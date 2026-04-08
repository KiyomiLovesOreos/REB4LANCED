-- Atlas for new REB4LANCED vouchers (placeholder sprite sheet; replace with real art later).
SMODS.Atlas({
    key  = 'vouchers',
    path = 'Vouchers.png',
    px   = 71,
    py   = 95,
})

-- Hieroglyph: -1 Ante + -1 Discard (vanilla: -1 Ante + -1 Hand)
-- Petroglyph: -1 Ante + -1 Hand (vanilla: -1 Ante + -1 Discard)
if REB4LANCED.config.hieroglyph_rework then
SMODS.Voucher:take_ownership('hieroglyph', {
    loc_txt = {
        name = 'Hieroglyph',
        text = {
            '{C:attention}-#1#{} Ante,',
            '{C:red}-#1#{} discard',
            'each round',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    redeem = function(self, card)
        ease_ante(-card.ability.extra)
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - card.ability.extra
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra
        ease_discard(-card.ability.extra)
    end,
}, false)

SMODS.Voucher:take_ownership('petroglyph', {
    loc_txt = {
        name = 'Petroglyph',
        text = {
            '{C:attention}-#1#{} Ante,',
            '{C:blue}-#1#{} hand',
            'each round',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    redeem = function(self, card)
        ease_ante(-card.ability.extra)
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - card.ability.extra
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra
        ease_hands_played(-card.ability.extra)
    end,
}, false)
end -- REB4LANCED.config.hieroglyph_rework

-- Tarot Tycoon: every shop has a free Mega Arcana Pack
-- extra = 1 nullifies vanilla's tarot_rate boost (4*extra); our free pack replaces it.
if REB4LANCED.config.tarot_tycoon_enhanced then
SMODS.Voucher:take_ownership('tarot_tycoon', {
    config = { extra = 1 },
    loc_txt = {
        name = 'Tarot Tycoon',
        text = {
            'Every shop has',
            'an additional {C:attention}free{}',
            '{C:tarot}Mega Arcana Pack{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_arcana_mega_1
        return { vars = {} }
    end,
    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                local booster = SMODS.add_booster_to_shop('p_arcana_mega_' .. math.random(1, 2))
                booster.ability.couponed = true
                booster:set_cost()
                return true
            end
        }))
    end,
    calculate = function(self, card, context)
        if context.starting_shop then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local booster = SMODS.add_booster_to_shop('p_arcana_mega_' .. math.random(1, 2))
                    booster.ability.couponed = true
                    booster:set_cost()
                    return true
                end
            }))
        end
    end,
}, false)
end -- REB4LANCED.config.tarot_tycoon_enhanced

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

-- Illusion: playing cards in shop are clones of cards in your deck, and their
-- upgrades are rerolled while preserving copied ones if no new roll lands.
if REB4LANCED.config.illusion_enhanced then
SMODS.Voucher:take_ownership('illusion', {
    loc_txt = {
        name = 'Illusion',
        text = {
            '{C:attention}Playing cards{} in shop are',
            '{C:attention}clones{} of cards in your {C:attention}deck{},',
            'and their upgrades can be {C:attention}rerolled{}',
        },
    },
}, false)
end -- REB4LANCED.config.illusion_enhanced

-- Telescope: replace forced first-slot with 50% shop rate boost for most-played hand's planet
-- (Celestial packs made random in boosters.lua; shop boost in overrides.lua)
if REB4LANCED.config.telescope_enhanced then
SMODS.Voucher:take_ownership('telescope', {
    loc_txt = {
        name = 'Telescope',
        text = {
            '{C:planet}Planet{} cards in the {C:attention}shop{}',
            'have a {C:green}1{C:inactive} in {C:green}2{} chance',
            'to be your most played',
            '{C:attention}poker hand\'s{} planet',
        },
    },
}, false)
end -- REB4LANCED.config.telescope_enhanced

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

-- ── Fork Tag Vouchers ─────────────────────────────────────────────────────────
-- T1 Split Tags: when you skip a blind, choose 1 of 2 offered tags.
-- T2 Fork Tags : when you skip a blind, gain both tags (upgrades T1).
if REB4LANCED.config.fork_tag_vouchers then

SMODS.Voucher({
    key          = 'split_tag',
    atlas        = 'vouchers',
    pos          = { x = 0, y = 0 },
    cost         = 6,
    unlocked     = true,
    discovered   = false,
    available    = true,
    loc_txt = {
        name = 'Split Tags',
        text = {
            'When you {C:attention}skip{} a blind,',
            'choose {C:attention}1{} of {C:attention}3{} offered Tags',
        },
    },
})

SMODS.Voucher({
    key          = 'fork_tag',
    atlas        = 'vouchers',
    pos          = { x = 1, y = 0 },   -- placeholder sprite
    cost         = 8,
    unlocked     = true,
    discovered   = false,
    available    = true,
    requires     = { 'v_reb4l_split_tag' },
    loc_txt = {
        name = 'Fork Tags',
        text = {
            'When you {C:attention}skip{} a blind,',
            'choose {C:attention}2{} of {C:attention}3{} offered Tags',
        },
    },
})

end -- REB4LANCED.config.fork_tag_vouchers
