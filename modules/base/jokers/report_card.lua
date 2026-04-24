return function(REB4LANCED)
-- Report Card: retrigger all Aces once (both played and held in hand).
if REB4LANCED.config.joker_set_rank then
SMODS.Joker({
    key    = 'report_card',
    atlas  = 'reb4l_jokers',
    pos    = { x = 1, y = 0 },
    unlocked         = true,
    discovered       = true,
    blueprint_compat = true,
    eternal_compat   = true,
    rarity = 2,
    cost   = 6,
    config = {},
    loc_txt = {
        name = 'Report Card',
        text = {
            'Retrigger all {C:attention}Aces{} once',
            '{C:inactive}(played and held in hand)',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.other_card:get_id() == 14 then
            return { repetitions = 1 }
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
