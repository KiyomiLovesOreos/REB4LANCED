-- The Wall: 3x chips required (vanilla: 4x)
if REB4LANCED.config.wall_enhanced then
SMODS.Blind:take_ownership('wall', {
    mult = 3,
}, false)
end

-- Finisher Blinds: 3x chips required (vanilla: 2x)
-- Violet Vessel: 5x chips required
--if REB4LANCED.config.finisher_blinds_enhanced then
--for _, key in ipairs({ 'final_heart', 'final_leaf', 'final_acorn', 'final_bell' }) do
--    SMODS.Blind:take_ownership(key, {
--        mult = 3,
--    }, false)
--end
--SMODS.Blind:take_ownership('final_vessel', {
--    mult = 5,
--}, false)
--end
