return function(REB4LANCED)
-- Seven Leaf Clover: if the played hand contains at least one scoring 7,
-- all scoring cards count as Lucky Cards for this hand.
if REB4LANCED.config.joker_set_rank then
SMODS.Joker({
    key    = 'seven_leaf_clover',
    atlas  = 'reb4l_jokers',
    pos    = { x = 5, y = 0 },
    rarity = 1,
    cost   = 4,
    config = {},
    loc_txt = {
        name = 'Seven Leaf Clover',
        text = {
            'If hand contains a scoring {C:attention}7{},',
            'all cards count as {C:attention}Lucky Cards{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local has_seven = false
            for _, c in ipairs(context.scoring_hand) do
                if c:get_id() == 7 and not c.debuff then
                    has_seven = true
                    break
                end
            end
            if has_seven then
                for _, c in ipairs(context.scoring_hand) do
                    c.reb4l_slc = true
                    if SMODS.enh_cache and SMODS.enh_cache.write then
                        SMODS.enh_cache:write(c, nil)
                    end
                end
            end
        end
        if context.check_enhancement and context.other_card.reb4l_slc then
            return { m_lucky = true }
        end
        if context.after then
            for _, c in ipairs(context.scoring_hand) do
                c.reb4l_slc = nil
            end
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
