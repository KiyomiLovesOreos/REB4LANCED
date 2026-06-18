return function(REB4LANCED)
if REB4LANCED.config.anaglyph_enhanced then
SMODS.Tag:take_ownership('double', {
    apply = function(self, tag, context)
        if not (G.GAME and G.GAME.reb4l_anaglyph_active) then return end
        if context.type == 'tag_add' and context.tag.key ~= 'tag_double' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.BLUE, function()
                if context.tag.ability and context.tag.ability.orbital_hand then
                    G.orbital_hand = context.tag.ability.orbital_hand
                end
                local copy = Tag(context.tag.key)
                copy.reb4l_anaglyph_copy = true
                add_tag(copy)
                G.orbital_hand = nil
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
