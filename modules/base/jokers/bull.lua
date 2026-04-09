return function(REB4LANCED)
-- Bull: scoring Spades/Clubs cards give +1 Chip per $5 (vanilla: +1 Chip per $1, no suit restriction)
-- Note: vanilla card.lua does arithmetic on card.ability.extra directly (expects a number),
-- so we don't touch config and hardcode our values instead.
if REB4LANCED.config.bull_enhanced then
SMODS.Joker:take_ownership('bull', {
    loc_txt = {
        name = 'Bull',
        text = {
            'Scoring {C:spades}Spades{} and {C:clubs}Clubs{}',
            'cards give {C:chips}+#1#{} Chips',
            'for every {C:money}$#2#{} you have',
            '{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local current = 3 * math.floor(((G.GAME and G.GAME.dollars or 0) + (G.GAME and G.GAME.dollar_buffer or 0)) / 5)
        return { vars = { 3, 5, current } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
            (context.other_card:is_suit('Spades') or context.other_card:is_suit('Clubs')) then
            local chips = 3 * math.floor(((G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)) / 5)
            if chips > 0 then
                return { chips = chips }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.bull_enhanced

end
