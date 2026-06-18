return function(REB4LANCED)

SMODS.Consumable({
    key   = 'axiom_03',
    set   = 'reb4l_Axiom',
    atlas = 'reb4l_axioms',
    pos   = { x = 2, y = 0 },
    cost  = 6,
    loc_txt = {
        name = 'Return',
        text = {
            'Add a random {C:attention}destroyed{}',
            'joker from this run as a',
            '{C:dark_edition}Negative{} copy',
            ' ',
            '{s:0.8}{C:inactive}A few steps backwards may{}',
            '{s:0.8}{C:inactive}keep you moving forwards.{}',
        },
    },
    can_use = function(self, card)
        local pool = G.GAME.reb4l_destroyed_jokers
        return pool and #pool > 0
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        local pool = G.GAME.reb4l_destroyed_jokers or {}
        local idx = math.max(1, math.ceil(pseudorandom(pseudoseed('reb4l_return')) * #pool))
        local key = pool[idx]

        if not key or not G.P_CENTERS[key] or G.P_CENTERS[key].set ~= 'Joker' then return end

        table.remove(pool, idx)

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
                local new_joker = create_card('Joker', G.jokers, nil, nil, true, false, key)
                new_joker:add_to_deck()
                new_joker:set_edition({ negative = true }, true)
                G.jokers:emplace(new_joker)
                new_joker:start_materialize()
                return true
            end
        }))

        delay(0.5)
    end,
})

end
