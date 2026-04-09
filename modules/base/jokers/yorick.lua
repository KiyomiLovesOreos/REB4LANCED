return function(REB4LANCED)
-- Yorick: retriggers all played cards N times; N starts at 1, +1 every 23 hands played
if REB4LANCED.config.yorick_enhanced then
SMODS.Joker:take_ownership('yorick', {
    loc_txt = {
        name = 'Yorick',
        text = {
            'Retriggers all {C:attention}played cards{}',
            '{C:attention}#1#{} time(s)',
            '{C:inactive}(+1 retrigger every {C:attention}23{}{C:inactive} hands){}',
            '{C:inactive}(Next in {C:attention}#2#{C:inactive} hands)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local played = G.GAME and G.GAME.hands_played or 0
        local retriggers = 1 + math.floor(played / 23)
        local next_in = 23 - (played % 23)
        return { vars = { retriggers, next_in } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local played = G.GAME and G.GAME.hands_played or 0
            local retriggers = 1 + math.floor(played / 23)
            return { repetitions = retriggers }
        end
    end,
}, false)
end -- REB4LANCED.config.yorick_enhanced

end
