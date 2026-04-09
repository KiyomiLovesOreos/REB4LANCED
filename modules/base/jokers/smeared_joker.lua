return function(REB4LANCED)
-- Smeared Joker: add description note that suit-based boss debuffs are also ignored
-- (behavior is implemented in overrides.lua Card:is_suit)
if REB4LANCED.config.smeared_enhanced then
SMODS.Joker:take_ownership('smeared', {
    loc_txt = {
        name = 'Smeared Joker',
        text = {
            '{C:hearts}Hearts{} and {C:diamonds}Diamonds',
            'count as the same suit,',
            '{C:spades}Spades{} and {C:clubs}Clubs',
            'count as the same suit.',
            '{C:inactive}All cards ignore suit-based',
            '{C:inactive}Boss Blind debuffs',
        },
    },
}, false)
end

end
