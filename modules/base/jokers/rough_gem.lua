return function(REB4LANCED)
-- Rough Gem: $2 per scoring Diamond (vanilla: $1)
if REB4LANCED.config.rough_gem_enhanced then
SMODS.Joker:take_ownership('rough_gem', {
    config = { extra = { dollars = 2 } },
    loc_txt = {
        name = 'Rough Gem',
        text = {
            'Played cards with',
            '{C:diamonds}Diamond{} suit earn',
            '{C:money}$#1#{} when scored',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,
}, false)
end -- REB4LANCED.config.rough_gem_enhanced

end
