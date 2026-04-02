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

SMODS.Stake:take_ownership('stake_blue', {
    loc_txt = {
        name = "Blue Stake",
        text = {
            "{C:attention}Interest{} is earned at",
            "{C:money}$1{} per {C:money}$7{} held",
        },
    },
    modifiers = function()
        G.GAME.interest_base = 7
    end,
}, true)

-- Purple Stake: adds Rental Jokers (swapped with Orange)
SMODS.Stake:take_ownership('stake_purple', {
    loc_txt = {
        name = "Purple Stake",
        text = {
            "Shop can have {C:attention}Rental{} Jokers",
            "{C:inactive,s:0.8}(Costs {C:money,s:0.8}$3{C:inactive,s:0.8} per round)",
        },
    },
    modifiers = function()
        G.GAME.modifiers.enable_rentals_in_shop = true
    end,
}, true)

-- Orange Stake: adds Perishable Jokers (swapped with Purple); 6 rounds instead of vanilla 5
SMODS.Stake:take_ownership('stake_orange', {
    loc_txt = {
        name = "Orange Stake",
        text = {
            "Shop can have {C:attention}Perishable{} Jokers",
            "{C:inactive,s:0.8}(Expires after {C:attention,s:0.8}6{C:inactive,s:0.8} rounds)",
        },
    },
    modifiers = function()
        G.GAME.modifiers.enable_perishables_in_shop = true
        G.GAME.perishable_rounds = 6
    end,
}, true)

SMODS.Stake:take_ownership('stake_gold', {
    loc_txt = {
        name = "Gold Stake",
        text = {
            "{C:attention}Showdown{} Boss Blinds every {C:attention}4{} Antes",
        },
    },
    modifiers = function()
        G.GAME.modifiers.showdown_interval = 4
    end,
}, true)

-- Perishable sticker: fix loc_vars to read G.GAME.perishable_rounds so the
-- tooltip shows the correct max (6 on Orange stake, 5 on vanilla).
-- SMODS defaults to card.ability.perishable_rounds or 5 which ignores our change.
SMODS.Sticker:take_ownership('perishable', {
    loc_vars = function(self, info_queue, card)
        local rounds = (G.GAME and G.GAME.perishable_rounds) or 5
        return { vars = { rounds, card.ability.perish_tally or rounds } }
    end,
}, true)

end -- REB4LANCED.config.stakes_enhanced
