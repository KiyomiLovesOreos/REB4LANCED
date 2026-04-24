return function(REB4LANCED)
if REB4LANCED.config.stakes_enhanced then

SMODS.Stake:take_ownership('stake_blue', {
    loc_txt = {
        name = "Blue Stake",
        text = {
            "{C:attention}Base reroll cost{} is",
            "{C:money}$2{} higher",
        },
    },
    modifiers = function()
        G.GAME.modifiers.reb4l_base_reroll_cost_bonus =
            (G.GAME.modifiers.reb4l_base_reroll_cost_bonus or 0) + 2
    end,
}, true)

end
end
