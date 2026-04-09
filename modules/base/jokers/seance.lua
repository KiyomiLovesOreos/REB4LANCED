return function(REB4LANCED)
-- Séance: same trigger, but creates a Negative Spectral (no consumable slot used)
if REB4LANCED.config.seance_enhanced then
SMODS.Joker:take_ownership('seance', {
    loc_txt = {
        name = 'Séance',
        text = {
            'If played hand is a {C:attention}#1#{},',
            'create a {C:dark_edition}Negative{} {C:spectral}Spectral{} card',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { localize(card.ability.extra.poker_hand, 'poker_hands') } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and context.scoring_name == card.ability.extra.poker_hand then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            return {
                extra = {
                    message = localize('k_plus_spectral'),
                    message_card = card,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local c = SMODS.add_card({ set = 'Spectral', key_append = 'reb4l_seance' })
                                if c then c:set_edition('e_negative', true) end
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                    end
                }
            }
        end
    end,
}, false)
end -- REB4LANCED.config.seance_enhanced

end
