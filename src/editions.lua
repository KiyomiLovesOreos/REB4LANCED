-- Only e_holo differs from vanilla (vanilla: +10 Mult, reb4lanced: +20 Mult).
-- Keys use the vanilla identifier WITHOUT the 'e_' class prefix.

if REB4LANCED.config.holo_enhanced then
SMODS.Edition:take_ownership('holo', {
    config = { mult = 20 },
}, false)
end
