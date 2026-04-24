return function(REB4LANCED)
-- Pocket Aces: if the scoring hand contains at least 2 Aces, earn $5.
if REB4LANCED.config.joker_set_rank then
SMODS.Joker({
    key    = 'pocket_aces',
    atlas  = 'reb4l_jokers',
    pos    = { x = 6, y = 0 },
    rarity = 1,
    cost   = 4,
    config = { extra = 5 },
    loc_txt = {
        name = 'Pocket Aces',
        text = {
            'If scoring hand contains',
            'a {C:attention}pair of Aces{},',
            'earn {C:money}$#1#{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and not context.blueprint then
            local ace_count = 0
            for _, c in ipairs(context.scoring_hand) do
                if c:get_id() == 14 and not c.debuff then
                    ace_count = ace_count + 1
                end
            end
            if ace_count >= 2 then
                return {
                    dollars = card.ability.extra,
                    message = '+$' .. card.ability.extra,
                    colour  = G.C.MONEY,
                }
            end
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
