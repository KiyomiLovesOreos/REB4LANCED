return function(REB4LANCED)

SMODS.Consumable({
    key    = 'axiom_04',
    set    = 'reb4l_Axiom',
    atlas  = 'reb4l_axioms',
    pos    = { x = 3, y = 0 },
    cost   = 6,
    config = { max_highlighted = 1 },
    loc_txt = {
        name = 'Reframe',
        text = {
            'Randomize the {C:attention}suit{},',
            '{C:attention}rank{}, {C:green}enhancement{},',
            '{C:mult}edition{}, and {C:attention}seal{}',
            'of {C:attention}1{} selected card',
            ' ',
            '{s:0.8}{C:inactive}How we perceive a problem{}',
            '{s:0.8}{C:inactive}can change every time we see it.{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 1
        return {}
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        local target = G.hand.highlighted[1]

        local suit_pool = {}
        for _, s in pairs(SMODS.Suits) do suit_pool[#suit_pool + 1] = s end

        local rank_pool = {}
        for _, r in pairs(SMODS.Ranks) do rank_pool[#rank_pool + 1] = r end

        local enh_pool = { 'none' }
        for k, v in pairs(G.P_CENTERS) do
            if v.set == 'Enhanced' then enh_pool[#enh_pool + 1] = k end
        end

        local ed_pool = { 'none' }
        for k, v in pairs(G.P_CENTERS) do
            if v.set == 'Edition' and k ~= 'e_base' then ed_pool[#ed_pool + 1] = k end
        end

        local seal_pool = { 'none' }
        for k, _ in pairs(SMODS.Seals) do seal_pool[#seal_pool + 1] = k end

        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.4,
            func = function()
                play_sound('tarot1')
                used_card:juice_up(0.3, 0.5)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.1,
            func = function()
                target:flip()
                play_sound('card1', 0.9)
                target:juice_up(0.3, 0.3)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            func = function()
                local new_suit = pseudorandom_element(suit_pool, pseudoseed('reb4l_reframe_suit'))
                local new_rank = pseudorandom_element(rank_pool, pseudoseed('reb4l_reframe_rank'))
                local new_enh  = pseudorandom_element(enh_pool,  pseudoseed('reb4l_reframe_enh'))
                local new_ed   = pseudorandom_element(ed_pool,   pseudoseed('reb4l_reframe_ed'))
                local new_seal = pseudorandom_element(seal_pool, pseudoseed('reb4l_reframe_seal'))

                assert(SMODS.change_base(target, new_suit.key, new_rank.key))

                if new_enh == 'none' then
                    target:set_ability(G.P_CENTERS.c_base, nil, true)
                else
                    target:set_ability(G.P_CENTERS[new_enh], nil, true)
                end

                target:set_edition(new_ed ~= 'none' and new_ed or nil, true, true)
                target:set_seal(new_seal ~= 'none' and new_seal or nil, true, true)

                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.2,
            func = function()
                target:flip()
                play_sound('tarot2', 0.9, 0.6)
                target:juice_up(0.3, 0.3)
                return true
            end
        }))

        delay(0.5)
    end,
})

end
