return function(REB4LANCED)
-- CEO: scored Aces have a 1 in 3 chance to earn $10.
if REB4LANCED.config.joker_set_rank then
SMODS.Joker({
    key    = 'ceo',
    atlas  = 'reb4l_jokers',
    pos    = { x = 3, y = 0 },
    unlocked         = true,
    discovered       = true,
    blueprint_compat = true,
    eternal_compat   = true,
    rarity = 2,
    cost   = 6,
    config = { extra = 10 },
    loc_txt = {
        name = 'CEO',
        text = {
            'Scored {C:attention}Aces{} have a',
            '{C:green}1 in 3{} chance to',
            'earn {C:money}$#1#{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play
            and context.other_card:get_id() == 14
            and pseudorandom('reb4l_ceo') < 1/3 then
            return {
                dollars = card.ability.extra,
                message = '+$' .. card.ability.extra,
                colour  = G.C.MONEY,
            }
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
