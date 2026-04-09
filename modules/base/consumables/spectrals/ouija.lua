return function(REB4LANCED)
-- Ouija: player selects 1 card to choose its rank (vanilla: random rank)
if REB4LANCED.config.sigil_ouija_enhanced then
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

end
