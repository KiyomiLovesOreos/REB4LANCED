return function(REB4LANCED)
if REB4LANCED.config.stakes_enhanced then
-- Gold Stake: adds Perishable Jokers (moved from Orange); 6 rounds instead of vanilla 5
SMODS.Stake:take_ownership('stake_gold', {
    loc_txt = {
        name = "Gold Stake",
        text = {
            "Shop can have {C:attention}Perishable{} Jokers",
            "{C:inactive,s:0.8}(Expires after {C:attention,s:0.8}6{C:inactive,s:0.8} rounds)",
        },
    },
    modifiers = function()
        G.GAME.modifiers.enable_perishables_in_shop = true
        if REB4LANCED.config.perishable_enhanced then
            G.GAME.perishable_rounds = 6
        end
    end,
}, true)

end
end
