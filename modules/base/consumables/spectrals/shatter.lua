return function(REB4LANCED)
if not REB4LANCED.config.spectral_set_sell_value then return end

SMODS.Consumable({
    key   = 'shatter',
    set   = 'Spectral',
    atlas = 'reb4l_spectrals',
    pos   = { x = 0, y = 0 },
    cost  = 4,
    config = {},
    loc_txt = {
        name = 'Shatter',
        text = {
            'Destroy a selected {C:attention}Joker{}',
            'Cards held in hand permanently gain',
            '{X:mult,C:white}X#1#{} Mult when scored',
            '{C:inactive,s:0.8}({C:money,s:0.8}$1 {C:inactive,s:0.8}sell value {C:inactive,s:0.8}= {C:mult,s:0.8}+0.05{C:inactive,s:0.8} XMult)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local target = nil
        if G.CONTROLLER and G.CONTROLLER.HID and G.CONTROLLER.HID.controller then
            target = G.jokers and G.jokers.cards and G.jokers.cards[#G.jokers.cards]
        else
            target = G.jokers and G.jokers.highlighted and G.jokers.highlighted[1]
        end
        local val = target and string.format("%.2f", (target.sell_cost or 0) * 0.05) or '0'
        return { vars = { val } }
    end,
    can_use = function(self, card)
        if G.CONTROLLER and G.CONTROLLER.HID and G.CONTROLLER.HID.controller then
            return G.jokers and #G.jokers.cards >= 1
                and not SMODS.is_eternal(G.jokers.cards[#G.jokers.cards], card)
        end
        return G.jokers and #G.jokers.highlighted == 1
            and not SMODS.is_eternal(G.jokers.highlighted[1], card)
    end,
    use = function(self, card, area, copier)
        local target = nil
        if G.CONTROLLER and G.CONTROLLER.HID and G.CONTROLLER.HID.controller then
            target = G.jokers and G.jokers.cards[#G.jokers.cards]
        else
            target = G.jokers and G.jokers.highlighted[1]
        end
        if not target then return end
        local bonus = (target.sell_cost or 0) * 0.05
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                for _, c in ipairs(G.hand.cards) do
                    c.ability.perma_x_mult = (c.ability.perma_x_mult or 0) + bonus
                end
                SMODS.destroy_cards(target)
                return true
            end,
        }))
    end,
})

end
