return function(REB4LANCED)
-- ─── The Idol ────────────────────────────────────────────────────────────────
-- Mode 1/2: reb4l_idol_card mirrors vanilla idol_card (rotating each round).
-- Mode 3: per-card fixed rank/suit stored in card.ability.reb4l_idol_rank/suit/id.
JokerDisplay.Definitions["j_idol"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" },
            },
        },
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "idol_card", colour = G.C.FILTER },
        { text = ")" },
    },
    calc_function = function(card)
        local idol
        if REB4LANCED.config.idol_mode == 3 and card.ability.reb4l_idol_rank then
            idol = {
                rank = card.ability.reb4l_idol_rank,
                suit = card.ability.reb4l_idol_suit,
                id   = card.ability.reb4l_idol_id,
            }
        else
            idol = (G.GAME and G.GAME.current_round and G.GAME.current_round.reb4l_idol_card)
                or { rank = "Ace", suit = "Spades", id = 14 }
        end
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card:is_suit(idol.suit) and scoring_card:get_id() and
                   scoring_card:get_id() == idol.id then
                    count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                end
            end
        end
        local xmult = type(card.ability.extra) == "number" and card.ability.extra or 2
        card.joker_display_values.x_mult = xmult ^ count
        card.joker_display_values.idol_card = localize {
            type = "variable", key = "jdis_rank_of_suit",
            vars = { localize(idol.rank, "ranks"), localize(idol.suit, "suits_plural") },
        }
    end,
    style_function = function(card, text, reminder_text, extra)
        local suit
        if REB4LANCED.config.idol_mode == 3 and card.ability.reb4l_idol_suit then
            suit = card.ability.reb4l_idol_suit
        else
            local idol = G.GAME and G.GAME.current_round and G.GAME.current_round.reb4l_idol_card
            suit = idol and idol.suit or "Spades"
        end
        if reminder_text and reminder_text.children and reminder_text.children[2] then
            reminder_text.children[2].config.colour = lighten(G.C.SUITS[suit], 0.35)
        end
    end,
}

end
