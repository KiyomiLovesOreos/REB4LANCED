return function(REB4LANCED)

SMODS.Consumable({
    key   = 'axiom_01',
    set   = 'reb4l_Axiom',
    atlas = 'reb4l_axioms',
    pos   = { x = 0, y = 0 },
    cost  = 6,
    loc_txt = {
        name = 'Observe',
        text = {
            'See the top {C:purple}+3{} cards',
            'of your deck for the',
            'rest of this blind',
            ' ',
            '{s:0.8}{C:inactive}The solution to a problem{}',
            '{s:0.8}{C:inactive}may just require a more{}',
            '{s:0.8}{C:inactive}thorough look at it.{}',
        },
    },
    can_use = function(self, card)
        return G.GAME.facing_blind
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.scry_amount  = (G.GAME.scry_amount  or 0) + 3
                G.GAME.reb4l_tmp_scry = (G.GAME.reb4l_tmp_scry or 0) + 3
                return true
            end
        }))
        delay(0.5)
    end,
})

end
