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
-- Obelisk, Onyx Agate, Rough Gem: handled via take_ownership (config.extra is a table in vanilla; direct replacement would break it)

-- Deck config patches
if REB4LANCED.config.painted_mode and REB4LANCED.config.painted_mode > 1 and G.P_CENTERS.b_painted then G.P_CENTERS.b_painted.config.joker_slot = 0 end
if REB4LANCED.config.nebula_enhanced  and G.P_CENTERS.b_nebula  then G.P_CENTERS.b_nebula.config.consumable_slot = 0 end
if G.P_CENTERS.b_green then
    G.P_CENTERS.b_green.config.extra_hand_bonus    = 3
    G.P_CENTERS.b_green.config.extra_discard_bonus = 2
end

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
