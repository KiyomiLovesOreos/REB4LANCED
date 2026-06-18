return function(REB4LANCED)
-- Oops! No Sixes: doubles listed probability denominators (inverse of Oops! All 6s).
-- Logic handled via SMODS.get_probability_vars override in modules/base/hooks/overrides.lua
if REB4LANCED.config.oops_no_sixes_enhanced then
SMODS.Joker({
    key    = 'oops_no_sixes',
    atlas  = 'reb4l_jokers',
    pos    = { x = 14, y = 0 },
    rarity = 3,
    cost   = 8,
    blueprint_compat = true,
    eternal_compat   = true,
    loc_txt = {
        name = 'Oops! No Sixes',
        text = {
            'All listed probabilities',
            'have {C:attention}double{} denominators',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    -- calculate removed; handled globally
})
end -- REB4LANCED.config.oops_no_sixes_enhanced

end
