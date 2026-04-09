return function(REB4LANCED)
-- Hit the Road: xmult_gain +0.75 per Jack (vanilla: +0.5); resets end of round; Jacks reshuffled into deck
-- REB4LANCED.htr_jacks is a shared table (accessible from overrides.lua) so the
-- draw_from_deck_to_hand wrapper can process it after cards reach G.discard.
REB4LANCED.htr_jacks = REB4LANCED.htr_jacks or {}
if REB4LANCED.config.hit_the_road_enhanced then
SMODS.Joker:take_ownership('hit_the_road', {
    config = { extra = { xmult_gain = 0.75, xmult = 1 } },
    loc_txt = {
        name = "Hit the Road",
        text = {
            "Gains {X:mult,C:white} X#1# {} Mult per",
            "{C:attention}Jack{} discarded,",
            "{C:attention}Jacks{} reshuffled into deck",
            "{C:inactive}Resets each round{}",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if not context.blueprint then
            if context.pre_discard and context.full_hand then
                for _, c in ipairs(context.full_hand) do
                    if not c.debuff and c:get_id() == 11 then
                        REB4LANCED.htr_jacks[c.unique_val or c] = c
                    end
                end
            end
            if context.discard and not context.other_card.debuff and context.other_card:get_id() == 11 then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
                return {
                    message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } },
                    colour = G.C.RED,
                    delay = 0.45
                }
            end
            if context.end_of_round and context.game_over == false and context.main_eval and card.ability.extra.xmult > 1 then
                card.ability.extra.xmult = 1
                return { message = localize('k_reset'), colour = G.C.RED }
            end
        end
        if context.joker_main then
            return { xmult = card.ability.extra.xmult }
        end
    end,
}, false)
end -- REB4LANCED.config.hit_the_road_enhanced

end
