return function(REB4LANCED)
-- Palette: each Wild Card in hand gives +1 Hand Size.
if REB4LANCED.config.joker_set_suit then

local function reb4l_palette_update()
    if not G.GAME or not G.jokers or not G.hand then return end
    for _, j in ipairs(G.jokers.cards) do
        if j.config.center.key == 'j_reb4l_palette' and not j.debuff then
            local wild_count = 0
            for _, c in ipairs(G.hand.cards or {}) do
                if c.config and c.config.center and c.config.center.key == 'm_wild' and not c.debuff then
                    wild_count = wild_count + 1
                end
            end
            local bonus = wild_count * (j.ability.extra.hand_size_per or 1)
            local prev = j.ability.reb4l_palette_bonus or 0
            local delta = bonus - prev
            if delta ~= 0 then
                G.GAME.modifiers.hand_size = (G.GAME.modifiers.hand_size or 0) + delta
                G.hand:change_size(delta)
            end
            j.ability.reb4l_palette_bonus = bonus
        end
    end
end

-- Wrap draw so palette recalculates after any draw
if G.FUNCS.draw_from_deck_to_hand then
    local reb4l_palette_orig_draw = G.FUNCS.draw_from_deck_to_hand
    G.FUNCS.draw_from_deck_to_hand = function(e)
        local result = reb4l_palette_orig_draw(e)
        reb4l_palette_update()
        return result
    end
end

SMODS.Joker {
    key = 'palette',
    atlas = 'reb4l_jokers',
    pos = { x = 14, y = 1 },
    rarity = 1,
    cost = 4,

    blueprint_compat = true,
    eternal_compat = true,

    config = {
        extra = {
            hand_size_per = 1,
        }
    },

    loc_txt = {
        name = 'Palette',
        text = {
            '{C:attention}+#1#{} hand size',
            'for each {C:attention}Wild Card{}',
            'held in hand',
        },
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hand_size_per } }
    end,

    calculate = function(self, card, context)
        if context.setting_ability then
            if G.E_MANAGER then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.0,
                    func = function()
                        reb4l_palette_update()
                        return true
                    end
                }))
            end
            return
        end
        if context.pre_discard and not card.debuff then
            -- Calculate post-discard wild count by subtracting highlighted wilds
            local wild_count = 0
            for _, c in ipairs(G.hand.cards or {}) do
                if c.config and c.config.center and c.config.center.key == 'm_wild' and not c.debuff then
                    wild_count = wild_count + 1
                end
            end
            local highlighted_wilds = 0
            for _, c in ipairs(G.hand.highlighted or {}) do
                if c.config and c.config.center and c.config.center.key == 'm_wild' and not c.debuff then
                    highlighted_wilds = highlighted_wilds + 1
                end
            end
            local after_discard = wild_count - highlighted_wilds
            local bonus = after_discard * (card.ability.extra.hand_size_per or 1)
            local prev = card.ability.reb4l_palette_bonus or 0
            local delta = bonus - prev
            if delta ~= 0 then
                G.GAME.modifiers.hand_size = (G.GAME.modifiers.hand_size or 0) + delta
                G.hand:change_size(delta)
            end
            card.ability.reb4l_palette_bonus = bonus
            return
        end
        if context.setting_blind and not card.debuff then
            card.ability.reb4l_palette_bonus = 0
        end
    end,
}

end -- REB4LANCED.config.joker_set_suit

end
