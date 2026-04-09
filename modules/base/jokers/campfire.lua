return function(REB4LANCED)
-- Campfire: gains X0.1 Mult per card sold; loses X0.25 Mult after each blind defeated
-- Vanilla: gains xmult based on sell value; loses ALL xmult after boss blind
if REB4LANCED.config.campfire_enhanced then
SMODS.Joker:take_ownership('campfire', {
    config = { extra = { xmult = 1, xmult_gain = 0.1, xmult_loss = 0.25 } },
    loc_txt = {
        name = 'Campfire',
        text = {
            'Gains {X:mult,C:white} X#1# {} Mult for each',
            '{C:attention}card{} sold',
            'Loses {X:mult,C:white} X#2# {} Mult after',
            'each {C:attention}Blind{} is defeated',
            '{C:inactive}(Currently {X:mult,C:white} X#3# {C:inactive} Mult)',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.xmult_gain,
            card.ability.extra.xmult_loss,
            string.format('%.2f', card.ability.extra.xmult),
        } }
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card ~= card and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } },
                colour = G.C.MULT,
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval
            and not context.blueprint and card.ability.extra.xmult > 1 then
            card.ability.extra.xmult = math.max(1, card.ability.extra.xmult - card.ability.extra.xmult_loss)
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } },
                colour = G.C.MULT,
            }
        end
        if context.joker_main and card.ability.extra.xmult > 1 then
            return { xmult = card.ability.extra.xmult }
        end
    end,
}, false)
end -- REB4LANCED.config.campfire_enhanced

end
