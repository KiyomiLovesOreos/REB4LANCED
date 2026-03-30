-- Direct value patches (always loaded).
-- Note: rarity changes must go through SMODS.Joker:take_ownership (see jokers.lua);
-- direct G.P_CENTERS mutations don't affect Steamodded's pool registry.

-- Joker costs
if G.P_CENTERS.j_golden  then G.P_CENTERS.j_golden.cost  = 8 end -- $8 (vanilla: $6)
if G.P_CENTERS.j_matador then G.P_CENTERS.j_matador.cost = 4 end -- $4 (vanilla: $3)

-- Joker config (flat value changes)
if G.P_CENTERS.j_todo_list  and G.P_CENTERS.j_todo_list.config.extra  then
    G.P_CENTERS.j_todo_list.config.extra.dollars = 5  -- $5 (vanilla: $4)
end
if G.P_CENTERS.j_obelisk    then G.P_CENTERS.j_obelisk.config.extra    = 0.25 end -- X0.25/hand (vanilla: X0.2)
if G.P_CENTERS.j_onyx_agate then G.P_CENTERS.j_onyx_agate.config.extra = 14   end -- +14 Mult   (vanilla: +7)
if G.P_CENTERS.j_rough_gem then
    G.P_CENTERS.j_rough_gem.config.extra = 2  -- $2/Diamond (vanilla: $1)
end

-- Deck config patches
if G.P_CENTERS.b_painted then G.P_CENTERS.b_painted.config.joker_slot    = 0 end -- remove -1 joker slot
if G.P_CENTERS.b_nebula  then G.P_CENTERS.b_nebula.config.consumable_slot = 0 end -- remove -1 consumable slot

-- Enhancement config
if G.P_CENTERS.m_mult   then G.P_CENTERS.m_mult.config.mult   = 6  end -- +6 Mult   (vanilla: +4)
if G.P_CENTERS.m_stone  then G.P_CENTERS.m_stone.config.bonus = 75 end -- +75 Chips (vanilla: +50)

-- Standard pack sizes (4/6/6 instead of 3/5/4)
local _std = {
    p_standard_normal_1 = { extra = 4, choose = 1 },
    p_standard_normal_2 = { extra = 4, choose = 1 },
    p_standard_normal_3 = { extra = 4, choose = 1 },
    p_standard_normal_4 = { extra = 4, choose = 1 },
    p_standard_jumbo_1  = { extra = 6, choose = 1 },
    p_standard_jumbo_2  = { extra = 6, choose = 1 },
    p_standard_mega_1   = { extra = 6, choose = 2 },
    p_standard_mega_2   = { extra = 6, choose = 2 },
}
for key, vals in pairs(_std) do
    if G.P_CENTERS[key] then
        G.P_CENTERS[key].config.extra  = vals.extra
        G.P_CENTERS[key].config.choose = vals.choose
    end
end
