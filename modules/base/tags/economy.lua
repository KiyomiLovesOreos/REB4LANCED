return function(REB4LANCED)
if REB4LANCED.config.tag_reworks_enhanced then
SMODS.Tag:take_ownership('economy', {
    config = { max = 50 },
    loc_vars = function(self, info_queue, tag)
        return { vars = { 50 } }
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.MONEY, function()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    ease_dollars(math.min(50, math.max(0, G.GAME.dollars)), true)
                    return true
                end,
            }))
            tag.triggered = true
            return true
        end
    end,
}, false)
end
end
