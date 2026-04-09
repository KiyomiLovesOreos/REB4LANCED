return function(REB4LANCED)
-- The Wall: 3x chips required (vanilla: 4x)
if REB4LANCED.config.wall_enhanced then
SMODS.Blind:take_ownership('wall', {
    mult = 3,
}, false)
end
end
