return function(REB4LANCED)
if not REB4LANCED.config.tag_set_skip then return end

SMODS.Tag({
    key      = 'surplus',
    atlas    = 'reb4l_tags',
    pos      = { x = 1, y = 0 },
    min_ante = 2,
    config   = { type = 'immediate', slots = 1 },
    loc_txt = {
        name = 'Surplus Tag',
        text = {
            '{C:attention}+#1#{} consumable slot',
        },
    },
    loc_vars = function(self, info_queue, tag)
        return { vars = { self.config.slots } }
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            tag:yep('+' .. tag.config.slots .. ' Slot', G.C.PURPLE, function()
                G.consumeables.config.card_limit = G.consumeables.config.card_limit + tag.config.slots
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
})

end
