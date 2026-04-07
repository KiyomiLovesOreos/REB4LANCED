local loc = {
    misc = {
        variables = {
            a_discards = "+#1# Discard",
        },
    },
}

if REB4LANCED.config.stakes_enhanced then
    local reb4l_blue_stake_text = REB4LANCED.config.blue_stake_mode == 2 and {
        "{C:attention}Base reroll cost{} is",
        "{C:money}$2{} higher",
        "{s:0.8}Applies all previous Stakes",
    } or {
        "{C:attention}Interest{} is earned at",
        "{C:money}$1{} per {C:money}$7{} held",
        "{s:0.8}Applies all previous Stakes",
    }
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
                    "{C:attention}Reroll{} cost scales by",
                    "{C:money}$2{} per reroll instead of {C:money}$1",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_blue = {
                text = reb4l_blue_stake_text,
            },
            stake_purple = {
                text = {
                    "{C:attention}Showdown{} Boss Blinds every {C:attention}4{} Antes",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_orange = {
                text = {
                    "Shop can have {C:attention}Rental{} Jokers",
                    "{C:inactive,s:0.8}(Costs {C:money,s:0.8}$3{C:inactive,s:0.8} per round)",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
            stake_gold = {
                text = {
                    "Shop can have {C:attention}Perishable{} Jokers",
                    "{C:inactive,s:0.8}(Expires after {C:attention,s:0.8}6{C:inactive,s:0.8} rounds)",
                    "{s:0.8}Applies all previous Stakes",
                },
            },
        },
    }
end

return loc
