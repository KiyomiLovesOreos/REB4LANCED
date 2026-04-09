return function(REB4LANCED)
if REB4LANCED.config.garbage_tag_enhanced then
SMODS.Tag:take_ownership('garbage', {
    min_ante = 2,
    config = { dollars_per_discard = 2 },
    loc_vars = function(self, info_queue, tag)
        return { vars = { 2, 2 * (G.GAME.unused_discards or 0) } }
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.MONEY, function()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            ease_dollars((G.GAME.unused_discards or 0) * 2)
            tag.triggered = true
            return true
        end
    end,
}, false)
end
end
