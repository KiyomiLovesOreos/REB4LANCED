return function(REB4LANCED)
-- Four Corners: scored 4s act as Wild Cards.
if REB4LANCED.config.joker_set_rank then
SMODS.Joker({
    key    = 'four_corners',
    atlas  = 'reb4l_jokers',
    pos    = { x = 11, y = 0 },
    rarity = 1,
    cost   = 4,
    config = {},
    loc_txt = {
        name = 'Four Corners',
        text = {
            'Scored {C:attention}4s{} act as',
            '{C:attention}Wild Cards{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            for _, c in ipairs(context.scoring_hand) do
                if c:get_id() == 4 and not c.debuff then
                    c.reb4l_fc = true
                    if SMODS.enh_cache and SMODS.enh_cache.write then
                        SMODS.enh_cache:write(c, nil)
                    end
                end
            end
        end
        if context.check_enhancement and context.other_card.reb4l_fc then
            return { m_wild = true }
        end
        if context.after then
            for _, c in ipairs(context.scoring_hand) do
                c.reb4l_fc = nil
            end
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
