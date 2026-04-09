return function(REB4LANCED)
-- Rocket: starts at $2, +$2 per boss (vanilla: $1, +$2)
if REB4LANCED.config.rocket_enhanced then
SMODS.Joker:take_ownership('rocket', {
    config = { extra = { dollars = 2, increase = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.increase } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and context.beat_boss then
            card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.increase
            return { message = localize('k_upgrade_ex'), colour = G.C.MONEY }
        end
    end,
    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end,
}, false)
end

end
