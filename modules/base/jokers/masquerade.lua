return function(REB4LANCED)
-- Masquerade: retriggers all scored cards of the current suit; suit rotates each blind.
if REB4LANCED.config.joker_set_suit then
local SUITS = { 'Spades', 'Hearts', 'Clubs', 'Diamonds' }
SMODS.Joker({
    key    = 'masquerade',
    atlas  = 'reb4l_jokers',
    pos    = { x = 12, y = 0 },
    rarity = 2,
    cost   = 6,
    config = { extra = { suit_index = 1 } },
    loc_txt = {
        name = 'Masquerade',
        text = {
            'Retriggers all scored',
            '{C:attention}#1#{} cards',
            '{C:inactive}(Suit changes each Blind)',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { SUITS[card.ability.extra.suit_index] } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local suit = SUITS[card.ability.extra.suit_index]
            if context.other_card:is_suit(suit) and not context.other_card.debuff then
                return { repetitions = 1 }
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval
            and not context.blueprint then
            card.ability.extra.suit_index = (card.ability.extra.suit_index % 4) + 1
            return {
                message = SUITS[card.ability.extra.suit_index],
                colour  = G.C.FILTER,
            }
        end
    end,
})
end -- REB4LANCED.config.joker_set_suit

end
