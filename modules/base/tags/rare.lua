return function(REB4LANCED)
if REB4LANCED.config.joker_tags_enhanced then
SMODS.Tag:take_ownership('rare', {
    loc_txt = {
        name = 'Rare Tag',
        text = {
            'Creates a random',
            '{C:red}Rare{} Joker',
            '{C:inactive}(Must have room){}',
        },
    },
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.RED, function()
                if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                    SMODS.add_card({ set = 'Joker', rarity = 'Rare', key_append = 'rta' })
                end
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}, false)
end
end
