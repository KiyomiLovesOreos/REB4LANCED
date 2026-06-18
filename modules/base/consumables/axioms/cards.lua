-- 20 stub Axiom consumables (5-wide sprite sheet, 4 rows).
-- Fill in loc_txt, use, and can_use when designing each card.
-- Remove can_use stub once implemented so the card becomes usable.
return function(REB4LANCED)

local function axiom(key, x, y, name)
    SMODS.Consumable({
        key   = key,
        set   = 'reb4l_Axiom',
        atlas = 'reb4l_axioms',
        pos   = {x = x, y = y},
        cost  = 6,
        loc_txt = {
            name = name,
            text = { '{C:inactive}Not yet implemented{}' },
        },
        can_use = function(self, card) return false end,
        use     = function(self, card, area, copier) end,
    })
end

-- Row 0 (axiom_01, 03, 04, 05 are implemented in their own files)
axiom('axiom_02', 1, 0, 'Axiom II')
-- Row 1
axiom('axiom_06', 0, 1, 'Axiom VI')
axiom('axiom_07', 1, 1, 'Axiom VII')
axiom('axiom_08', 2, 1, 'Axiom VIII')
axiom('axiom_09', 3, 1, 'Axiom IX')
axiom('axiom_10', 4, 1, 'Axiom X')
-- Row 2
axiom('axiom_11', 0, 2, 'Axiom XI')
axiom('axiom_12', 1, 2, 'Axiom XII')
axiom('axiom_13', 2, 2, 'Axiom XIII')
axiom('axiom_14', 3, 2, 'Axiom XIV')
axiom('axiom_15', 4, 2, 'Axiom XV')
-- Row 3
axiom('axiom_16', 0, 3, 'Axiom XVI')
axiom('axiom_17', 1, 3, 'Axiom XVII')
axiom('axiom_18', 2, 3, 'Axiom XVIII')
axiom('axiom_19', 3, 3, 'Axiom XIX')
axiom('axiom_20', 4, 3, 'Axiom XX')

end
