return function(REB4LANCED)
-- Mr. Bones: 25% threshold; destroys rightmost joker on trigger; self-destructs if it is the rightmost
if REB4LANCED.config.mr_bones_enhanced then
SMODS.Joker:take_ownership('mr_bones', {
    loc_txt = {
        name = 'Mr. Bones',
        text = {
            'Prevents {C:attention}losing{} the run if',
            'chips scored are at least',
            '{C:attention}25%{} of required chips',
            '{C:inactive}Destroys the {C:attention}rightmost Joker{}',
        },
    },
    calculate = function(self, card, context)
        if context.game_over and not context.blueprint and
            G.GAME.chips >= math.floor(G.GAME.blind.chips * 0.25) then
            local rightmost = nil
            for i = #G.jokers.cards, 1, -1 do
                if not G.jokers.cards[i].getting_sliced then
                    rightmost = G.jokers.cards[i]
                    break
                end
            end
            if rightmost then
                rightmost.getting_sliced = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        rightmost:start_dissolve({ G.C.RED }, nil, 1.6)
                        return true
                    end
                }))
            end
            return {
                message = localize('k_saved_ex'),
                saved = true,
            }
        end
    end,
}, false)
end -- REB4LANCED.config.mr_bones_enhanced

end
