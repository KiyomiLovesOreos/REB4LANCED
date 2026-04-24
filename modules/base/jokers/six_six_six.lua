return function(REB4LANCED)
-- 666: played 6s retrigger 2 times.
if REB4LANCED.config.joker_set_rank then
SMODS.Joker({
    key    = '666',
    atlas  = 'reb4l_jokers',
    pos    = { x = 10, y = 0 },
    rarity = 1,
    cost   = 4,
    config = {},
    loc_txt = {
        name = '666',
        text = {
            'Played {C:attention}6s{} retrigger',
            '{C:attention}2{} times',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.repetition and not context.blueprint
            and context.cardarea == G.play
            and context.other_card:get_id() == 6 then
            return { repetitions = 2 }
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
