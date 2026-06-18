return function(REB4LANCED)
if not REB4LANCED.config.stakes_enhanced then return end

local mode = REB4LANCED.config.perishable_enhanced or 1

if mode == 1 then
    -- Vanilla: fix tooltip to show correct round count
    SMODS.Sticker:take_ownership('perishable', {
        loc_vars = function(self, info_queue, card)
            local rounds = (G.GAME and G.GAME.perishable_rounds) or 5
            return { vars = { rounds, card.ability.perish_tally or rounds } }
        end,
    }, true)
    return
end

-- Modes 2 (Wilting) and 3 (Sell Decay): text only.
-- All behaviour is handled in overrides.lua.
-- perishable_rounds is set to 999 in orange_stake so vanilla never fires.
SMODS.Sticker:take_ownership('perishable', {
    loc_txt = mode == 2 and {
        name = 'Perishable',
        text = {
            'This Joker {C:red}wilts{} over {C:attention}#2#{} hands,',
            'scoring weaker each hand played',
            'then is {C:red}destroyed{}',
            '{C:inactive}(Hand {C:attention}#1#{C:inactive}/{C:attention}#2#{C:inactive})',
        },
    } or {
        name = 'Perishable',
        text = {
            'Loses {C:money}$1{} sell value per round',
            'Destroyed when value reaches {C:money}$0{}',
            '{C:inactive}(Sell value: {C:money}$#1#{C:inactive})',
        },
    },
    loc_vars = function(self, info_queue, card)
        if mode == 2 then
            local mx    = (G.GAME and G.GAME.reb4l_wilt_max) or 10
            local tally = card.ability.reb4l_wilt_tally or 0
            return { vars = { tally + 1, mx } }
        else
            return { vars = { card.sell_cost or 0 } }
        end
    end,
}, true)

end
