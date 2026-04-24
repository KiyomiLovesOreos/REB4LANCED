local loc = {
    misc = {
        variables = {
            a_discards = "+#1# Discard",
        },
    },
}

if REB4LANCED.config.stakes_enhanced then
    loc.descriptions = {
        Stake = {
            stake_red = {
                text = {
                    "All {C:attention}blind payouts{} reduced by {C:money}$1",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_green = {
                text = {
                    "Shop can have {C:attention}Eternal{} Jokers",
                    "{C:inactive,s:0.8}[Cannot be {C:attention,s:0.8}sold{} {C:inactive}or{} {C:attention,s:0.8}destroyed{}]",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_black = {
                text = {
                    "{C:attention}Interest{} is earned at",
                    "{C:money}$1{} per {C:money}$7{} held",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_blue = {
                text = {
                    "{C:attention}Base reroll cost{} is",
                    "{C:money}$2{} higher",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_purple = {
                text = (REB4LANCED.config.purple_stake_mode == 2) and {
                    "Shop can have {C:attention}Pinned{} Jokers",
                    "{C:inactive,s:0.8}(Cannot be {C:attention,s:0.8}moved {C:inactive,s:0.8}from the {C:attention,s:0.8}leftmost position{})",
                    "{s:0.8}Applies all previous Stakes",
                } or {
                    "{C:attention}Vouchers{} cost {C:money}$2{} more",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_orange = {
                text = (REB4LANCED.config.perishable_enhanced == 2) and {
                    "Shop can have {C:attention}Perishable{} Jokers",
                    "{C:inactive,s:0.8}(Wilts weaker each hand played)",
                    "{s:0.8}Applies all previous Stakes",
                } or (REB4LANCED.config.perishable_enhanced == 3) and {
                    "Shop can have {C:attention}Perishable{} Jokers",
                    "{C:inactive,s:0.8}(Loses sell value each round)",
                    "{s:0.8}Applies all previous Stakes",
                } or {
                    "Shop can have {C:attention}Perishable{} Jokers",
                    "{C:inactive,s:0.8}(Expires after {C:attention,s:0.8}5{C:inactive,s:0.8} rounds)",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_gold = {
                text = {
                    "Shop can have {C:attention}Rental{} Jokers",
                    "{C:inactive,s:0.8}(Costs {C:money,s:0.8}$3{C:inactive,s:0.8} per round)",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
        },
    }
end

return loc
