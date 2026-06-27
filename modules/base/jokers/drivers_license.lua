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

    if JokerDisplay then
        -- ─── Driver's License ─────────────────────────────────────────────────────────
        -- X4 Mult at 16 enhanced cards (vanilla: X3 at 16).
        JokerDisplay.Definitions["j_drivers_license"] = {
            text = {
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" },
                    },
                },
            },
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "count" },
                { text = "/" },
                { ref_table = "card.joker_display_values", ref_value = "threshold" },
                { text = ")", colour = G.C.UI.TEXT_INACTIVE },
            },
            calc_function = function(card)
                local count = 0
                for _, c in ipairs(G.playing_cards or {}) do
                    if c.config.center and c.config.center.set == "Enhanced" then
                        count = count + 1
                    end
                end
                local xmult = type(card.ability.extra) == "number" and card.ability.extra or 4
                card.joker_display_values.count     = count
                card.joker_display_values.threshold = 16
                card.joker_display_values.xmult     = count >= 16 and xmult or 1
            end,
            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children then
                    local count = card.joker_display_values.count or 0
                    local colour = count >= 16 and G.C.GREEN or G.C.UI.TEXT_INACTIVE
                    for _, child in ipairs(reminder_text.children) do
                        if child.config then child.config.colour = colour end
                    end
                end
            end,
        }
    end

end -- REB4LANCED.config.drivers_license_enhanced

end
