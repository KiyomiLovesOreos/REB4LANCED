return function(REB4LANCED)
-- Nine Circles: scored 9s give Xmult; Xmult grows by 0.25 after each boss blind defeated.
if REB4LANCED.config.joker_set_rank then
SMODS.Joker({
    key    = 'nine_circles',
    atlas  = 'reb4l_jokers',
    pos    = { x = 4, y = 0 },
    rarity = 3,
    cost   = 8,
    config = { extra = { xmult = 1.25 } },
    loc_txt = {
        name = 'Nine Circles',
        text = {
            'Scored {C:attention}9s{} give',
            '{X:mult,C:white} X#1# {} Mult',
            '{C:mult}+0.25{} Xmult per boss beaten',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { string.format('%.2f', card.ability.extra.xmult) } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play
            and context.other_card:get_id() == 9 then
            return { xmult = card.ability.extra.xmult }
        end
        if context.end_of_round and context.game_over == false
            and context.main_eval and not context.blueprint
            and G.GAME.blind and G.GAME.blind.boss then
            card.ability.extra.xmult = card.ability.extra.xmult + 0.25
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } },
                colour  = G.C.MULT,
            }
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
