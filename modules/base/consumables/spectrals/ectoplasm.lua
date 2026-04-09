return function(REB4LANCED)
-- Ectoplasm: random -1 hands/discards/hand size
if REB4LANCED.config.ectoplasm_enhanced then
SMODS.Consumable:take_ownership('ectoplasm', {
    loc_txt = {
        name = 'Ectoplasm',
        text = {
            'Add {C:dark_edition}Negative{} to a random {C:attention}Joker{}',
            'Randomly apply {C:red}-1{} hand,',
            '{C:red}-1{} discard, or {C:red}-1{} hand size',
        },
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        return { vars = { "-1 hand, discard, or hand size" } }
    end,
    use = function(self, card, area, copier)
        if card.reb4l_used then return end
        card.reb4l_used = true
        local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                -- Build pool of options that still have room to be reduced (min 1).
                local options = {}
                if G.GAME.round_resets.hands > 1 then
                    options[#options + 1] = 1
                end
                if G.GAME.round_resets.discards > 1 then
                    options[#options + 1] = 2
                end
                if G.hand.config.card_limit > 1 then
                    options[#options + 1] = 3
                end
                if #options > 0 then
                    local roll = pseudorandom_element(options, pseudoseed('reb4l_ectoplasm'))
                    if roll == 1 then
                        G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
                        ease_hands_played(-1)
                    elseif roll == 2 then
                        G.GAME.round_resets.discards = G.GAME.round_resets.discards - 1
                        ease_discard(-1)
                    else
                        G.hand:change_size(-1)
                    end
                end
                if #editionless_jokers > 0 then
                    local eligible_card = pseudorandom_element(editionless_jokers, pseudoseed('ectoplasm'))
                    eligible_card:set_edition({ negative = true })
                end
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
    end,
    can_use = function(self, card)
        -- Usable if there's an editionless joker AND at least one thing to reduce.
        if not next(SMODS.Edition:get_edition_cards(G.jokers, true)) then return false end
        return G.GAME.round_resets.hands > 1
            or G.GAME.round_resets.discards > 1
            or G.hand.config.card_limit > 1
    end,
}, false)
end -- REB4LANCED.config.ectoplasm_enhanced
end
