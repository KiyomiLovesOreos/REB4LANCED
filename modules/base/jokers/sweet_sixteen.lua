return function(REB4LANCED)
-- Sweet Sixteen: if scoring hand contains a 10 and a 6, all scored cards give $1.
if REB4LANCED.config.joker_set_rank then
SMODS.Joker({
    key    = 'sweet_sixteen',
    atlas  = 'reb4l_jokers',
    pos    = { x = 9, y = 0 },
    rarity = 1,
    cost   = 4,
    config = { extra = { active = false, dollars = 1 } },
    loc_txt = {
        name = 'Sweet Sixteen',
        text = {
            'If scoring hand contains a {C:attention}10{} and a {C:attention}6{},',
            'all scored cards give {C:money}$#1#{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local has_ten, has_six = false, false
            for _, c in ipairs(context.scoring_hand) do
                if not c.debuff then
                    local id = c:get_id()
                    if id == 10 then has_ten = true end
                    if id == 6  then has_six  = true end
                end
            end
            card.ability.extra.active = has_ten and has_six
        end
        if context.individual and context.cardarea == G.play
            and card.ability.extra.active then
            return {
                dollars = card.ability.extra.dollars,
                message = '+$' .. card.ability.extra.dollars,
                colour  = G.C.MONEY,
            }
        end
        if context.after and not context.blueprint then
            card.ability.extra.active = false
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
