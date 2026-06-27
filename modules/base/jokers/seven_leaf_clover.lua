return function(REB4LANCED)
-- Seven Leaf Clover: each scoring 7 boosts all probability numerators by +1.
-- Counts all 7s at once in context.before so every card gets full boost.
if REB4LANCED.config.joker_set_rank then

if JokerDisplay then
    JokerDisplay.Definitions["j_reb4l_seven_leaf_clover"] = {
        text = {
            { text = "+", scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = " odds", scale = 0.25 },
        },
        calc_function = function(card)
            card.joker_display_values.odds = G.GAME and G.GAME.reb4l_slc_odds or 0
        end,
    }
end

SMODS.Joker({
    key    = 'seven_leaf_clover',
    atlas  = 'reb4l_jokers',
    pos    = { x = 5, y = 0 },
    rarity = 1,
    cost   = 6,

    blueprint_compat = false,
    eternal_compat = true,

    config = {
        extra = {
            odds = 0,
        }
    },

    loc_txt = {
        name = 'Seven Leaf Clover',
        text = {
            'Before scoring, increases',
            'all odds by {C:green}+1{} per',
            '{C:attention}7{} in the played hand',
        },
    },

    loc_vars = function(self, info_queue, card)
        local boost = G.GAME and G.GAME.reb4l_slc_odds or 0
        return { vars = { boost } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local sevens = 0
            for _, c in ipairs(G.play.cards or {}) do
                if c:get_id() == 7 then sevens = sevens + 1 end
            end
            G.GAME.reb4l_slc_odds = card.debuff and 0 or sevens

            if sevens > 0 then
                return { message = '+' .. sevens, colour = G.C.GREEN }
            end
        end
        -- Clear after all scoring is done, deferred so probability checks
        -- during joker finalization still see the boost
        if context.final_scoring_step and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.0,
                func = function()
                    G.GAME.reb4l_slc_odds = nil
                    return true
                end
            }))
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
