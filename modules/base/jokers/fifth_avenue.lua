return function(REB4LANCED)
-- Fifth Avenue: scored 5s give +15 Chips and +2 Mult.
if REB4LANCED.config.joker_set_rank then
SMODS.Joker({
    key    = 'fifth_avenue',
    atlas  = 'reb4l_jokers',
    pos    = { x = 7, y = 0 },
    rarity = 2,
    cost   = 5,
    config = { extra = { chips = 15, mult = 2 } },
    loc_txt = {
        name = 'Fifth Avenue',
        text = {
            'Scored {C:attention}5s{} give',
            '{C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play
            and context.other_card:get_id() == 5 then
            return { chips = card.ability.extra.chips, mult = card.ability.extra.mult }
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
