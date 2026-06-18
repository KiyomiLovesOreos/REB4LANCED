return function(REB4LANCED)
if REB4LANCED.config.stakes_enhanced then
SMODS.Stake:take_ownership('stake_black', {
    loc_txt = {
        name = "Black Stake",
        text = {
            "{C:attention}Interest{} is earned at",
            "{C:money}$1{} per {C:money}$7{} held",
        },
    },
    modifiers = function()
        G.GAME.interest_base = 7
    end,
}, true)

end
end
