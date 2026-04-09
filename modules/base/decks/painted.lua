return function(REB4LANCED)
-- Painted Deck: -1 hand or -1 discard per round instead of -1 joker slot (joker_size patched in patches.lua)
-- painted_mode: 1=Vanilla, 2=-1 Hand/Round, 3=-1 Discard/Round
if REB4LANCED.config.painted_mode and REB4LANCED.config.painted_mode > 1 then
SMODS.Back:take_ownership('painted', {
    loc_txt = {
        name = "Painted Deck",
        text = {
            "Start with {C:attention}+2{} hand size,",
            "{C:blue}-1{} {C:attention}#1#{} per round",
        },
    },
    loc_vars = function(self, info_queue)
        local mode = REB4LANCED.config.painted_mode or 2
        return { vars = { mode == 3 and 'discard' or 'hand' } }
    end,
    apply = function(self, back)
        local mode = REB4LANCED.config.painted_mode or 2
        if mode == 3 then
            G.GAME.round_resets.discards = G.GAME.round_resets.discards - 1
        else
            G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
        end
    end,
}, false)
end

end
