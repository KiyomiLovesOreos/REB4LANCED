return function(REB4LANCED)
-- Golden Ticket: Uncommon, $5 per Gold Card scored (vanilla: Common, $4)
if REB4LANCED.config.ticket_enhanced then
SMODS.Joker:take_ownership('ticket', {
    rarity = 2,
    config = { extra = 5 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
}, false)
end

end
