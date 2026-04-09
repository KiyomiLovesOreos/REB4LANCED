return function(REB4LANCED)
-- Flower Pot: each scoring Wild Card gives +15 Chips (stacking per wild)
if REB4LANCED.config.flower_pot_enhanced then
SMODS.Joker:take_ownership('flower_pot', {
    config = { extra = 15 },
    loc_txt = {
        name = 'Flower Pot',
        text = {
            'scored {C:attention}Wild Card{}',
            'give {C:chips}+#1#{} Chips per',
            '{C:attention}Wild Card{} in played hand',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return nil, true  -- block vanilla's all-suits X3 dispatch; we handle chips in individual
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_wild' then
                local wild_count = 0
                for _, c in ipairs(context.scoring_hand) do
                    if c.config.center.key == 'm_wild' then wild_count = wild_count + 1 end
                end
                return { chips = card.ability.extra * wild_count }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.flower_pot_enhanced

end
