return function(REB4LANCED)

if REB4LANCED.config.joker_set_suit then

SMODS.Joker {
    key = 'palette',
    atlas = 'reb4l_jokers',
    pos = { x = 14, y = 1 },
    rarity = 3,
    cost = 8,

    blueprint_compat = false,
    eternal_compat = true,

    config = {
        extra = {
            per_wild = 1
        }
    },

    loc_txt = {
        name = 'Palette',
        text = {
            'Each {C:attention}Wild Card{} in hand',
            'gives {C:attention}+#1#{} Hand Size'
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.per_wild } }
    end,

    calculate = function(self, card, context)

        -- THIS is the correct hook for live hand size modification
        if context.hand_size_mod then
            local wild_count = 0

            for _, c in ipairs(G.hand.cards or {}) do
                if c.config
                and c.config.center
                and c.config.center.key == 'm_wild'
                and not c.debuff then
                    wild_count = wild_count + 1
                end
            end

            if wild_count > 0 then
                return {
                    hand_size = wild_count * card.ability.extra.per_wild
                }
            end
        end

    end
}

end

end
