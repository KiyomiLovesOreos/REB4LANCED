return function(REB4LANCED)
-- Onyx Agate: +14 Mult per scoring Club (vanilla: +9)
if REB4LANCED.config.onyx_agate_enhanced then
SMODS.Joker:take_ownership('onyx_agate', {
    config = { extra = { mult = 14 } },
    loc_txt = {
        name = 'Onyx Agate',
        text = {
            'Played cards with',
            '{C:clubs}Club{} suit give',
            '{C:mult}+#1#{} Mult when scored',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
}, false)
end -- REB4LANCED.config.onyx_agate_enhanced

end
