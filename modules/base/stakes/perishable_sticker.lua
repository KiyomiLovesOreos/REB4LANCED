return function(REB4LANCED)
if REB4LANCED.config.stakes_enhanced then
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
end
