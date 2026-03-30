-- Mult Card: +6 Mult (vanilla: +4) — see src/patches.lua
-- Stone Card: +75 Chips (vanilla: +50) — see src/patches.lua

-- Wild Card: resist suit-based Boss Blind debuffs (behavior in overrides.lua)
SMODS.Enhancement:take_ownership('wild', {
    loc_txt = {
        name = 'Wild Card',
        text = {
            'Can be used as {C:attention}any suit',
            '{C:inactive}Resists {C:attention}suit{C:inactive}-based Boss Blind debuffs',
        },
    },
}, false)
