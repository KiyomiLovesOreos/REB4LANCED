return function(REB4LANCED)
if REB4LANCED.config.stakes_enhanced then
SMODS.Stake:take_ownership('stake_black', {
    loc_txt = {
        name = "Black Stake",
        text = {
            "{C:attention}Reroll{} cost scales by",
            "{C:money}$2{} per reroll instead of {C:money}$1",
        },
    },
    modifiers = function()
        G.GAME.modifiers.reb4l_reroll_scale = 2
    end,
}, true)

end
end
