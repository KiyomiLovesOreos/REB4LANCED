return function(REB4LANCED)
-- Superposition: generates The Fool if straight + ace in full played hand (Four Fingers synergy)
if REB4LANCED.config.superposition_enhanced then
SMODS.Joker:take_ownership('superposition', {
    loc_txt = {
        name = 'Superposition',
        text = {
            'If {C:attention}played hand{} contains',
            'a {C:attention}Straight{} and an {C:attention}Ace{},',
            'create {C:tarot}The Fool{}',
            '{C:inactive}(if room)',
        },
    },
    calculate = function(self, card, context)
        if context.joker_main and context.scoring_name == 'Straight' then
            local has_ace = false
            for i = 1, #G.play.cards do
                if G.play.cards[i]:get_id() == 14 then
                    has_ace = true
                    break
                end
            end
            if has_ace and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local fool = SMODS.add_card({ key = 'c_fool', key_append = 'reb4l_superposition' })
                        G.GAME.consumeable_buffer = 0
                        if fool then fool:juice_up(0.3, 0.5) end
                        return true
                    end
                }))
                return { message = localize('k_plus_tarot') }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.superposition_enhanced

end
