return function(REB4LANCED)
-- Satellite: mode-selectable rework
-- Mode 1 (Vanilla): $1 per planet card used this run
-- Mode 2: earns $ceil(highest_hand_level / 2) at end of round
-- Mode 3: earns $1 per level immediately on any hand level-up; Blueprint/Brainstorm copyable
if REB4LANCED.config.satellite_mode == 2 then
SMODS.Joker:take_ownership('satellite', {
    loc_txt = {
        name = 'Satellite',
        text = {
            'Earn {C:money}$#1#{} at end of round for every',
            '{C:attention}2{} levels of your highest poker hand',
            '{C:inactive}(Currently {C:money}$#2#{C:inactive})',
        },
    },
    loc_vars = function(self, info_queue, card)
        local highest = 0
        for _, hand in pairs(G.GAME and G.GAME.hands or {}) do
            local lv = type(hand.level) == 'number' and hand.level
                or tonumber(tostring(hand.level)) or 0
            if lv > highest then highest = lv end
        end
        return { vars = { card.ability.extra, math.ceil(highest / 2) } }
    end,
    calc_dollar_bonus = function(self, card)
        if card.debuff then return end
        local highest = 0
        for _, hand in pairs(G.GAME.hands) do
            local lv = type(hand.level) == 'number' and hand.level
                or tonumber(tostring(hand.level)) or 0
            if lv > highest then highest = lv end
        end
        local amount = math.ceil(highest / 2)
        if amount > 0 then return amount end
    end,
}, false)
elseif REB4LANCED.config.satellite_mode == 3 then
SMODS.Joker:take_ownership('satellite', {
    loc_txt = {
        name = 'Satellite',
        text = {
            'Earns {C:money}$1{} each time any',
            '{C:planet}Poker Hand{} levels up',
            '{C:inactive}(Orbital Tag: {C:money}+$5{C:inactive})',
        },
    },
    calculate = function(self, card, context)
        if context.satellite_level_up and not card.debuff then
            local earn = context.levels or 1
            ease_dollars(earn)
            card:juice_up(0.3, 0.4)
            return { message = localize{type='variable', key='a_dollars', vars={earn}}, colour = G.C.MONEY }
        end
    end,
}, false)
end

end
