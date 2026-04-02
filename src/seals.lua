-- Blue Seal: probability scales with last played hand size (hand_size/5 chance)
-- e.g. Pair=2/5, Two Pair=4/5, Flush=5/5 (guaranteed)
if REB4LANCED.config.blue_seal_enhanced then
SMODS.Seal:take_ownership('Blue', {
    config = { extra = { odds = 5 } },
    loc_txt = {
        name = 'Blue Seal',
        text = {
            '{C:green}#1#{C:inactive}/{C:green}#2#{} chance to create',
            'the {C:planet}Planet{} card for the',
            '{C:attention}last hand played{}',
            '{C:inactive}(#1# = cards in played hand)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local selected = G.hand and G.hand.highlighted and #G.hand.highlighted or 0
        return { vars = { selected, self.config.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.initial_scoring_step and context.scoring_hand then
            -- Capture both size and hand type at scoring time so end-of-round
            -- always uses the hand that was actually just scored
            G.GAME.reb4l_blue_seal_size = #context.scoring_hand
            G.GAME.reb4l_blue_seal_hand = G.GAME.last_hand_played
        end
        if context.playing_card_end_of_round and context.cardarea == G.hand
            and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            local seal = card.ability.seal
            local hand_size = G.GAME.reb4l_blue_seal_size or 0
            local hand_type = G.GAME.reb4l_blue_seal_hand
            if hand_type and pseudorandom(pseudoseed('blue_seal')) < hand_size / seal.extra.odds then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = function()
                        local _planet = nil
                        for _, v in pairs(G.P_CENTER_POOLS.Planet) do
                            if v.config.hand_type == hand_type then
                                _planet = v.key
                            end
                        end
                        if _planet then SMODS.add_card({ key = _planet }) end
                        G.GAME.consumeable_buffer = 0
                        return true
                    end
                }))
                return { message = localize('k_plus_planet'), colour = G.C.SECONDARY_SET.Planet }
            end
        end
    end,
}, false)
end
