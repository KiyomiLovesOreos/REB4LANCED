return function(REB4LANCED)
if REB4LANCED.config.joker_set_suit then

local reb4l_prism_has_any_suit = SMODS.has_any_suit
function SMODS.has_any_suit(card)
    if card.base and card.base.value == '7' and G.jokers then
        for _, j in ipairs(G.jokers.cards) do
            if j.config.center.key == 'j_reb4l_prism' and not j.debuff then
                return true
            end
        end
    end
    return reb4l_prism_has_any_suit(card)
end

SMODS.Joker({
    key    = 'prism',
    atlas  = 'reb4l_jokers',
    pos    = { x = 13, y = 0 },
    rarity = 3,
    cost   = 10,
    loc_txt = {
        name = 'Prism',
        text = {
            '{C:attention}7s{} count as {C:attention}Wild Cards{}',
            'Scored {C:attention}Wild Cards{}',
            'retrigger adjacent scoring cards',
        },
    },
    -- loc_vars = function(self, info_queue, card)
    --     info_queue[#info_queue + 1] = reb4l_credit({ { 'Art', 'Solaskies', HEX('a0d8ef') } })
    --     return {}
    -- end,
    calculate = function(self, card, context)
        local function adjacent_wild(other_card, hand)
            if not hand or other_card.debuff then return false end
            local idx
            for i, c in ipairs(hand) do
                if c == other_card then idx = i; break end
            end
            if not idx then return false end
            local function is_wild(c) return not c.debuff and SMODS.has_any_suit(c) end
            local left  = idx > 1     and hand[idx - 1]
            local right = idx < #hand and hand[idx + 1]
            return (left and is_wild(left)) or (right and is_wild(right))
        end

        if context.repetition and context.cardarea == G.play then
            if adjacent_wild(context.other_card, context.scoring_hand) then
                return { message = localize('k_again_ex'), repetitions = 1, card = card }
            end
        end

        if context.retrigger_joker_check and not context.retrigger_joker
            and context.other_context and context.other_context.cardarea == G.play then
            if adjacent_wild(context.other_card, context.other_context.scoring_hand) then
                return { repetitions = 1, card = card }
            end
        end
    end,
})

end -- REB4LANCED.config.joker_set_suit
end
