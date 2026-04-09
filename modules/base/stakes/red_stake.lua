return function(REB4LANCED)
if REB4LANCED.config.stakes_enhanced then
SMODS.Stake:take_ownership('stake_red', {
    loc_txt = {
        name = "Red Stake",
        text = {
            "All {C:attention}blind payouts{} reduced by {C:money}$1",
        },
    },
    modifiers = function()
        -- Suppress vanilla Red Stake's "Small Blind gives no reward" effect
        if G.GAME.modifiers.no_blind_reward then
            G.GAME.modifiers.no_blind_reward.Small = nil
        end
        G.GAME.modifiers.reb4l_payout_decrease = 1
    end,
}, true)

end
end
