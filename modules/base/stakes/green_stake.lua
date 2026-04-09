return function(REB4LANCED)
if REB4LANCED.config.stakes_enhanced then
SMODS.Stake:take_ownership('stake_green', {
    loc_txt = {
        name = "Green Stake",
        text = {
            "Shop can have {C:attention}Eternal{} Jokers",
            "{C:inactive,s:0.8}(Cannot be {C:attention,s:0.8}sold{C:inactive,s:0.8} or {C:attention,s:0.8}destroyed{C:inactive,s:0.8})",
        },
    },
    modifiers = function()
        G.GAME.modifiers.enable_eternals_in_shop = true
    end,
}, true)

end
end
