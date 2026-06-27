return function(REB4LANCED)
-- Paint Bucket: first scored card of the current suit each round
-- is converted into a Wild Card. The suit cycles each round.
if REB4LANCED.config.joker_set_stone then

local suits = { 'Spades', 'Hearts', 'Clubs', 'Diamonds' }

SMODS.Joker({
    key    = 'paint_bucket',
    atlas  = 'reb4l_jokers',
    pos    = { x = 2, y = 0 },
    unlocked         = true,
    discovered       = true,
    blueprint_compat = false,
    eternal_compat   = true,
    rarity = 2,
    cost   = 5,

    config = {
        extra = {
            current_suit = 'Spades',
            used_this_round = false,
        }
    },

    loc_txt = {
        name = 'Paint Bucket',
        text = {
            'First scored {V:1}#1#{} each',
            'round becomes a',
            '{C:attention}Wild Card{}',
            '{C:inactive}[#2#]{}',
        },
    },

    loc_vars = function(self, info_queue, card)
        local suit = card.ability.extra.current_suit or 'Spades'
        info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
        local status = card.ability.extra.used_this_round and 'Inactive' or 'Active'
        return { vars = { localize(suit, 'suits_plural'), status, colours = { G.C.SUITS[suit] } } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play
            and not card.debuff and not context.blueprint then
            local extra = card.ability.extra
            if not extra.used_this_round
                and context.other_card
                and context.other_card:is_suit(extra.current_suit)
                and not context.other_card.debuff then
                extra.used_this_round = true
                local target = context.other_card
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        target:set_ability(G.P_CENTERS.m_wild)
                        target:juice_up(0.5, 0.5)
                        return true
                    end
                }))
                return { message = 'Wild!', colour = G.C.GREEN }
            end
        end

        if context.end_of_round and not context.blueprint then
            local extra = card.ability.extra
            extra.used_this_round = false
            local idx = 1
            for i, s in ipairs(suits) do
                if s == extra.current_suit then idx = i; break end
            end
            extra.current_suit = suits[idx % #suits + 1]
        end
    end,
})
end -- REB4LANCED.config.joker_set_stone

end
