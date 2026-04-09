return function(REB4LANCED)
if REB4LANCED.config.joker_tags_enhanced then
SMODS.Tag:take_ownership('uncommon', {
    loc_txt = {
        name = 'Uncommon Tag',
        text = {
            'Creates a random',
            '{C:green}Uncommon{} Joker',
            '{C:inactive}(Must have room){}',
        },
    },
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.GREEN, function()
                if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                    SMODS.add_card({ set = 'Joker', rarity = 'Uncommon', key_append = 'uta' })
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
