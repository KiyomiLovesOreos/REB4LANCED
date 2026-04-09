return function(REB4LANCED)
-- Obelisk: X0.25 per consecutive most-played hand (vanilla X0.2)
-- patches.lua cannot set config.extra = 0.25 because vanilla config.extra is a table
if REB4LANCED.config.obelisk_enhanced then
SMODS.Joker:take_ownership('obelisk', {
    config = { extra = 0.25, x_mult = 1 },
}, false)
end -- REB4LANCED.config.obelisk_enhanced
end
