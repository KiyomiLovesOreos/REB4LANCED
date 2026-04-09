return function(REB4LANCED)
-- Constellation: gains X0.1 Mult on ANY hand level-up (planet card, Space Joker, Orbital Tag, Burnt Joker)
-- Xmult accumulation handled in overrides.lua level_up_hand; here we just apply joker_main
if REB4LANCED.config.constellation_enhanced then
SMODS.Joker:take_ownership('constellation', {
    config = { extra = 1, Xmult_mod = 0.1 },
    loc_txt = {
        name = 'Constellation',
        text = {
            'Gains {X:mult,C:white} X#1# {} Mult every time',
            'a {C:planet}Poker Hand{} levels up',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    loc_vars = function(self, info_queue, card)
        -- Migrate: vanilla table {Xmult=n,Xmult_mod=0.1} → our flat Xmult in extra
        if type(card.ability.extra) == 'table' then
            card.ability.Xmult_mod = card.ability.extra.Xmult_mod or 0.1
            card.ability.extra = card.ability.extra.Xmult or 1
        -- Migrate: last session stored increment (0.1) in extra, Xmult in x_mult
        elseif type(card.ability.extra) == 'number' and card.ability.extra < 0.5 then
            card.ability.Xmult_mod = card.ability.extra
            card.ability.extra = card.ability.x_mult or 1
        end
        card.ability.Xmult_mod = card.ability.Xmult_mod or 0.1
        return { vars = { card.ability.Xmult_mod, card.ability.extra or 1 } }
    end,
    calculate = function(self, card, context)
        -- Migrate: vanilla table {Xmult=n,Xmult_mod=0.1} → our flat Xmult in extra
        if type(card.ability.extra) == 'table' then
            card.ability.Xmult_mod = card.ability.extra.Xmult_mod or 0.1
            card.ability.extra = card.ability.extra.Xmult or 1
        -- Migrate: last session stored increment (0.1) in extra, Xmult in x_mult
        elseif type(card.ability.extra) == 'number' and card.ability.extra < 0.5 then
            card.ability.Xmult_mod = card.ability.extra
            card.ability.extra = card.ability.x_mult or 1
        end
        card.ability.Xmult_mod = card.ability.Xmult_mod or 0.1
        if context.joker_main then
            return { xmult = card.ability.extra }
        end
    end,
}, false)
end -- REB4LANCED.config.constellation_enhanced

end
