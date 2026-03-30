if REB4LANCED.config.red_stake_enhanced then
SMODS.Stake:take_ownership('stake_red', {
    loc_txt = {
        name = "Red Stake",
        text = {
            "All {C:attention}blind payouts{} reduced by {C:money}$1",
        },
    },
    modifiers = function()
        G.GAME.modifiers.reb4l_payout_decrease = (G.GAME.modifiers.reb4l_payout_decrease or 0) + 1
    end,
}, true)
end

if REB4LANCED.config.green_stake_enhanced then
SMODS.Stake:take_ownership('stake_green', {
    loc_txt = {
        name = "Green Stake",
        text = {
            "Shop can have {C:attention}Eternal{} Jokers",
            "{C:inactive,s:0.8}(Cannot be {C:attention,s:0.8}sold{C:inactive,s:0.8} or {C:attention,s:0.8}destroyed{C:inactive,s:0.8})",
        },
    },
    modifiers = function()
        G.GAME.modifiers.enable_eternal_stickerbox_in_shop = true
    end,
}, true)
end

if REB4LANCED.config.black_stake_enhanced then
SMODS.Stake:take_ownership('stake_black', {
    loc_txt = {
        name = "Black Stake",
        text = {
            "{C:attention}Discarded{} cards are",
            "reshuffled into your {C:attention}deck",
        },
    },
    modifiers = function()
        -- effect handled in overrides.lua Card.discard hook
    end,
}, true)
end

SMODS.Stake:take_ownership('stake_blue', {
    loc_txt = {
        name = "Blue Stake",
        text = {
            "+2 wine ante",
        },
    },
    modifiers = function()
        G.GAME.win_ante = G.GAME.win_ante + 2
    end,
}, true)

-- Purple Stake: adds Perishable Jokers (moved from vanilla Orange Stake)
if REB4LANCED.config.purple_stake_enhanced then
SMODS.Stake:take_ownership('stake_purple', {
    loc_txt = {
        name = "Purple Stake",
        text = {
            "Shop can have {C:attention}Perishable{} Jokers",
            "{C:inactive,s:0.8}(Expires after {C:attention,s:0.8}5{C:inactive,s:0.8} rounds)",
        },
    },
    modifiers = function()
        G.GAME.modifiers.enable_perishables_in_shop = true
    end,
}, true)
end

if REB4LANCED.config.orange_stake_enhanced then
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

SMODS.Stake:take_ownership('stake_gold', {
    loc_txt = {
        name = "Gold Stake",
        text = {
            "{C:attention}Showdown{} Boss Blinds every {C:attention}5{} Antes",
        },
    },
    modifiers = function()
        G.GAME.modifiers.showdown_interval = 5
    end,
}, true)
