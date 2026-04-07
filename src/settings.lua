REB4LANCED = REB4LANCED or {}
REB4LANCED.config = SMODS.current_mod.config
REB4LANCED.UI = REB4LANCED.UI or {}

-- Apply defaults for any missing settings
local defaults = {
    idol_mode = 1,
    bloodstone_enhanced = false,
    interest_on_skip = false,
    lovers_enhanced = false,
    tarot_enhance_enhanced = false,
    buffed_black_hole = false,
    diet_cola_enhanced = false,
    sigil_ouija_enhanced = false,
    pack_tags_enhanced = false,
    tag_reworks_enhanced = false,
    chicot_mode = 1,
    -- Joker reworks
    satellite_mode = 1,
    flower_pot_enhanced = false,
    seeing_double_enhanced = false,
    constellation_enhanced = false,
    splash_enhanced = false,
    superposition_enhanced = false,
    bootstraps_enhanced = false,
    bull_enhanced = false,
    erosion_enhanced = false,
    delayed_grat_mode = 1,
    throwback_enhanced = false,
    matador_enhanced = false,
    yorick_enhanced = false,
    mr_bones_enhanced = false,
    seance_enhanced = false,
    campfire_enhanced = false,
    drunkard_enhanced = false,
    hit_the_road_enhanced = false,
    drivers_license_enhanced = false,
    merry_andy_enhanced = false,
    -- Joker stat buffs
    mad_enhanced = false,
    crazy_enhanced = false,
    droll_enhanced = false,
    eight_ball_enhanced = false,
    hanging_chad_enhanced = false,
    space_joker_enhanced = false,
    vagabond_enhanced = false,
    madness_enhanced = false,
    rocket_enhanced = false,
    golden_enhanced = false,
    todo_list_enhanced = false,
    obelisk_enhanced = false,
    onyx_agate_enhanced = false,
    rough_gem_enhanced = false,
    -- Joker rarity/cost changes
    mime_enhanced = false,
    smeared_enhanced = false,
    baron_enhanced = false,
    mail_rebate_enhanced = false,
    marble_enhanced = false,
    ticket_enhanced = false,
    -- Enhancement changes
    mult_card_enhanced = false,
    stone_card_enhanced = false,
    wild_card_enhanced = false,
    -- Edition changes
    holo_enhanced = false,
    -- Seal changes
    blue_seal_enhanced = false,
    -- Deck changes (reworks)
    abandoned_enhanced = false,
    checkered_enhanced = false,
    anaglyph_enhanced = false,
    painted_mode = 1,
    black_deck_enhanced = false,
    nebula_enhanced = false,
    -- Deck changes (new content)
    workshop_deck = false,
    magician_deck = false,
    burnt_mode = 1,
    anchor_deck = 1,
    -- Stake changes
    stakes_enhanced = false,
    stake_scaling_enhanced = false,
    blue_stake_mode = 1,
    perishable_enhanced = false,
    -- Boss blind changes
    wall_enhanced = false,
    -- Tag changes
    edition_tags_enhanced = false,
    joker_tags_enhanced = false,
    coupon_tag_enhanced = false,
    garbage_tag_enhanced = false,
    voucher_tag_enhanced = false,
    -- Voucher changes
    hieroglyph_rework = false,
    tarot_tycoon_enhanced = false,
    planet_tycoon_enhanced = false,
    magic_trick_enhanced = false,
    illusion_enhanced = false,
    telescope_enhanced = false,
    observatory_enhanced = false,
    -- Consumable changes
    ectoplasm_enhanced = false,
    wheel_of_fortune_enhanced = false,
    -- Misc
    standard_packs_enhanced = false,
    buffed_soul = false,
    -- New vouchers / decks
    fork_tag_vouchers = false,
}
for k, v in pairs(defaults) do
    if REB4LANCED.config[k] == nil then
        REB4LANCED.config[k] = v
    end
end
if type(REB4LANCED.config.anchor_deck) == 'boolean' then
    REB4LANCED.config.anchor_deck = REB4LANCED.config.anchor_deck and 2 or 1
end
REB4LANCED.config.anchor_deck = math.max(1, math.min(3, tonumber(REB4LANCED.config.anchor_deck) or 1))
REB4LANCED.config.blue_stake_mode = math.max(1, math.min(2, tonumber(REB4LANCED.config.blue_stake_mode) or 1))

REB4LANCED.UI.options_per_page = 4
REB4LANCED.UI.current_page     = 1
REB4LANCED.UI.current_category = 'jokers'
REB4LANCED.UI.current_tab      = 1

-- ─── Preset key order ─────────────────────────────────────────────────────────
-- Defines the canonical order for encode/decode.  Each entry is one of:
--   { 'key', 'bool' }          → encoded as 0 (false) or 1 (true)
--   { 'key', 'cycle', max }    → encoded as 0-indexed digit  (stored value − 1)
-- Add new keys to the END to preserve backward-compatibility with old codes.
local PRESET_KEYS              = {
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
    { 'throwback_enhanced',        'bool' },
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
    { 'perishable_enhanced',       'bool' },
    { 'interest_on_skip',          'bool' },
    { 'standard_packs_enhanced',   'bool' },
    { 'fork_tag_vouchers',         'bool' },
    { 'blue_stake_mode',           'cycle', 2 },
}

-- ─── SUGGESTED PRESET ─────────────────────────────────────────────────────────
-- Edit the values below to customise what the "Suggested" button applies.
-- Booleans : true / false
-- Cycles   : 1 = first option shown in-game, 2 = second, 3 = third, etc.
local SUGGESTED                = {
    -- Jokers (reworks)
    chicot_mode               = 3, -- 1=Vanilla  2=-33% Blind Chips  3=Skip Tags
    bloodstone_enhanced       = true,
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
    throwback_enhanced        = true,
    matador_enhanced          = true,
    yorick_enhanced           = false,
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
    golden_enhanced           = true,
    todo_list_enhanced        = true,
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
    diet_cola_enhanced        = true,
    -- Consumables
    lovers_enhanced           = true,
    tarot_enhance_enhanced    = false,
    sigil_ouija_enhanced      = true,
    buffed_soul               = false,
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
    anaglyph_enhanced         = true,
    painted_mode              = 3, -- 1=Vanilla  2=-1 Hand/Round     3=-1 Discard/Round
    black_deck_enhanced       = true,
    nebula_enhanced           = true,
    -- Decks (new content)
    workshop_deck             = true,
    magician_deck             = true,
    burnt_mode                = 3,
    anchor_deck               = 2, -- 1=Off  2=Hand Locked  3=Fixed Rerolls
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
    blue_stake_mode           = 1, -- 1=Current  2=+$2 Base Reroll
    perishable_enhanced       = true,
    interest_on_skip          = true,
    standard_packs_enhanced   = true,
    fork_tag_vouchers         = true,
}

-- Encodes current config to a string of digits (one char per PRESET_KEYS entry).
local function reb4l_encode_config()
    local parts = {}
    for _, entry in ipairs(PRESET_KEYS) do
        local val = REB4LANCED.config[entry[1]]
        if entry[2] == 'bool' then
            parts[#parts + 1] = val and '1' or '0'
        else
            parts[#parts + 1] = tostring((val or 1) - 1)
        end
    end
    return table.concat(parts)
end

-- Decodes a code string and writes values into REB4LANCED.config.
-- Returns true on success, false if the string is invalid.
local function reb4l_decode_and_apply(code)
    if type(code) ~= 'string' then return false end
    code = code:match('^%s*(.-)%s*$') -- strip whitespace
    if #code < #PRESET_KEYS then return false end
    for i, entry in ipairs(PRESET_KEYS) do
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

-- ─── Category definitions ──────────────────────────────────────────────────────
-- Tab 1: vanilla rebalances.  Tab 2: new content added by the mod.
-- Adding a new tab-2 category: append an entry here and add a matching
-- elseif block in get_category_options below.
local categories_tab1 = {
    { key = 'jokers',       label = 'Jokers' },
    { key = 'consumables',  label = 'Consumables' },
    { key = 'tags',         label = 'Tags' },
    { key = 'decks',        label = 'Decks' },
    { key = 'enhancements', label = 'Enhancements' },
    { key = 'vouchers',     label = 'Vouchers' },
    { key = 'seals',        label = 'Seals' },
    { key = 'editions',     label = 'Editions' },
    { key = 'bosses',       label = 'Bosses' },
    { key = 'misc',         label = 'Misc' },
    { key = 'presets',      label = 'Presets' },
}
local categories_tab2 = {
    { key = 'nc_jokers',       label = 'Jokers' },
    { key = 'nc_decks',        label = 'Decks' },
    { key = 'nc_enhancements', label = 'Enhancements' },
    { key = 'nc_seals',        label = 'Seals' },
    { key = 'nc_spectrals',    label = 'Spectrals' },
    { key = 'nc_tarots',       label = 'Tarots' },
    { key = 'nc_vouchers',     label = 'Vouchers' },
    { key = 'nc_tags',         label = 'Tags' },
    { key = 'nc_hand_types',   label = 'Hand Types' },
    { key = 'nc_boss_blinds',  label = 'Boss Blinds' },
    { key = 'nc_stakes',       label = 'Stakes' },
    { key = 'nc_relics',       label = 'Relics' },
}
local function categories_for_tab(tab)
    return tab == 2 and categories_tab2 or categories_tab1
end

-- ─── Option box builders ──────────────────────────────────────────────────────

local function make_cycle_box(label, key, options_list, minw)
    local callback_name = 'reb4l_cycle_' .. key
    G.FUNCS[callback_name] = function(e)
        if not e or not e.cycle_config then return end
        REB4LANCED.config[key] = e.cycle_config.current_option
        SMODS.save_mod_config(SMODS.current_mod)
    end

    local current_idx = REB4LANCED.config[key] or 1
    local current_str = options_list[current_idx] or options_list[1]

    return {
        n = G.UIT.R,
        config = { align = 'cm', colour = G.C.L_BLACK, r = 0.1, padding = 0.15, emboss = 0.1 },
        nodes = { {
            n = G.UIT.C,
            config = { align = 'cl' },
            nodes = { SMODS.GUI.createOptionSelector({
                label = label,
                scale = 0.8,
                options = options_list,
                opt_callback = callback_name,
                no_pips = true,
                current_option = current_str,
                config = { align = 'cm', minw = minw or 7, padding = 0 }
            }) }
        } }
    }
end

local function make_option_box(label, desc, key)
    local toggle = create_toggle({
        label = label,
        ref_table = REB4LANCED.config,
        ref_value = key,
        callback = function(_)
            SMODS.save_mod_config(SMODS.current_mod)
        end,
    })
    toggle.config.minw = 7.5
    toggle.nodes[1].config.minw = 6
    toggle.nodes[1].config.align = 'cl'
    toggle.nodes[1].nodes[1].config.align = 'cl'

    local col_nodes = { toggle }
    if desc then
        col_nodes[#col_nodes + 1] = {
            n = G.UIT.R,
            config = { align = 'cl', padding = 0.03 },
            nodes = { { n = G.UIT.T, config = { text = desc, scale = 0.3, colour = HEX('b8c7d4') } } }
        }
    end

    return {
        n = G.UIT.R,
        config = { align = 'cm', colour = G.C.L_BLACK, r = 0.1, padding = 0.15, emboss = 0.1 },
        nodes = { {
            n = G.UIT.C,
            config = { align = 'cl' },
            nodes = col_nodes
        } }
    }
end

-- ─── Category option lists ─────────────────────────────────────────────────────

local function get_category_options(key)
    if key == 'jokers' then
        return {
            make_cycle_box('Chicot', 'chicot_mode', { 'Vanilla', '-33% Blind Chips', 'Skip Tags' }),
            make_option_box('Bloodstone', '1/3 chance for X2 Mult on Hearts', 'bloodstone_enhanced'),
            make_cycle_box('The Idol', 'idol_mode', { 'Vanilla', 'Rare/X2.5', 'Fixed Rank/Suit' }),
            make_option_box('Seeing Double', 'X1.25 per scoring card (Club + other suit)', 'seeing_double_enhanced'),
            make_option_box('Flower Pot', '+15 Chips per scoring Wild Card', 'flower_pot_enhanced'),
            make_cycle_box('Satellite', 'satellite_mode', { 'Vanilla', 'End of Round', 'On Level Up' }),
            make_option_box('Constellation', 'X0.1 Mult gain on any hand level-up', 'constellation_enhanced'),
            make_option_box('Splash', 'Every played card scores; debuffs cleared', 'splash_enhanced'),
            make_option_box('Superposition', 'Creates The Fool if hand is Straight + Ace', 'superposition_enhanced'),
            make_option_box('Bootstraps', '+1 Mult per $5 per scoring Heart/Diamond', 'bootstraps_enhanced'),
            make_option_box('Bull', '+3 Chips per $5 per scoring Spade/Club', 'bull_enhanced'),
            make_option_box('Erosion', 'X0.15 Mult per card below 52 in deck', 'erosion_enhanced'),
            make_option_box('Campfire', 'X0.1 per sell; loses X0.25 per blind beaten', 'campfire_enhanced'),
            make_cycle_box('Delayed Grat.', 'delayed_grat_mode', { 'Vanilla', '$2/Unused Discard', '$4 if 0 Used' }, 8.5),
            make_option_box('Throwback', 'X1.0 per skipped blind', 'throwback_enhanced'),
            make_option_box('Matador', '$5 per hand played in Boss Blind', 'matador_enhanced'),
            make_option_box('Yorick', '+1 retrigger all cards every 23 hands played', 'yorick_enhanced'),
            make_option_box('Mr. Bones', '25% threshold; destroys rightmost Joker', 'mr_bones_enhanced'),
            make_option_box('Séance', 'Creates a Negative Spectral', 'seance_enhanced'),
            make_option_box('Hit the Road', 'X0.75/Jack discarded; Jacks reshuffled', 'hit_the_road_enhanced'),
            make_option_box('Drunkard', '+1 discard on blind entry; Blueprint copyable', 'drunkard_enhanced'),
            make_option_box("Driver's License", 'X4 Mult at 16+ enhanced cards in deck', 'drivers_license_enhanced'),
            make_option_box('Merry Andy', '+3 discards, -1 hand size on blind entry', 'merry_andy_enhanced'),
            make_option_box('Mad Joker', '+10 Mult for Two Pair', 'mad_enhanced'),
            make_option_box('Crazy Joker', '+18 Mult for Straight', 'crazy_enhanced'),
            make_option_box('Droll Joker', '+15 Mult for Flush', 'droll_enhanced'),
            make_option_box('8 Ball', '1/3 chance per 8 scored', 'eight_ball_enhanced'),
            make_option_box('Hanging Chad', 'Uncommon/$6; retriggers first card 2x', 'hanging_chad_enhanced'),
            make_option_box('Space Joker', '1/3 chance to level up played hand', 'space_joker_enhanced'),
            make_option_box('Vagabond', 'Triggers at $8 or less', 'vagabond_enhanced'),
            make_option_box('Madness', '+0.75 Xmult per blind beaten', 'madness_enhanced'),
            make_option_box('Rocket', 'Starts at $2; +$2 per boss beaten', 'rocket_enhanced'),
            make_option_box('Golden Joker', '$6/round; costs $8', 'golden_enhanced'),
            make_option_box('Todo List', '$5 per discard', 'todo_list_enhanced'),
            make_option_box('Obelisk', 'X0.25 per consecutive most-played hand', 'obelisk_enhanced'),
            make_option_box('Onyx Agate', '+14 Mult', 'onyx_agate_enhanced'),
            make_option_box('Rough Gem', '$2 per Diamond scored', 'rough_gem_enhanced'),
            make_option_box('Mime', 'Rare; costs $8', 'mime_enhanced'),
            make_option_box('Baron', 'Rarity: Uncommon', 'baron_enhanced'),
            make_option_box('Mail-In Rebate', 'Rarity: Uncommon', 'mail_rebate_enhanced'),
            make_option_box('Marble Joker', 'Rarity: Common', 'marble_enhanced'),
            make_option_box('Golden Ticket', 'Uncommon; $5 per Gold Card scored', 'ticket_enhanced'),
            make_option_box('Smeared Joker', 'All cards ignore suit-based Boss Blind debuffs', 'smeared_enhanced'),
            make_option_box('Diet Cola', 'Double Tag at end of round, expires after 3 rounds', 'diet_cola_enhanced'),
        }
    elseif key == 'consumables' then
        return {
            make_option_box('The Lovers', 'Converts 2 cards to Wild', 'lovers_enhanced'),
            make_option_box('Enhancement Tarots', 'Chariot/Justice/Devil/Tower: 2 cards; Empress/Hierophant: 3',
                'tarot_enhance_enhanced'),
            make_option_box('Sigil / Ouija', 'Select a card to choose suit or rank', 'sigil_ouija_enhanced'),
            make_option_box('Buffed Soul', '0.5% chance in Tarot/Spectral packs', 'buffed_soul'),
            make_option_box('Buffed Black Hole', '1.5% chance in Planet packs', 'buffed_black_hole'),
            make_option_box('Wheel of Fortune', '1/3 chance to apply edition', 'wheel_of_fortune_enhanced'),
            make_option_box('Ectoplasm', 'Randomly -1 hand/-1 discard/-1 hand size', 'ectoplasm_enhanced'),
        }
    elseif key == 'tags' then
        return {
            make_option_box('Pack Tags', 'add pack to next shop', 'pack_tags_enhanced'),
            make_option_box('Tag Reworks', 'Orbital: 5 levels; Economy: $50', 'tag_reworks_enhanced'),
            make_option_box('Edition Tags', 'Foil/Holo/Polychrome/Negative Tags apply edition at purchase',
                'edition_tags_enhanced'),
            make_option_box('Joker Tags', 'Uncommon/Rare Tags directly spawn a Joker', 'joker_tags_enhanced'),
            make_option_box('Coupon Tag', 'Also adds a free random booster pack', 'coupon_tag_enhanced'),
            make_option_box('Garbage Tag', '$2 per unused discard', 'garbage_tag_enhanced'),
            make_option_box('Voucher Tag', 'Adds a free Voucher to the next shop', 'voucher_tag_enhanced'),
        }
    elseif key == 'decks' then
        return {
            make_option_box('Abandoned Deck', 'Face cards cannot appear', 'abandoned_enhanced'),
            make_option_box('Checkered Deck', 'Only Spades/Hearts; Clubs/Diamonds cannot appear', 'checkered_enhanced'),
            make_option_box('Anaglyph Deck', 'All tags gained are doubled (including Double Tags)', 'anaglyph_enhanced'),
            make_cycle_box('Painted Deck', 'painted_mode', { 'Vanilla', '-1 Hand/Round', '-1 Discard/Round' }),
            make_option_box('Black Deck', 'Start at Ante 0; keep -1 hand, +1 joker slot', 'black_deck_enhanced'),
            make_option_box('Nebula Deck', 'No -1 consumable slot penalty', 'nebula_enhanced'),
        }
    elseif key == 'enhancements' then
        return {
            make_option_box('Mult Card', '+6 Mult', 'mult_card_enhanced'),
            make_option_box('Stone Card', '+75 Chips', 'stone_card_enhanced'),
            make_option_box('Wild Card', 'Acts as *any* suit, not *all* suits', 'wild_card_enhanced'),
        }
    elseif key == 'vouchers' then
        return {
            make_option_box('Hieroglyph / Petroglyph', 'Swapped: Hieroglyph -1 discard; Petroglyph -1 hand',
                'hieroglyph_rework'),
            make_option_box('Tarot Tycoon', 'Every shop has a free Mega Arcana Pack', 'tarot_tycoon_enhanced'),
            make_option_box('Planet Tycoon', '1/2 Planet cards in shop are Negative', 'planet_tycoon_enhanced'),
            make_option_box('Magic Trick', 'Shop playing cards may have enhancements, editions, seals, and clips',
                'magic_trick_enhanced'),
            make_option_box('Illusion', 'Shop playing cards clone your deck and reroll copied upgrades',
                'illusion_enhanced'),
            make_option_box('Telescope', '1/2 chance Planet in shop matches most-played hand', 'telescope_enhanced'),
            make_option_box('Observatory', 'X2 Mult per Planet used', 'observatory_enhanced'),
        }
    elseif key == 'seals' then
        return {
            make_option_box('Blue Seal', 'Probability = cards in played hand / 5', 'blue_seal_enhanced'),
        }
    elseif key == 'editions' then
        return {
            make_option_box('Holo', '+20 Mult', 'holo_enhanced'),
        }
    elseif key == 'bosses' then
        return {
            make_option_box('The Wall', '3x chips instead of 4x', 'wall_enhanced'),
            --make_option_box('Finisher Blinds', '3x chips (Violet Vessel: 5x)',            'finisher_blinds_enhanced'),
        }
    elseif key == 'misc' then
        return {
            make_option_box('Stake Changes', 'All stake reworks (modifiers, reroll/interest/showdown changes)',
                'stakes_enhanced'),
            make_cycle_box('Blue Stake', 'blue_stake_mode', { 'Current', '+$2 Base Reroll' }, 8.5),
            make_option_box('Stake Scaling', 'Per-stake blind chip scaling; vanilla jumps at Green and Purple if off',
                'stake_scaling_enhanced'),
            make_option_box('Perishable Rework', 'Debuffs after 6 rounds instead of 5', 'perishable_enhanced'),
            make_option_box('Interest on Skip', 'Earn interest when skipping a blind', 'interest_on_skip'),
            make_option_box('Standard Packs', '4/6/6 cards', 'standard_packs_enhanced'),
        }
    elseif key == 'new_content' then
        return {}
        -- ── Tab 2: New Content ────────────────────────────────────────────────────
    elseif key == 'nc_jokers' then
        -- Jokers are grouped by theme/set; toggling a theme enables everything under it.
        return {}
    elseif key == 'nc_decks' then
        return {
            make_option_box('Workshop Deck', 'Start with Overstock and Clearance Sale; -1 hand', 'workshop_deck'),
            make_option_box('Magician Deck', 'Start with Magic Trick and Illusion vouchers', 'magician_deck'),
            make_cycle_box('Burnt Deck', 'burnt_mode', { 'Off', 'Start', 'Planet Levels' }),
            make_cycle_box('Anchor Deck', 'anchor_deck',
                { 'Off', 'Hand Locked', 'Fixed Rerolls' }, 8.5),
        }
    elseif key == 'nc_enhancements' then
        return {}
    elseif key == 'nc_seals' then
        return {}
    elseif key == 'nc_spectrals' then
        -- Note: hide any spectral whose only effect is creating a seal
        -- (i.e. it is made redundant by the seal existing directly).
        return {}
    elseif key == 'nc_tarots' then
        return {}
    elseif key == 'nc_vouchers' then
        return {
            make_option_box('Fork Tag Vouchers',
                'Split Tags (choose 1 of 2 on skip) and Fork Tags (gain both) + Fork Deck',
                'fork_tag_vouchers'),
        }
    elseif key == 'nc_tags' then
        return {}
    elseif key == 'nc_hand_types' then
        return {}
    elseif key == 'nc_boss_blinds' then
        return {}
    elseif key == 'nc_stakes' then
        return {}
    elseif key == 'nc_relics' then
        return {}
    elseif key == 'presets' then
        local code = reb4l_encode_config()
        local mid  = math.floor(#code / 2)
        return {
            -- Config code display
            {
                n = G.UIT.R,
                config = { align = 'cm', colour = G.C.L_BLACK, r = 0.1, padding = 0.15, emboss = 0.1 },
                nodes = { {
                    n = G.UIT.C,
                    config = { align = 'cm' },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = 'cm', padding = 0.04 },
                            nodes = {
                                { n = G.UIT.T, config = { text = 'Config Code', scale = 0.33, colour = G.C.WHITE } }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm', padding = 0.02 },
                            nodes = {
                                { n = G.UIT.T, config = { text = code:sub(1, mid), scale = 0.27, colour = HEX('b8c7d4') } }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm', padding = 0.02 },
                            nodes = {
                                { n = G.UIT.T, config = { text = code:sub(mid + 1), scale = 0.27, colour = HEX('b8c7d4') } }
                            }
                        },
                    }
                } }
            },
            -- Preset buttons: All Off | Suggested | All On
            {
                n = G.UIT.R,
                config = { align = 'cm', colour = G.C.L_BLACK, r = 0.1, padding = 0.15, emboss = 0.1 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = 'cm', padding = 0.06 },
                        nodes = {
                            UIBox_button({ label = { 'All Off' }, button = 'reb4l_preset_all_off', minw = 2.2, minh = 0.6, scale = 0.35, col = true, focus_args = { type = 'none' } })
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = 'cm', padding = 0.06 },
                        nodes = {
                            UIBox_button({ label = { 'Suggested' }, button = 'reb4l_preset_suggested', minw = 2.2, minh = 0.6, scale = 0.35, col = true, focus_args = { type = 'none' } })
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = 'cm', padding = 0.06 },
                        nodes = {
                            UIBox_button({ label = { 'All On' }, button = 'reb4l_preset_all_on', minw = 2.2, minh = 0.6, scale = 0.35, col = true, focus_args = { type = 'none' } })
                        }
                    },
                }
            },
            -- Clipboard buttons: Copy | Paste & Apply
            {
                n = G.UIT.R,
                config = { align = 'cm', colour = G.C.L_BLACK, r = 0.1, padding = 0.15, emboss = 0.1 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = 'cm', padding = 0.08 },
                        nodes = {
                            UIBox_button({ label = { 'Copy Code' }, button = 'reb4l_copy_config', minw = 3.2, minh = 0.6, scale = 0.35, col = true, focus_args = { type = 'none' } })
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = 'cm', padding = 0.08 },
                        nodes = {
                            UIBox_button({ label = { 'Paste & Apply' }, button = 'reb4l_paste_config', minw = 3.2, minh = 0.6, scale = 0.35, col = true, focus_args = { type = 'none' } })
                        }
                    },
                }
            },
        }
    end
    return {}
end

-- ─── Sidebar panel ────────────────────────────────────────────────────────────
-- Builds the category button list for the active tab.

local function build_sidebar_panel()
    local cats = categories_for_tab(REB4LANCED.UI.current_tab)
    local nodes = {}
    for _, cat in ipairs(cats) do
        local sel = cat.key == REB4LANCED.UI.current_category
        nodes[#nodes + 1] = {
            n = G.UIT.R,
            config = { align = 'cm', padding = 0.04 },
            nodes = { UIBox_button({
                id         = 'reb4l_cat_' .. cat.key,
                ref_table  = { key = cat.key },
                button     = 'reb4l_change_category',
                label      = { cat.label },
                minh       = 0.6,
                minw       = 2.6,
                col        = true,
                choice     = true,
                chosen     = sel and 'vert' or nil,
                scale      = 0.35,
                focus_args = { type = 'none' },
            }) }
        }
    end
    return {
        n = G.UIT.ROOT,
        config = { align = 'tl', colour = G.C.CLEAR, padding = 0.05 },
        nodes = { { n = G.UIT.C, config = { align = 'tl' }, nodes = nodes } }
    }
end

-- ─── Right-side content panel ─────────────────────────────────────────────────
-- Builds the paged options list for the currently selected category.

local function build_options_panel()
    local all                  = get_category_options(REB4LANCED.UI.current_category)
    local per                  = REB4LANCED.UI.options_per_page
    local total                = math.max(1, math.ceil(#all / per))
    local cur                  = math.min(REB4LANCED.UI.current_page, total)
    REB4LANCED.UI.current_page = cur

    local col                  = {}
    if #all == 0 then
        col[1] = {
            n = G.UIT.T,
            config = { text = 'No options in this category yet', scale = 0.35, colour = HEX('566d7a') }
        }
    else
        local s = (cur - 1) * per + 1
        local e = math.min(s + per - 1, #all)
        for i = s, e do
            if all[i] then col[#col + 1] = all[i] end
        end
    end

    if total > 1 then
        local page_opts = {}
        for i = 1, total do
            page_opts[#page_opts + 1] = localize('k_page') .. ' ' .. i .. '/' .. total
        end
        col[#col + 1] = SMODS.GUI.createOptionSelector({
            label          = '',
            scale          = 0.8,
            options        = page_opts,
            opt_callback   = 'reb4l_update_config_page',
            no_pips        = true,
            current_option = localize('k_page') .. ' ' .. cur .. '/' .. total,
            config         = { align = 'cm', padding = 0.15 }
        })
    end

    return {
        n = G.UIT.ROOT,
        config = { align = 'tl', colour = G.C.CLEAR, padding = 0.1 },
        nodes = { { n = G.UIT.C, config = { align = 'tl' }, nodes = col } }
    }
end

-- Rebuilds the content panel in-place (used after preset application).
local function reb4l_refresh_panel()
    local content = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('reb4lContent')
    if not (content and content.config.object) then return end
    content.config.object:remove()
    content.config.object = UIBox {
        definition = build_options_panel(),
        config     = { offset = { x = 0, y = 0 }, parent = content }
    }
    content.UIBox:recalculate()
end

-- Rebuilds the sidebar O-node (used when switching config tabs).
local function reb4l_refresh_sidebar()
    local sidebar = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('reb4lSidebar')
    if not (sidebar and sidebar.config.object) then return end
    sidebar.config.object:remove()
    sidebar.config.object = UIBox {
        definition = build_sidebar_panel(),
        config     = { offset = { x = 0, y = 0 }, parent = sidebar }
    }
    sidebar.UIBox:recalculate()
end

-- ─── Preset callbacks ─────────────────────────────────────────────────────────

G.FUNCS.reb4l_preset_all_off = function(_)
    for _, entry in ipairs(PRESET_KEYS) do
        if entry[2] == 'bool' then
            REB4LANCED.config[entry[1]] = false
        else
            REB4LANCED.config[entry[1]] = 1
        end
    end
    SMODS.save_mod_config(SMODS.current_mod)
    reb4l_refresh_panel()
end

G.FUNCS.reb4l_preset_all_on = function(_)
    for _, entry in ipairs(PRESET_KEYS) do
        REB4LANCED.config[entry[1]] = (entry[2] == 'bool') and true or entry[3]
    end
    SMODS.save_mod_config(SMODS.current_mod)
    reb4l_refresh_panel()
end

G.FUNCS.reb4l_preset_suggested = function(_)
    for k, v in pairs(SUGGESTED) do
        REB4LANCED.config[k] = v
    end
    SMODS.save_mod_config(SMODS.current_mod)
    reb4l_refresh_panel()
end

G.FUNCS.reb4l_copy_config = function(_)
    if love and love.system then
        love.system.setClipboardText(reb4l_encode_config())
    end
end

G.FUNCS.reb4l_paste_config = function(_)
    if not (love and love.system) then return end
    if reb4l_decode_and_apply(love.system.getClipboardText()) then
        reb4l_refresh_panel()
    end
end

-- Page change: the selector lives INSIDE the content UIBox, so e.UIBox can't see
-- 'reb4lContent' (it's in the outer UIBox). Use G.OVERLAY_MENU instead.
G.FUNCS.reb4l_update_config_page = function(e)
    if not e or not e.cycle_config then return end
    local opt = e.cycle_config.current_option
    if type(opt) == 'number' then REB4LANCED.UI.current_page = opt end
    local content = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('reb4lContent')
    if not (content and content.config.object) then return end
    content.config.object:remove()
    content.config.object = UIBox {
        definition = build_options_panel(),
        config     = { offset = { x = 0, y = 0 }, parent = content }
    }
    content.UIBox:recalculate()
end

-- ─── Tab-switch callback ───────────────────────────────────────────────────────
-- Switches between the two top-level config pages, rebuilds both O-nodes.

G.FUNCS.reb4l_switch_config_tab = function(e)
    if not e then return end
    local new_tab = e.config.ref_table.tab_num
    if REB4LANCED.UI.current_tab == new_tab then return end
    -- Clear old tab button's chosen indicator
    local old_btn = G.OVERLAY_MENU and
        G.OVERLAY_MENU:get_UIE_by_ID('reb4l_tab_' .. REB4LANCED.UI.current_tab)
    if old_btn then old_btn.config.chosen = nil end
    e.config.chosen                = true
    REB4LANCED.UI.current_tab      = new_tab
    REB4LANCED.UI.current_category = categories_for_tab(new_tab)[1].key
    REB4LANCED.UI.current_page     = 1
    reb4l_refresh_sidebar()
    reb4l_refresh_panel()
end

-- ─── Category switch callback ──────────────────────────────────────────────────
-- Sidebar buttons now live inside the reb4lSidebar O-node (its own UIBox),
-- so we look up reb4lContent via G.OVERLAY_MENU rather than e.UIBox.

G.FUNCS.reb4l_change_category = function(e)
    if not e then return end
    local content = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('reb4lContent')
    if not content then return end
    if content.config.oid == e.config.id then return end -- already on this tab

    -- Update chosen highlight
    if content.config.old_chosen then content.config.old_chosen.config.chosen = nil end
    content.config.old_chosen      = e
    e.config.chosen                = 'vert'
    content.config.oid             = e.config.id

    REB4LANCED.UI.current_category = e.config.ref_table.key
    REB4LANCED.UI.current_page     = 1

    content.config.object:remove()
    content.config.object = UIBox {
        definition = build_options_panel(),
        config = { offset = { x = 0, y = 0 }, parent = content }
    }
    content.UIBox:recalculate()
end

-- ─── Config tab ───────────────────────────────────────────────────────────────

SMODS.current_mod.config_tab = function()
    REB4LANCED.UI.current_tab      = 1
    REB4LANCED.UI.current_category = 'jokers'
    REB4LANCED.UI.current_page     = 1

    local stub                     = function()
        return UIBox {
            definition = { n = G.UIT.ROOT, config = { colour = G.C.CLEAR, minh = 0.1, minw = 0.1 }, nodes = {} },
            config     = { offset = { x = 0, y = 0 } },
        }
    end

    -- O-node for the sidebar (rebuilt when switching top tabs)
    local sidebar_node             = {
        n = G.UIT.O,
        config = { id = 'reb4lSidebar', object = stub() }
    }

    -- O-node for the content panel (rebuilt when switching category or page)
    local content_node             = {
        n = G.UIT.O,
        config = {
            id         = 'reb4lContent',
            oid        = 'reb4l_cat_jokers',
            old_chosen = nil,
            object     = stub(),
        }
    }

    -- Deferred init: attach proper parent refs so both O-nodes are cleaned up with the tab
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0,
        func = function()
            local sb = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('reb4lSidebar')
            if sb then
                if sb.config.object then sb.config.object:remove() end
                sb.config.object = UIBox {
                    definition = build_sidebar_panel(),
                    config     = { offset = { x = 0, y = 0 }, parent = sb },
                }
                sb.UIBox:recalculate()
            end
            local ct = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('reb4lContent')
            if ct then
                if ct.config.object then ct.config.object:remove() end
                ct.config.object = UIBox {
                    definition = build_options_panel(),
                    config     = { offset = { x = 0, y = 0 }, parent = ct },
                }
                ct.UIBox:recalculate()
            end
            return true
        end,
    }))

    -- Top tab buttons (Vanilla Changes | New Content)
    local tab_labels = { 'Reworks', 'New Content' }
    local tab_row = {}
    for i, label in ipairs(tab_labels) do
        tab_row[#tab_row + 1] = {
            n = G.UIT.C,
            config = { align = 'cm', padding = 0.05 },
            nodes = { UIBox_button({
                id         = 'reb4l_tab_' .. i,
                ref_table  = { tab_num = i },
                button     = 'reb4l_switch_config_tab',
                label      = { label },
                minh       = 0.55,
                minw       = 3.8,
                col        = true,
                choice     = true,
                chosen     = (i == 1) and true or nil,
                scale      = 0.35,
                focus_args = { type = 'none' },
            }) }
        }
    end

    return {
        n = G.UIT.ROOT,
        config = { emboss = 0.05, minh = 9, r = 0.1, minw = 12, align = 'cm', colour = G.C.BLACK },
        nodes = { {
            n = G.UIT.C, -- outer column: tab row on top, sidebar+content below
            config = { align = 'tl', padding = 0.1, colour = G.C.BLACK },
            nodes = {
                -- Top: page tab buttons
                { n = G.UIT.R, config = { align = 'cm', padding = 0.05 }, nodes = tab_row },
                -- Bottom: sidebar | content
                {
                    n = G.UIT.R,
                    config = { align = 'cl', padding = 0.0 },
                    nodes = {
                        { n = G.UIT.C, config = { align = 'tl', padding = 0.05 },                         nodes = { sidebar_node } },
                        { n = G.UIT.C, config = { align = 'tl', padding = 0.05, minw = 8.5, minh = 8.0 }, nodes = { content_node } },
                    }
                },
            }
        } }
    }
end
