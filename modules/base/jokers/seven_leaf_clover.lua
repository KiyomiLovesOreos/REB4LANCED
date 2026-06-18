return function(REB4LANCED)
-- Seven Leaf Clover: if the played hand contains at least one scoring 7,
-- all scoring cards count as Lucky Cards for this hand.
if REB4LANCED.config.joker_set_rank then
SMODS.Joker({
    key    = 'seven_leaf_clover',
    atlas  = 'reb4l_jokers',
    pos    = { x = 5, y = 0 },
    rarity = 1,
    cost   = 6,
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
                local lucky = G.P_CENTERS.m_lucky
                for _, c in ipairs(context.scoring_hand) do
                    c.reb4l_slc          = true
                    c.reb4l_slc_effect   = c.ability.effect
                    c.reb4l_slc_mult     = c.ability.mult
                    c.reb4l_slc_pdollars = c.ability.p_dollars
                    c.ability.effect     = 'Lucky Card'
                    c.ability.mult       = lucky and lucky.config.mult     or 20
                    c.ability.p_dollars  = lucky and lucky.config.p_dollars or 20
                end
            end
        end

        if context.after then
            for _, c in ipairs(context.scoring_hand) do
                if c.reb4l_slc then
                    c.ability.effect    = c.reb4l_slc_effect
                    c.ability.mult      = c.reb4l_slc_mult
                    c.ability.p_dollars = c.reb4l_slc_pdollars
                    c.reb4l_slc          = nil
                    c.reb4l_slc_effect   = nil
                    c.reb4l_slc_mult     = nil
                    c.reb4l_slc_pdollars = nil
                end
            end
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
