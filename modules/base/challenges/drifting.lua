-- REB4LANCED Challenge: Drifting
-- All joker values are randomized (0.25x–2x) once when acquired and hidden behind "?".

return function(REB4LANCED)
    SMODS.Challenge({
        key = "drifting",
        loc_txt = {
            name = "Drifting",
            text = {
                "All {C:attention}Joker{} values are",
                "{C:red}randomized{} {C:attention}0.25-2×{}",
                "and {C:inactive}hidden{}"
            }
        },
        deck = {
            type = "Challenge Deck",
        },
        rules = {
            custom = { { id = "reb4l_drifting" } },
        },
        unlocked = function(self) return true end,
        apply = function(self)
            if G.GAME then
                G.GAME.modifiers = G.GAME.modifiers or {}
                G.GAME.modifiers.reb4l_drifting_active = true
            end
        end,
        calculate = function(self, context) end,
    })
end
