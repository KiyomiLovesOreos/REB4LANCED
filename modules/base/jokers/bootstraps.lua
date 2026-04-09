return function(REB4LANCED)
-- Bootstraps: scoring Hearts/Diamonds cards give +1 Mult per $5 (vanilla: +2 Mult per $5, no suit restriction)
if REB4LANCED.config.bootstraps_enhanced then
SMODS.Joker:take_ownership('bootstraps', {
    config = { extra = { mult = 1, dollars = 5 } },
    loc_txt = {
        name = 'Bootstraps',
        text = {
            'Scoring {C:hearts}Hearts{} and {C:diamonds}Diamonds{}',
            'cards give {C:mult}+#1#{} Mult',
            'for every {C:money}$#2#{} you have',
            '{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local current = card.ability.extra.mult *
            math.floor(((G.GAME and G.GAME.dollars or 0) + (G.GAME and G.GAME.dollar_buffer or 0)) /
                card.ability.extra.dollars)
        return { vars = { card.ability.extra.mult, card.ability.extra.dollars, current } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
            (context.other_card:is_suit('Hearts') or context.other_card:is_suit('Diamonds')) then
            local mult = card.ability.extra.mult *
                math.floor(((G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)) / card.ability.extra.dollars)
            if mult > 0 then
                return { mult = mult }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.bootstraps_enhanced

end
