return function(REB4LANCED)
if REB4LANCED.config.stakes_enhanced then
-- Purple Stake: Showdown Boss Blinds every 4 Antes (moved from Gold)
SMODS.Stake:take_ownership('stake_purple', {
    loc_txt = {
        name = "Purple Stake",
        text = {
            "{C:attention}Showdown{} Boss Blinds every {C:attention}4{} Antes",
        },
    },
    modifiers = function()
        G.GAME.modifiers.showdown_interval = 4
    end,
}, true)

end
end
