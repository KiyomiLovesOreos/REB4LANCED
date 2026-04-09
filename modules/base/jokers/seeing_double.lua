return function(REB4LANCED)
-- We block vanilla's joker_main dispatch (return nil, true) and apply xmult per individual card.
-- Vanilla's calculate_joker checks obj.calculate first; returning a truthy second value prevents
-- the vanilla branch from running while producing no effect itself.
if REB4LANCED.config.seeing_double_enhanced then
SMODS.Joker:take_ownership('seeing_double', {
    config = { extra = 1.25 },
    loc_txt = {
        name = 'Seeing Double',
        text = {
            'Each scoring card gives',
            '{X:mult,C:white} X#1# {} Mult if',
            '{C:attention}played hand{} contains a',
            '{C:clubs}Club{} and one other suit',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return nil, true  -- block vanilla's joker_main dispatch; we handle this in individual
        end
        if context.individual and context.cardarea == G.play then
            if not card.debuff and #context.scoring_hand >= 2
                and SMODS.seeing_double_check(context.scoring_hand, 'Clubs') then
                return { xmult = card.ability.extra }
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)
end -- REB4LANCED.config.seeing_double_enhanced

end
