-- Only the 3 spectrals that differ from vanilla get take_ownership.
-- Keys use the vanilla identifier WITHOUT the 'c_' class prefix.

-- Sigil: player selects 1 card to choose its suit (vanilla: random suit)
if REB4LANCED.config.sigil_ouija_enhanced then
SMODS.Consumable:take_ownership('sigil', {
    config = { max_highlighted = 1 },
    loc_txt = {
        name = "Sigil",
        text = {
            "Converts all {C:attention}cards{}",
            "in hand to {C:attention}#1#{} suit",
        },
    },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 1
        return { vars = { "highlighted card's" } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        local reference = G.hand.highlighted and G.hand.highlighted[1]
        local _suit = SMODS.Suits[reference.base.suit]
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.4,
            func = function() play_sound('tarot1'); used_tarot:juice_up(0.3, 0.5); return true end
        }))
        for i = 1, #G.hand.cards do
            local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip(); play_sound('card1', percent)
                    G.hand.cards[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({
                func = function() assert(SMODS.change_base(G.hand.cards[i], _suit.key)); return true end
            }))
        end
        for i = 1, #G.hand.cards do
            local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip(); play_sound('tarot2', percent, 0.6)
                    G.hand.cards[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted == 1
    end,
}, false)

-- Ouija: player selects 1 card to choose its rank (vanilla: random rank)
SMODS.Consumable:take_ownership('ouija', {
    config = { max_highlighted = 1 },
    loc_txt = {
        name = "Ouija",
        text = {
            "Converts all {C:attention}cards{}",
            "in hand to {C:attention}#1#{} rank",
            "{C:inactive}(-1 Hand Size)",
        },
    },
    loc_vars = function(self, info_queue, card)
        card.ability.max_highlighted = 1
        return { vars = { "highlighted card's" } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        local reference = G.hand.highlighted and G.hand.highlighted[1]
        local _rank = SMODS.Ranks[reference.base.value]
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.4,
            func = function() play_sound('tarot1'); used_tarot:juice_up(0.3, 0.5); return true end
        }))
        for i = 1, #G.hand.cards do
            local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip(); play_sound('card1', percent)
                    G.hand.cards[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({
                func = function() assert(SMODS.change_base(G.hand.cards[i], nil, _rank.key)); return true end
            }))
        end
        for i = 1, #G.hand.cards do
            local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip(); play_sound('tarot2', percent, 0.6)
                    G.hand.cards[i]:juice_up(0.3, 0.3); return true
                end
            }))
        end
        G.hand:change_size(-1)
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted == 1
    end,
}, false)

end -- REB4LANCED.config.sigil_ouija_enhanced

-- Ectoplasm: random -1 hands/discards/hand size
SMODS.Consumable:take_ownership('ectoplasm', {
    loc_txt = {
        name = 'Ectoplasm',
        text = {
            'Add {C:dark_edition}Negative{} to a random {C:attention}Joker{}',
            'Randomly apply {C:red}-1{} hand,',
            '{C:red}-1{} discard, or {C:red}-1{} hand size',
        },
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        return { vars = { "-1 hand, discard, or hand size" } }
    end,
    use = function(self, card, area, copier)
        if card.reb4l_used then return end
        card.reb4l_used = true
        local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                local roll = math.floor(pseudorandom('reb4l_ectoplasm') * 3) + 1
                if roll == 1 then
                    G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
                    ease_hands_played(-1)
                elseif roll == 2 then
                    G.GAME.round_resets.discards = G.GAME.round_resets.discards - 1
                    ease_discard(-1)
                else
                    G.hand:change_size(-1)
                end
                if #editionless_jokers > 0 then
                    local eligible_card = pseudorandom_element(editionless_jokers, 'ectoplasm')
                    eligible_card:set_edition({ negative = true })
                end
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
    end,
    can_use = function(self, card)
        return next(SMODS.Edition:get_edition_cards(G.jokers, true))
    end,
}, false)
