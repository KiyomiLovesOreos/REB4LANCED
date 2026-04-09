return function(REB4LANCED)
-- Wild Card: resist suit-based Boss Blind debuffs (behavior in overrides.lua)
if REB4LANCED.config.wild_card_enhanced then
SMODS.Enhancement:take_ownership('wild', {
    loc_txt = {
        name = 'Wild Card',
        text = {
            'Can be used as {C:attention}any suit',
        },
    },
}, false)
end
end
