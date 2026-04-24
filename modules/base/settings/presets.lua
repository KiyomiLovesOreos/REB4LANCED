REB4LANCED       = REB4LANCED or {}
REB4LANCED.UI    = REB4LANCED.UI or {}
REB4LANCED.config = SMODS.current_mod.config

-- ─── Preset key order ─────────────────────────────────────────────────────────
-- Defines the canonical order for encode/decode.  Each entry is one of:
--   { 'key', 'bool' }          → encoded as 0 (false) or 1 (true)
--   { 'key', 'cycle', max }    → encoded as 0-indexed digit  (stored value − 1)
-- Add new keys to the END to preserve backward-compatibility with old codes.
REB4LANCED.PRESET_KEYS = {
    -- Jokers (reworks)
    { 'chicot_mode',               'cycle', 3 },
    { 'bloodstone_enhanced',       'bool' },
    { 'idol_mode',                 'cycle', 3 },
    { 'seeing_double_enhanced',    'bool' },
    { 'flower_pot_enhanced',       'bool' },
    { 'satellite_mode',            'cycle', 3 },
    { 'constellation_enhanced',    'bool' },
    { 'splash_enhanced',           'bool' },
    { 'superposition_enhanced',    'bool' },
    { 'bootstraps_enhanced',       'bool' },
    { 'bull_enhanced',             'bool' },
    { 'erosion_enhanced',          'bool' },
    { 'campfire_enhanced',         'bool' },
    { 'delayed_grat_mode',         'cycle', 3 },
    { 'throwback_enhanced',        'cycle', 3 },
    { 'matador_enhanced',          'bool' },
    { 'yorick_enhanced',           'bool' },
    { 'mr_bones_enhanced',         'bool' },
    { 'seance_enhanced',           'bool' },
    { 'hit_the_road_enhanced',     'bool' },
    { 'drunkard_enhanced',         'bool' },
    { 'drivers_license_enhanced',  'bool' },
    { 'merry_andy_enhanced',       'bool' },
    -- Jokers (stat buffs)
    { 'mad_enhanced',              'bool' },
    { 'crazy_enhanced',            'bool' },
    { 'droll_enhanced',            'bool' },
    { 'eight_ball_enhanced',       'bool' },
    { 'hanging_chad_enhanced',     'bool' },
    { 'space_joker_enhanced',      'bool' },
    { 'vagabond_enhanced',         'bool' },
    { 'madness_enhanced',          'bool' },
    { 'rocket_enhanced',           'bool' },
    { 'golden_enhanced',           'bool' },
    { 'todo_list_enhanced',        'bool' },
    { 'obelisk_enhanced',          'bool' },
    { 'onyx_agate_enhanced',       'bool' },
    { 'rough_gem_enhanced',        'bool' },
    -- Jokers (rarity/cost)
    { 'mime_enhanced',             'bool' },
    { 'smeared_enhanced',          'bool' },
    { 'baron_enhanced',            'bool' },
    { 'mail_rebate_enhanced',      'bool' },
    { 'marble_enhanced',           'bool' },
    { 'ticket_enhanced',           'bool' },
    { 'diet_cola_enhanced',        'bool' },
    -- Consumables
    { 'lovers_enhanced',           'bool' },
    { 'tarot_enhance_enhanced',    'bool' },
    { 'sigil_ouija_enhanced',      'bool' },
    { 'buffed_soul',               'bool' },
    { 'buffed_black_hole',         'bool' },
    { 'wheel_of_fortune_enhanced', 'bool' },
    { 'ectoplasm_enhanced',        'bool' },
    -- Tags
    { 'pack_tags_enhanced',        'bool' },
    { 'tag_reworks_enhanced',      'bool' },
    { 'edition_tags_enhanced',     'bool' },
    { 'joker_tags_enhanced',       'bool' },
    { 'coupon_tag_enhanced',       'bool' },
    { 'garbage_tag_enhanced',      'bool' },
    { 'voucher_tag_enhanced',      'bool' },
    -- Decks (reworks)
    { 'abandoned_enhanced',        'bool' },
    { 'checkered_enhanced',        'bool' },
    { 'anaglyph_enhanced',         'bool' },
    { 'painted_mode',              'cycle', 3 },
    { 'black_deck_enhanced',       'bool' },
    { 'nebula_enhanced',           'bool' },
    -- Decks (new content)
    { 'workshop_deck',             'bool' },
    { 'magician_deck',             'bool' },
    { 'burnt_mode',                'cycle', 3 },
    { 'anchor_deck',               'cycle', 3 },
    -- Enhancements
    { 'mult_card_enhanced',        'bool' },
    { 'stone_card_enhanced',       'bool' },
    { 'wild_card_enhanced',        'bool' },
    -- Vouchers
    { 'hieroglyph_rework',         'bool' },
    { 'tarot_tycoon_enhanced',     'bool' },
    { 'planet_tycoon_enhanced',    'bool' },
    { 'magic_trick_enhanced',      'bool' },
    { 'illusion_enhanced',         'bool' },
    { 'telescope_enhanced',        'bool' },
    { 'observatory_enhanced',      'bool' },
    -- Seals
    { 'blue_seal_enhanced',        'bool' },
    -- Editions
    { 'holo_enhanced',             'bool' },
    -- Bosses
    { 'wall_enhanced',             'bool' },
    -- Misc
    { 'stakes_enhanced',           'bool' },
    { 'stake_scaling_enhanced',    'bool' },
    { 'perishable_enhanced',       'cycle', 3 },
    { 'purple_stake_mode',         'cycle', 2 },
    { 'interest_on_skip',          'bool' },
    { 'standard_packs_enhanced',   'bool' },
    { 'fork_tag_vouchers',         'bool' },
    { 'draft_deck',                'bool' },
    { 'all_seeing_eye_deck',       'bool' },
    -- New joker sets
    { 'joker_set_rank',            'bool' },
    { 'joker_set_stone',           'bool' },
    { 'joker_set_suit',            'bool' },
    -- New tag sets
    { 'tag_set_skip',              'bool' },
    -- New consumable sets
    { 'axiom_set',                 'bool' },
}

-- ─── SUGGESTED PRESET ─────────────────────────────────────────────────────────
-- Edit the values below to customise what the "Suggested" button applies.
-- Booleans : true / false
-- Cycles   : 1 = first option shown in-game, 2 = second, 3 = third, etc.
REB4LANCED.SUGGESTED = {
    -- Jokers (reworks)
    chicot_mode               = 3, -- 1=Vanilla  2=-33% Blind Chips  3=Skip Tags
    bloodstone_enhanced       = false,
    idol_mode                 = 3, -- 1=Vanilla  2=Rare/X2.5         3=Fixed Rank/Suit
    seeing_double_enhanced    = true,
    flower_pot_enhanced       = true,
    satellite_mode            = 2, -- 1=Vanilla  2=End of Round      3=On Level Up
    constellation_enhanced    = true,
    splash_enhanced           = true,
    superposition_enhanced    = true,
    bootstraps_enhanced       = false,
    bull_enhanced             = false,
    erosion_enhanced          = true,
    campfire_enhanced         = true,
    delayed_grat_mode         = 2, -- 1=Vanilla  2=$2/Unused Discard 3=$4 if 0 Used
    throwback_enhanced        = 2, -- 1=Vanilla  2=X1/Skip          3=X0.5/Tag Gained
    matador_enhanced          = true,
    yorick_enhanced           = true,
    mr_bones_enhanced         = false,
    seance_enhanced           = true,
    hit_the_road_enhanced     = true,
    drunkard_enhanced         = true,
    drivers_license_enhanced  = true,
    merry_andy_enhanced       = true,
    -- Jokers (stat buffs)
    mad_enhanced              = true,
    crazy_enhanced            = true,
    droll_enhanced            = true,
    eight_ball_enhanced       = true,
    hanging_chad_enhanced     = true,
    space_joker_enhanced      = true,
    vagabond_enhanced         = false,
    madness_enhanced          = true,
    rocket_enhanced           = true,
    golden_enhanced           = false,
    todo_list_enhanced        = false,
    obelisk_enhanced          = false,
    onyx_agate_enhanced       = true,
    rough_gem_enhanced        = true,
    -- Jokers (rarity/cost)
    mime_enhanced             = true,
    smeared_enhanced          = true,
    baron_enhanced            = true,
    mail_rebate_enhanced      = true,
    marble_enhanced           = true,
    ticket_enhanced           = true,
    diet_cola_enhanced        = false,
    -- Consumables
    lovers_enhanced           = true,
    tarot_enhance_enhanced    = false,
    sigil_ouija_enhanced      = true,
    buffed_soul               = true,
    buffed_black_hole         = true,
    wheel_of_fortune_enhanced = true,
    ectoplasm_enhanced        = true,
    -- Tags
    pack_tags_enhanced        = false,
    tag_reworks_enhanced      = true,
    edition_tags_enhanced     = true,
    joker_tags_enhanced       = true,
    coupon_tag_enhanced       = true,
    garbage_tag_enhanced      = true,
    voucher_tag_enhanced      = true,
    -- Decks (reworks)
    abandoned_enhanced        = true,
    checkered_enhanced        = true,
    anaglyph_enhanced         = false,
    painted_mode              = 3, -- 1=Vanilla  2=-1 Hand/Round     3=-1 Discard/Round
    black_deck_enhanced       = true,
    nebula_enhanced           = true,
    -- Decks (new content)
    workshop_deck             = true,
    magician_deck             = true,
    burnt_mode                = 3,
    anchor_deck               = 3, -- 1=Off  2=Hand Locked  3=Fixed Rerolls
    -- Enhancements
    mult_card_enhanced        = true,
    stone_card_enhanced       = true,
    wild_card_enhanced        = true,
    -- Vouchers
    hieroglyph_rework         = true,
    tarot_tycoon_enhanced     = true,
    planet_tycoon_enhanced    = true,
    magic_trick_enhanced      = true,
    illusion_enhanced         = true,
    telescope_enhanced        = true,
    observatory_enhanced      = true,
    -- Seals
    blue_seal_enhanced        = true,
    -- Editions
    holo_enhanced             = true,
    -- Bosses
    wall_enhanced             = false,
    -- Misc
    stakes_enhanced           = true,
    stake_scaling_enhanced    = true,
    perishable_enhanced       = 1, -- 1=Vanilla  2=Wilting  3=Sell Decay
    purple_stake_mode         = 1, -- 1=Voucher Cost  2=Pinned Shop
    interest_on_skip          = true,
    standard_packs_enhanced   = true,
    fork_tag_vouchers         = true,
    draft_deck                = true,
    all_seeing_eye_deck       = true,
    -- New joker sets
    joker_set_rank            = false,
    joker_set_stone           = false,
    joker_set_suit            = false,
    -- New tag sets
    tag_set_skip              = false,
    -- New consumable sets
    axiom_set                 = false,
}

-- ─── Encode / decode ──────────────────────────────────────────────────────────

local function reb4l_encode_config()
    local parts = {}
    for _, entry in ipairs(REB4LANCED.PRESET_KEYS) do
        local val = REB4LANCED.config[entry[1]]
        if entry[2] == 'bool' then
            parts[#parts + 1] = val and '1' or '0'
        else
            parts[#parts + 1] = tostring((val or 1) - 1)
        end
    end
    return table.concat(parts)
end
REB4LANCED.UI.encode_config = reb4l_encode_config

local function reb4l_decode_and_apply(code)
    if type(code) ~= 'string' then return false end
    code = code:match('^%s*(.-)%s*$')
    if #code < #REB4LANCED.PRESET_KEYS then return false end
    for i, entry in ipairs(REB4LANCED.PRESET_KEYS) do
        local n = tonumber(code:sub(i, i))
        if n == nil then return false end
        if entry[2] == 'bool' then
            REB4LANCED.config[entry[1]] = (n == 1)
        else
            REB4LANCED.config[entry[1]] = math.max(1, math.min(entry[3], n + 1))
        end
    end
    SMODS.save_mod_config(SMODS.current_mod)
    return true
end

-- ─── Preset callbacks ─────────────────────────────────────────────────────────

G.FUNCS.reb4l_preset_all_off = function(_)
    for _, entry in ipairs(REB4LANCED.PRESET_KEYS) do
        if entry[2] == 'bool' then
            REB4LANCED.config[entry[1]] = false
        else
            REB4LANCED.config[entry[1]] = 1
        end
    end
    SMODS.save_mod_config(SMODS.current_mod)
    REB4LANCED.UI.refresh_panel()
end

G.FUNCS.reb4l_preset_all_on = function(_)
    for _, entry in ipairs(REB4LANCED.PRESET_KEYS) do
        REB4LANCED.config[entry[1]] = (entry[2] == 'bool') and true or entry[3]
    end
    SMODS.save_mod_config(SMODS.current_mod)
    REB4LANCED.UI.refresh_panel()
end

G.FUNCS.reb4l_preset_suggested = function(_)
    for k, v in pairs(REB4LANCED.SUGGESTED) do
        REB4LANCED.config[k] = v
    end
    SMODS.save_mod_config(SMODS.current_mod)
    REB4LANCED.UI.refresh_panel()
end

G.FUNCS.reb4l_copy_config = function(_)
    if love and love.system then
        love.system.setClipboardText(reb4l_encode_config())
    end
end

G.FUNCS.reb4l_paste_config = function(_)
    if not (love and love.system) then return end
    if reb4l_decode_and_apply(love.system.getClipboardText()) then
        REB4LANCED.UI.refresh_panel()
    end
end
