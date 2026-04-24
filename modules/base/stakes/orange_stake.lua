return function(REB4LANCED)
if REB4LANCED.config.stakes_enhanced then
local mode = REB4LANCED.config.perishable_enhanced or 1
local perish_hint =
    mode == 2 and "{C:inactive,s:0.8}(Wilts weaker each hand played)" or
    mode == 3 and "{C:inactive,s:0.8}(Loses sell value each round)" or
                  "{C:inactive,s:0.8}(Expires after {C:attention,s:0.8}5{C:inactive,s:0.8} rounds)"

SMODS.Stake:take_ownership('stake_orange', {
    loc_txt = {
        name = "Orange Stake",
        text = {
            "Shop can have {C:attention}Perishable{} Jokers",
            perish_hint,
        },
    },
    modifiers = function()
        G.GAME.modifiers.enable_perishables_in_shop = true
        local pmode = REB4LANCED.config.perishable_enhanced or 1
        if pmode == 2 or pmode == 3 then
            G.GAME.perishable_rounds = 999  -- suppress vanilla countdown; our hooks handle decay
        end
        if pmode == 2 then
            G.GAME.reb4l_wilt_max = 10
        end
    end,
}, true)

end
end
