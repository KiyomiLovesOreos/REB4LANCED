-- Only tarots that differ from vanilla get take_ownership.
-- All use SMODS.Consumable (the parent class for both Tarot and Spectral).
-- Keys use the vanilla identifier WITHOUT the 'c_' class prefix.
--
-- Enhancement tarots (c_empress, c_heirophant, c_lovers, c_chariot, c_justice, c_devil, c_tower):
--   config.max_highlighted: enhanced values always used when block is loaded.
--   The config field is all that's needed; SMODS handles the use/can_use logic automatically.
--   loc_vars updates card.ability.max_highlighted so it reflects the current config at display time.
--
-- Suit tarots (c_star, c_moon, c_sun, c_world):
--   config.max_highlighted: 4 when block is loaded.
--
-- c_wheel_of_fortune: full use + can_use override for configurable probability.

-- The Empress: enhances up to 3 cards to Mult Cards (vanilla: 2)
if REB4LANCED.config.tarot_enhance_enhanced then
SMODS.Consumable:take_ownership('empress', {
    config = { max_highlighted = 3, mod_conv = 'm_mult' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 3
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
}, false)

-- The Hierophant: enhances up to 3 cards to Bonus Cards (vanilla: 2)
SMODS.Consumable:take_ownership('heirophant', {
    config = { max_highlighted = 3, mod_conv = 'm_bonus' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 3
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
}, false)

-- The Chariot: enhances up to 2 cards to Steel Cards (vanilla: 1)
SMODS.Consumable:take_ownership('chariot', {
    config = { max_highlighted = 2, mod_conv = 'm_steel' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 2
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
}, false)

-- Justice: enhances up to 2 cards to Glass Cards (vanilla: 1)
SMODS.Consumable:take_ownership('justice', {
    config = { max_highlighted = 2, mod_conv = 'm_glass' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 2
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
}, false)

-- The Devil: enhances up to 2 cards to Gold Cards (vanilla: 1)
SMODS.Consumable:take_ownership('devil', {
    config = { max_highlighted = 2, mod_conv = 'm_gold' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 2
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
}, false)

-- The Tower: enhances up to 2 cards to Stone Cards (vanilla: 1)
SMODS.Consumable:take_ownership('tower', {
    config = { max_highlighted = 2, mod_conv = 'm_stone' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 2
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
}, false)

end -- REB4LANCED.config.tarot_enhance_enhanced

-- The Lovers: enhances up to 2 cards to Wild Cards (vanilla: 1)
if REB4LANCED.config.lovers_enhanced then
SMODS.Consumable:take_ownership('lovers', {
    config = { max_highlighted = 2, mod_conv = 'm_wild' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 2
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
}, false)
end -- REB4LANCED.config.lovers_enhanced

-- The Star: converts up to 4 cards to Diamonds (vanilla: 3)
if REB4LANCED.config.tarot_suit_enhanced then
SMODS.Consumable:take_ownership('star', {
    config = { max_highlighted = 4, suit_conv = 'Diamonds' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 4
        return { vars = { card.ability.max_highlighted, localize(card.ability.suit_conv, 'suits_plural'), colours = { G.C.SUITS[card.ability.suit_conv] } } }
    end,
}, false)

-- The Moon: converts up to 4 cards to Clubs (vanilla: 3)
SMODS.Consumable:take_ownership('moon', {
    config = { max_highlighted = 4, suit_conv = 'Clubs' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 4
        return { vars = { card.ability.max_highlighted, localize(card.ability.suit_conv, 'suits_plural'), colours = { G.C.SUITS[card.ability.suit_conv] } } }
    end,
}, false)

-- The Sun: converts up to 4 cards to Hearts (vanilla: 3)
SMODS.Consumable:take_ownership('sun', {
    config = { max_highlighted = 4, suit_conv = 'Hearts' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 4
        return { vars = { card.ability.max_highlighted, localize(card.ability.suit_conv, 'suits_plural'), colours = { G.C.SUITS[card.ability.suit_conv] } } }
    end,
}, false)

-- The World: converts up to 4 cards to Spades (vanilla: 3)
SMODS.Consumable:take_ownership('world', {
    config = { max_highlighted = 4, suit_conv = 'Spades' },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 4
        return { vars = { card.ability.max_highlighted, localize(card.ability.suit_conv, 'suits_plural'), colours = { G.C.SUITS[card.ability.suit_conv] } } }
    end,
}, false)

end -- REB4LANCED.config.tarot_suit_enhanced

-- The Wheel of Fortune: 1/3 chance to apply edition
SMODS.Consumable:take_ownership('wheel_of_fortune', {
    config = { extra = { odds = 3 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, 3, 'reb4l_wheel_of_fortune')
        return { vars = { numerator, denominator } }
    end,
    use = function(self, card, area, copier)
        if SMODS.pseudorandom_probability(card, 'reb4l_wheel_of_fortune', 1, 3) then
            local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
            local eligible_card = pseudorandom_element(editionless_jokers, 'reb4l_wheel_of_fortune')
            local edition = SMODS.poll_edition { key = "reb4l_wheel_of_fortune", guaranteed = true, no_negative = true, options = { 'e_polychrome', 'e_holo', 'e_foil' } }
            eligible_card:set_edition(edition, true)
            check_for_unlock({ type = 'have_edition' })
        else
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    attention_text({
                        text = localize('k_nope_ex'),
                        scale = 1.3,
                        hold = 1.4,
                        major = card,
                        backdrop_colour = G.C.SECONDARY_SET.Tarot,
                        align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and
                            'tm' or 'cm',
                        offset = { x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and -0.2 or 0 },
                        silent = true
                    })
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.06 * G.SETTINGS.GAMESPEED,
                        blockable = false,
                        blocking = false,
                        func = function()
                            play_sound('tarot2', 0.76, 0.4)
                            return true
                        end
                    }))
                    play_sound('tarot2', 1, 0.4)
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
    end,
    can_use = function(self, card)
        return next(SMODS.Edition:get_edition_cards(G.jokers, true))
    end,
}, false)
