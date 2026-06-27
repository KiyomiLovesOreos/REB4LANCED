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

    if JokerDisplay then
        -- ─── Yorick ───────────────────────────────────────────────────────────────────
        -- Completely reworked: retriggers all played cards N times where
        -- N = 1 + floor(hands_played / 23).  Vanilla tracked discards to upgrade.
        JokerDisplay.Definitions["j_yorick"] = {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "retriggers", retrigger_type = "mult" },
            },
            text_config = { colour = G.C.ORANGE },
            reminder_text = {
                { text = "(next in ",                              colour = G.C.UI.TEXT_INACTIVE },
                { ref_table = "card.joker_display_values", ref_value = "next_in" },
                { text = ")",                                      colour = G.C.UI.TEXT_INACTIVE },
            },
            calc_function = function(card)
                local played = G.GAME and G.GAME.hands_played or 0
                card.joker_display_values.retriggers = 1 + math.floor(played / 23)
                card.joker_display_values.next_in    = 23 - (played % 23)
            end,
            retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
                if held_in_hand then return 0 end
                local played = G.GAME and G.GAME.hands_played or 0
                local retriggers = 1 + math.floor(played / 23)
                return retriggers * JokerDisplay.calculate_joker_triggers(joker_card)
            end,
        }
    end

end -- REB4LANCED.config.yorick_enhanced

end
