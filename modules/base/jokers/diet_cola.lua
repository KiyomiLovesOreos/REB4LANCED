return function(REB4LANCED)
-- Diet Cola: Double Tag at end of round (3 uses), then self-destructs (vanilla: Double Tag on sell)
if REB4LANCED.config.diet_cola_enhanced then
SMODS.Joker:take_ownership('diet_cola', {
    config = { extra = { tags_remaining = 3 } },
    loc_txt = {
        name = "Diet Cola",
        text = {
            "Creates a {C:attention}#1#{}",
            "#2#",
        },
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'tag_double', set = 'Tag' }
        local tag_name = localize { type = 'name_text', set = 'Tag', key = 'tag_double' }
        local uses = card.ability and card.ability.extra.tags_remaining or 3
        return { vars = { tag_name, 'at end of round (' .. uses .. ' uses left)' } }
    end,
    calculate = function(self, card, context)
        if context.selling_self then
            return true  -- suppress vanilla sell Double Tag; our version fires at end of round
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            card.ability.extra.tags_remaining = card.ability.extra.tags_remaining - 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    add_tag(Tag('tag_double'))
                    play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end
            }))
            if card.ability.extra.tags_remaining <= 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.5,
                    func = function()
                        card:start_dissolve()
                        return true
                    end
                }))
            end
            return { message = localize { type = 'name_text', set = 'Tag', key = 'tag_double' }, colour = G.C.GREEN }
        end
    end,
}, false)
end

end
