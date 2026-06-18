return function(REB4LANCED)
-- Ace in the Hole: Aces of a rotating suit score X3 Mult on your last hand of the round.
-- The active suit is re-rolled each time a blind is selected.
if REB4LANCED.config.joker_set_rank then
SMODS.Joker({
    key    = 'ace_in_hole',
    atlas  = 'reb4l_jokers',
    pos    = { x = 0, y = 0 },
    unlocked         = true,
    discovered       = true,
    blueprint_compat = true,
    eternal_compat   = true,
    rarity = 3,
    cost   = 8,
    config = { extra = { suit = 'Spades' } },
    loc_txt = {
        name = 'Ace in the Hole',
        text = {
            '{C:attention}Aces{} of #1#',
            'score {X:mult,C:white} X3 {} Mult',
            'on your {C:attention}last hand{}',
            '{C:inactive}(Suit changes each blind)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local suit = card.ability.extra.suit or 'Spades'
        return { vars = { localize(suit, 'suits_plural') }, colours = { G.C.SUITS[suit] } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            local suits = { 'Spades', 'Hearts', 'Clubs', 'Diamonds' }
            card.ability.extra.suit = suits[math.ceil(pseudorandom('reb4l_aith_blind') * 4)]
            return {
                message = localize(card.ability.extra.suit, 'suits_plural'),
                colour  = G.C.SUITS[card.ability.extra.suit],
            }
        end
        if context.individual and context.cardarea == G.play
            and G.GAME.current_round.hands_left == 0
            and context.other_card:get_id() == 14
            and context.other_card:is_suit(card.ability.extra.suit) then
            return { xmult = 3 }
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
