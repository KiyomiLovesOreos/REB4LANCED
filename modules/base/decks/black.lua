return function(REB4LANCED)
-- Black Deck: start at Ante 0 (keeps vanilla -1 hand, +1 joker slot)
if REB4LANCED.config.black_deck_enhanced then
SMODS.Back:take_ownership('black', {
    loc_txt = {
        name = "Black Deck",
        text = {
            "Start at {C:attention}Ante 0{},",
            "{C:red}-1{} Hand, {C:attention}+1{} Joker slot",
        },
    },
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
    apply = function(self, back)
        G.GAME.modifiers.reb4l_start_ante_zero = true
    end,
}, false)
end

end
