return function(REB4LANCED)
-- Paint Bucket: Stone Cards count as all suits.
-- The suit-check override is in hooks/overrides.lua (Card:is_suit).
if REB4LANCED.config.joker_set_stone then
SMODS.Joker({
    key    = 'paint_bucket',
    atlas  = 'reb4l_jokers',
    pos    = { x = 2, y = 0 },
    unlocked         = true,
    discovered       = true,
    blueprint_compat = false,
    eternal_compat   = true,
    rarity = 3,
    cost   = 8,
    config = {},
    loc_txt = {
        name = 'Paint Bucket',
        text = {
            '{C:attention}Stone Cards{}',
            'count as {C:attention}all suits',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
})
end -- REB4LANCED.config.joker_set_stone

end
