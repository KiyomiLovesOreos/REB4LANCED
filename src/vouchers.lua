-- Hieroglyph: -1 Ante + -1 Discard (vanilla: -1 Ante + -1 Hand)
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

-- Petroglyph: -1 Ante + -1 Hand (vanilla: -1 Ante + -1 Discard)
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

-- Tarot Tycoon: every shop has a free Mega Arcana Pack
SMODS.Voucher:take_ownership('tarot_tycoon', {
    config = {},
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

-- Planet Tycoon: each planet card in shop has a 1/odds chance to be Negative (odds configurable)
SMODS.Voucher:take_ownership('planet_tycoon', {
    config = { extra = { odds = 2 } },
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
        return { vars = { (card.ability.extra and card.ability.extra.odds) or 2 } }
    end,
    update = function(self, card, dt)
        if G.shop_jokers and G.shop_jokers.cards then
            for _, v in ipairs(G.shop_jokers.cards) do
                if v.ability.set == 'Planet' and not v.tycooned then
                    v.tycooned = true
                    local odds = (card.ability.extra and card.ability.extra.odds) or 2
                    if pseudorandom(pseudoseed('planet_tycoon_' .. v.sort_id)) < 1 / odds then
                        v:set_edition('e_negative', true)
                    end
                end
            end
        end
    end,
}, false)

-- Magic Trick: playing cards in shop may appear with enhancements, editions, or seals
-- (behavior in overrides.lua create_card_for_shop)
SMODS.Voucher:take_ownership('magic_trick', {
    loc_txt = {
        name = 'Magic Trick',
        text = {
            '{C:attention}Playing cards{} can',
            'be purchased from the {C:attention}shop{}',
            'and may have {C:attention}enhancements{},',
            '{C:dark_edition}editions{}, or {C:attention}seals',
        },
    },
}, false)

-- Illusion: playing cards in shop are clones of cards in your deck
-- (behavior in overrides.lua create_card_for_shop; no upgrade rerolls)
SMODS.Voucher:take_ownership('illusion', {
    loc_txt = {
        name = 'Illusion',
        text = {
            '{C:attention}Playing cards{} in shop',
            'are {C:attention}clones{} of cards',
            'in your {C:attention}deck',
        },
    },
}, false)

-- Telescope: replace forced first-slot with 50% shop rate boost for most-played hand's planet
-- (Celestial packs made random in boosters.lua; shop boost in overrides.lua)
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

-- Observatory: X2 Mult per Planet card used (vanilla: X1.5)
SMODS.Voucher:take_ownership('observatory', {
    config = { extra = { Xmult = 2 } },
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
        return { vars = { card.ability.extra.Xmult } }
    end,
}, false)
