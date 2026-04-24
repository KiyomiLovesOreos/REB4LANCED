return function(REB4LANCED)

SMODS.Consumable({
    key   = 'axiom_05',
    set   = 'reb4l_Axiom',
    atlas = 'reb4l_axioms',
    pos   = { x = 4, y = 0 },
    cost  = 6,
    loc_txt = {
        name = 'Persist',
        text = {
            '{C:attention}1st use{C:inactive} (in blind){}:',
            'Snapshot current {C:attention}hands left{}',
            '{C:attention}2nd use{}: set {C:attention}discards{}',
            'to that amount, {C:attention}hands{} to {C:attention}1{}',
            '{C:inactive}(#1# saved){}',
            ' ',
            '{s:0.8}{C:inactive}If you never stop trying,{}',
            '{s:0.8}{C:inactive}you will get there eventually.{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.reb4l_persist_saved or '?' } }
    end,
    keep_on_use = function(self, card)
        return not card.ability.reb4l_persist_saved
    end,
    can_use = function(self, card)
        if card.ability.reb4l_persist_saved then
            return true
        end
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
        if not card.ability.reb4l_persist_saved then
            G.E_MANAGER:add_event(Event({
                func = function()
                    card.ability.reb4l_persist_saved = G.GAME.current_round.hands_left
                    return true
                end
            }))
        else
            local saved = card.ability.reb4l_persist_saved
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.current_round.discards_left = saved
                    G.GAME.current_round.hands_left = 1
                    return true
                end
            }))
        end
        delay(0.5)
    end,
})

end
