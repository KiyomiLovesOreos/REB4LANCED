return function(REB4LANCED)
-- To Do List: $5 per scored hand (up from $4); stat patched in patches.lua
if REB4LANCED.config.todo_list_enhanced then
SMODS.Joker:take_ownership('todo_list', {
    loc_txt = {
        name = 'To Do List',
        text = {
            'Earn {C:money}$#1#',
            'if played hand is a {C:attention}#2#',
        },
    },
}, false)
end


if REB4LANCED.config.splash_enhanced then
SMODS.Joker:take_ownership('splash', {
    loc_txt = {
        name = 'Splash',
        text = {
            'Every {C:attention}played card{}',
            'counts in scoring',
            '{C:inactive}Debuffs are cleared',
            '{C:inactive}before scoring{}',
        },
    },
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            for i = 1, #G.play.cards do
                G.play.cards[i]:set_debuff(false)
            end
        end
        if context.modify_scoring_hand then
            return { add_to_hand = true }
        end
    end,
}, false)
end -- REB4LANCED.config.splash_enhanced

end
