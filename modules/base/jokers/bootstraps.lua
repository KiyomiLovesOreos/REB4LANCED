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

    if JokerDisplay then
        -- ─── Bootstraps ───────────────────────────────────────────────────────────────
        -- Now restricted to Hearts/Diamonds; +1 Mult per $5 (vanilla: +2 per $5, all suits).
        -- Display shows per-card mult for qualifying cards (correct ref paths unchanged).
        JokerDisplay.Definitions["j_bootstraps"] = {
            text = {
                { text = "+" },
                { ref_table = "card.joker_display_values", ref_value = "mult" },
            },
            text_config = { colour = G.C.MULT },
            calc_function = function(card)
                local extra = card.ability.extra
                local mult_per_card, dollars
                if type(extra) == "table" then
                    mult_per_card = extra.mult or 1
                    dollars = extra.dollars or 5
                else
                    mult_per_card = 2
                    dollars = extra or 2
                end
                local per_card = mult_per_card * math.floor(
                    math.max(0, (G.GAME and G.GAME.dollars or 0) + (G.GAME and G.GAME.dollar_buffer or 0)) / dollars
                )
                local total = 0
                if per_card > 0 then
                    local _, _, scoring_hand = JokerDisplay.evaluate_hand()
                    if scoring_hand then
                        for _, c in ipairs(scoring_hand) do
                            if c:is_suit('Hearts') or c:is_suit('Diamonds') then
                                total = total + per_card * JokerDisplay.calculate_card_triggers(c, scoring_hand)
                            end
                        end
                    end
                end
                card.joker_display_values.mult = total
            end,
        }
    end

end -- REB4LANCED.config.bootstraps_enhanced

end
