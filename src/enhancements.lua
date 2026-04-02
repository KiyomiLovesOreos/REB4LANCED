-- Mult Card: +6 Mult (vanilla: +4)
if REB4LANCED.config.mult_card_enhanced then
SMODS.Enhancement:take_ownership('mult', {
    loc_txt = {
        name = 'Mult Card',
        text = { '+{C:mult}#1#{} Mult' },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 6 } }
    end,
}, false)
end

-- Stone Card: +75 Chips (vanilla: +50)
if REB4LANCED.config.stone_card_enhanced then
SMODS.Enhancement:take_ownership('stone', {
    loc_txt = {
        name = 'Stone Card',
        text = { '+{C:chips}#1#{} Chips, {C:attention}no rank or suit' },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 75 } }
    end,
}, false)
end

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
