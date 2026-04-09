return function(REB4LANCED)
-- The Wheel of Fortune: 1/3 chance to apply edition
if REB4LANCED.config.wheel_of_fortune_enhanced then
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
end -- REB4LANCED.config.wheel_of_fortune_enhanced
end
