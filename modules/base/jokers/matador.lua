return function(REB4LANCED)
-- Matador: $5 every hand played in any blind (vanilla: $8 when playing boss blind's required hand)
-- Cost patched in src/patches.lua
if REB4LANCED.config.matador_enhanced then
SMODS.Joker:take_ownership('matador', {
    config = { extra = 5 },
    loc_txt = {
        name = 'Matador',
        text = {
            'Earn {C:money}$#1#{} every time',
            'a {C:attention}hand{} is played',
            'during a {C:attention}Boss Blind{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calculate = function(self, card, context)
        if context.after and G.GAME.blind and G.GAME.blind.boss then
            return {
                dollars = card.ability.extra,
                message = localize { type = 'variable', key = 'a_dollars', vars = { card.ability.extra } },
                colour = G.C.MONEY,
            }
        end
    end,
}, false)

    if JokerDisplay then
        -- ─── Matador ──────────────────────────────────────────────────────────────────
        -- Now earns $5 on EVERY hand played during a boss blind (vanilla: $8 only when
        -- playing the required hand of the boss blind).
        JokerDisplay.Definitions["j_matador"] = {
            text = {
                { text = "+$" },
                { ref_table = "card.ability", ref_value = "extra", retrigger_type = "mult" },
            },
            text_config = { colour = G.C.GOLD },
            reminder_text = {
                { text = "(", colour = G.C.UI.TEXT_INACTIVE },
                { ref_table = "card.joker_display_values", ref_value = "active_text" },
                { text = ")", colour = G.C.UI.TEXT_INACTIVE },
            },
            calc_function = function(card)
                local boss_active = G.GAME.blind and G.GAME.blind.get_type and
                    (not G.GAME.blind.disabled) and (G.GAME.blind:get_type() == "Boss")
                card.joker_display_values.active = boss_active
                card.joker_display_values.active_text = localize(boss_active and "jdis_active" or "jdis_inactive")
            end,
            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children and reminder_text.children[2] then
                    reminder_text.children[2].config.colour =
                        card.joker_display_values.active and G.C.GREEN or G.C.UI.TEXT_INACTIVE
                end
            end,
        }
    end

end -- REB4LANCED.config.matador_enhanced

end
