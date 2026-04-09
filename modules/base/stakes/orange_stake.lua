return function(REB4LANCED)
if REB4LANCED.config.stakes_enhanced then
-- Orange Stake: adds Rental Jokers (moved from Purple)
SMODS.Stake:take_ownership('stake_orange', {
    loc_txt = {
        name = "Orange Stake",
        text = {
            "Shop can have {C:attention}Rental{} Jokers",
            "{C:inactive,s:0.8}(Costs {C:money,s:0.8}$3{C:inactive,s:0.8} per round)",
        },
    },
    modifiers = function()
        G.GAME.modifiers.enable_rentals_in_shop = true
    end,
}, true)

end
end
