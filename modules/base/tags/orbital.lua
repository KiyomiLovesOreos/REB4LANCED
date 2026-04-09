return function(REB4LANCED)
if REB4LANCED.config.tag_reworks_enhanced then
SMODS.Tag:take_ownership('orbital', {
    min_ante = 1,
    config = { levels = 5 },
    loc_vars = function(self, info_queue, tag)
        return {
            vars = {
                (tag.ability.orbital_hand == '[' .. localize('k_poker_hand') .. ']') and tag.ability.orbital_hand
                    or localize(tag.ability.orbital_hand, 'poker_hands'),
                5,
            },
        }
    end,
    set_ability = function(self, tag)
        if G.orbital_hand then
            tag.ability.orbital_hand = G.orbital_hand
        elseif tag.ability.blind_type then
            if G.GAME.orbital_choices and G.GAME.orbital_choices[G.GAME.round_resets.ante][tag.ability.blind_type] then
                tag.ability.orbital_hand = G.GAME.orbital_choices[G.GAME.round_resets.ante][tag.ability.blind_type]
            end
        end
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            SMODS.upgrade_poker_hands({ from = tag, hands = { tag.ability.orbital_hand }, level_up = 5 })
            tag:yep('+', G.C.MONEY, function()
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
