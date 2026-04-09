return function(REB4LANCED)
if REB4LANCED.config.stakes_enhanced then
local reb4l_blue_stake_text = REB4LANCED.config.blue_stake_mode == 2 and {
    "{C:attention}Base reroll cost{} is",
    "{C:money}$2{} higher",
} or {
    "{C:attention}Interest{} is earned at",
    "{C:money}$1{} per {C:money}$7{} held",
}

SMODS.Stake:take_ownership('stake_blue', {
    loc_txt = {
        name = "Blue Stake",
        text = reb4l_blue_stake_text,
    },
    modifiers = function()
        if REB4LANCED.config.blue_stake_mode == 2 then
            G.GAME.modifiers.reb4l_base_reroll_cost_bonus =
                (G.GAME.modifiers.reb4l_base_reroll_cost_bonus or 0) + 2
        else
            G.GAME.interest_base = 7
        end
    end,
}, true)

end
end
