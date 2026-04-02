-- Direct value patches. Each is guarded by its corresponding config flag.
-- Note: rarity changes must go through SMODS.Joker:take_ownership (see jokers.lua);
-- direct G.P_CENTERS mutations don't affect Steamodded's pool registry.

-- Joker costs
if REB4LANCED.config.golden_enhanced  and G.P_CENTERS.j_golden  then G.P_CENTERS.j_golden.cost  = 8 end
if REB4LANCED.config.matador_enhanced and G.P_CENTERS.j_matador then G.P_CENTERS.j_matador.cost = 4 end

-- Joker config (flat value changes)
if REB4LANCED.config.todo_list_enhanced and G.P_CENTERS.j_todo_list and G.P_CENTERS.j_todo_list.config.extra then
    G.P_CENTERS.j_todo_list.config.extra.dollars = 5
end
if REB4LANCED.config.obelisk_enhanced    and G.P_CENTERS.j_obelisk    then G.P_CENTERS.j_obelisk.config.extra    = 0.25 end
if REB4LANCED.config.onyx_agate_enhanced and G.P_CENTERS.j_onyx_agate then G.P_CENTERS.j_onyx_agate.config.extra = 14   end
if REB4LANCED.config.rough_gem_enhanced  and G.P_CENTERS.j_rough_gem  then G.P_CENTERS.j_rough_gem.config.extra  = 2    end

-- Deck config patches
if REB4LANCED.config.painted_mode and REB4LANCED.config.painted_mode > 1 and G.P_CENTERS.b_painted then G.P_CENTERS.b_painted.config.joker_slot = 0 end
if REB4LANCED.config.nebula_enhanced  and G.P_CENTERS.b_nebula  then G.P_CENTERS.b_nebula.config.consumable_slot = 0 end

-- Enhancement config
if REB4LANCED.config.mult_card_enhanced  and G.P_CENTERS.m_mult  then G.P_CENTERS.m_mult.config.mult   = 6  end
if REB4LANCED.config.stone_card_enhanced and G.P_CENTERS.m_stone then G.P_CENTERS.m_stone.config.bonus = 75 end

-- Standard pack sizes (4/6/6 instead of 3/5/4)
if REB4LANCED.config.standard_packs_enhanced then
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
end
