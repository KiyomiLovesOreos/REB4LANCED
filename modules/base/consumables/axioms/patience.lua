return function(REB4LANCED)

SMODS.Consumable({
    key   = 'axiom_02',
    set   = 'reb4l_Axiom',
    atlas = 'reb4l_axioms',
    pos   = { x = 1, y = 0 },
    cost  = 6,
    loc_txt = {
        name = 'Patience',
        text = {
            'If this blind is beaten with',
            '{C:attention}2{C:inactive}+{} hands remaining,',
            'gain {C:money}$10{} and {C:chips}level up{}',
            'the {C:attention}scoring hand{}',
        },
    },
    can_use = function(self, card)
        return G.GAME.facing_blind and not G.GAME.reb4l_patience_active
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
                G.GAME.reb4l_patience_active = true
                return true
            end
        }))
        delay(0.5)
    end,
})

end
