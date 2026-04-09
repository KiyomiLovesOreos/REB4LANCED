return function(REB4LANCED)
-- Driver's License: X4 Mult at 16 enhanced cards (vanilla: X3 at 16)
if REB4LANCED.config.drivers_license_enhanced then
SMODS.Joker:take_ownership('drivers_license', {
    config = { extra = 4 },
    loc_txt = {
        name = "Driver's License",
        text = {
            'If you have atleast {C:attention}16{} Enhanced',
            'cards in your full deck,',
            '{X:mult,C:white} X#1# {} Mult',
            '{C:inactive}(Currently {C:attention}#2#{C:inactive} Enhanced)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local enhanced_count = 0
        for _, c in ipairs(G.playing_cards or {}) do
            if c.config.center.set == 'Enhanced' then
                enhanced_count = enhanced_count + 1
            end
        end
        return { vars = { card.ability.extra, enhanced_count } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local enhanced_count = 0
            for _, c in ipairs(G.playing_cards or {}) do
                if c.config.center.set == 'Enhanced' then
                    enhanced_count = enhanced_count + 1
                end
            end
            if enhanced_count >= 16 and not card.debuff then
                return { xmult = card.ability.extra }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.drivers_license_enhanced

end
