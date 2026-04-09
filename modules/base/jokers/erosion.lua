return function(REB4LANCED)
-- Erosion: X0.15 Mult for every card below 52 in deck (vanilla: +4 Mult per card below starting size)
if REB4LANCED.config.erosion_enhanced then
SMODS.Joker:take_ownership('erosion', {
    loc_txt = {
        name = 'Erosion',
        text = {
            '{X:mult,C:white} X#1# {} Mult for every',
            'card below {C:attention}52{} in your deck',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local missing = math.max(0, 52 - (G.playing_cards and #G.playing_cards or 52))
        local current = 1 + 0.15 * missing
        return { vars = { 0.15, string.format("%.2f", current) } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local missing = math.max(0, 52 - #G.playing_cards)
            if missing > 0 then
                return { xmult = 1 + 0.15 * missing }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.erosion_enhanced

end
