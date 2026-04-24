return function(REB4LANCED)
if not REB4LANCED.config.tag_set_skip then return end

SMODS.Tag({
    key    = 'grasp',
    atlas  = 'reb4l_tags',
    pos    = { x = 0, y = 0 },
    config = { type = 'immediate', hand_size = 1 },
    loc_txt = {
        name = 'Grasp Tag',
        text = {
            '{C:attention}+#1#{} hand size',
            'for the remainder',
            'of the run',
        },
    },
    loc_vars = function(self, info_queue, tag)
        return { vars = { self.config.hand_size } }
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            tag:yep('+' .. tag.config.hand_size .. ' Hand Size', G.C.BLUE, function()
                G.hand:change_size(tag.config.hand_size)
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
})

end
