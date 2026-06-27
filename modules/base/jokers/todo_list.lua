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

end
