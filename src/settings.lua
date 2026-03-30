REB4LANCED = REB4LANCED or {}
REB4LANCED.config = SMODS.current_mod.config
REB4LANCED.UI = REB4LANCED.UI or {}

-- Apply defaults for any missing settings
local defaults = {
    bloodstone_enhanced = true,    -- 1/3 for X2 instead of vanilla 1/2 for X1.5
    idol_enhanced = true,          -- X2.5 instead of vanilla X2
    interest_on_skip = true,       -- earn interest when skipping a blind
    tarot_suit_enhanced = true,    -- suit tarots convert up to 4 instead of vanilla 3
    lovers_enhanced = true,        -- The Lovers converts 2 cards instead of vanilla 1
    tarot_enhance_enhanced = true, -- enhancement tarots affect +1 more card than vanilla
    buffed_soul = true,            -- 1% chance in Tarot/Spectral packs
    buffed_black_hole = true,      -- 7.5% chance in Planet packs
    diet_cola_enhanced = true,     -- Double Tag at end of round (3 uses) instead of on sell
    sigil_ouija_enhanced = true,   -- Sigil/Ouija: select card to choose suit/rank
    pack_tags_enhanced = true,     -- pack tags add mega pack to next shop
    tag_reworks_enhanced = true,   -- D6: 3 free rerolls; Orbital: 5 levels; Economy: $50; etc.
    chicot_mode = 2,               -- 1=vanilla, 2=reduce boss blind 33%, 3=echo tags on boss defeat
    -- Joker reworks
    satellite_mode = 2,               -- 1=vanilla, 2=end-of-round $/2-per-level, 3=immediate $1-per-level-up
    flower_pot_enhanced = true,
    seeing_double_enhanced = true,
    constellation_enhanced = true,
    splash_enhanced = true,
    superposition_enhanced = true,
    bootstraps_enhanced = true,
    bull_enhanced = true,
    erosion_enhanced = true,
    delayed_grat_mode = 2,
    throwback_enhanced = true,
    matador_enhanced = true,
    yorick_enhanced = true,
    mr_bones_enhanced = true,
    seance_enhanced = true,
    campfire_enhanced = true,
    drunkard_enhanced = true,
    hit_the_road_enhanced = true,
    drivers_license_enhanced = true,
    merry_andy_enhanced = true,
    -- Joker stat buffs
    mad_enhanced = true,
    crazy_enhanced = true,
    droll_enhanced = true,
    eight_ball_enhanced = true,
    hanging_chad_enhanced = true,
    space_joker_enhanced = true,
    vagabond_enhanced = true,
    madness_enhanced = true,
    rocket_enhanced = true,
    golden_enhanced = true,
    todo_list_enhanced = true,
    obelisk_enhanced = true,
    onyx_agate_enhanced = true,
    rough_gem_enhanced = true,
    -- Joker rarity/cost changes
    mime_enhanced = true,
    smeared_enhanced = true,
    baron_enhanced = true,
    mail_rebate_enhanced = true,
    marble_enhanced = true,
    ticket_enhanced = true,
    -- Enhancement changes
    mult_card_enhanced = true,
    stone_card_enhanced = true,
    wild_card_enhanced = true,
    -- Edition changes
    holo_enhanced = true,
    -- Seal changes
    blue_seal_enhanced = true,
    -- Deck changes
    abandoned_enhanced = true,
    checkered_enhanced = true,
    anaglyph_enhanced = true,
    painted_enhanced = true,
    nebula_enhanced = true,
    -- Stake changes
    red_stake_enhanced = true,
    blue_stake_enhanced = true,
    green_stake_enhanced = true,
    black_stake_enhanced = true,
    purple_stake_enhanced = true,
    orange_stake_enhanced = true,
    gold_stake_enhanced = true,
    blind_scaling_enhanced = true,
    -- Boss blind changes
    wall_enhanced = true,
    finisher_blinds_enhanced = true,
    -- Tag changes
    edition_tags_enhanced = true,
    joker_tags_enhanced = true,
    coupon_tag_enhanced = true,
    -- Voucher changes
    hieroglyph_rework = true,
    tarot_tycoon_enhanced = true,
    planet_tycoon_enhanced = true,
    magic_trick_enhanced = true,
    illusion_enhanced = true,
    telescope_enhanced = true,
    observatory_enhanced = true,
    -- Consumable changes
    ectoplasm_enhanced = true,
    wheel_of_fortune_enhanced = true,
    -- Misc
    standard_packs_enhanced = true,
}
for k, v in pairs(defaults) do
    if REB4LANCED.config[k] == nil then
        REB4LANCED.config[k] = v
    end
end

REB4LANCED.UI.options_per_page  = 4
REB4LANCED.UI.current_page      = 1
REB4LANCED.UI.current_category  = 'jokers'

-- ─── Category definitions ──────────────────────────────────────────────────────
local categories_list = {
    { key = 'jokers',       label = 'Jokers'       },
    { key = 'consumables',  label = 'Consumables'  },
    { key = 'tags',         label = 'Tags'         },
    { key = 'decks',        label = 'Decks'        },
    { key = 'enhancements', label = 'Enhancements' },
    { key = 'vouchers',     label = 'Vouchers'     },
    { key = 'seals',        label = 'Seals'        },
    { key = 'editions',     label = 'Editions'     },
    { key = 'bosses',       label = 'Bosses'       },
    { key = 'stakes',       label = 'Stakes'       },
    { key = 'new_content',  label = 'New Content'  },
    { key = 'misc',         label = 'Misc'         },
}

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
            make_cycle_box('Chicot', 'chicot_mode', { 'Vanilla', 'Reduce Blind', 'Tags' }),
            make_option_box('Bloodstone',       '1/3 for X2 Mult',                               'bloodstone_enhanced'),
            make_option_box('The Idol',         'Rare, $8, X2.5 Mult',                           'idol_enhanced'),
            make_option_box('Seeing Double',    'X1.25 per scored card',   'seeing_double_enhanced'),
            make_option_box('Flower Pot',       '+15 Chips per Wild in hand', 'flower_pot_enhanced'),
            make_cycle_box('Satellite', 'satellite_mode', { 'Vanilla', 'End of Round', 'On Level Up' }),
            make_option_box('Constellation',    'Gains on any hand level-up', 'constellation_enhanced'),
            make_option_box('Splash',           'Every played card scores; debuffs cleared', 'splash_enhanced'),
            make_option_box('Superposition',    'Creates The Fool if hand is Straight + Ace', 'superposition_enhanced'),
            make_option_box('Bootstraps',       '+1 Mult per $5, Hearts/Diamonds only', 'bootstraps_enhanced'),
            make_option_box('Bull',             '+1 Chip per $5, Spades/Clubs only', 'bull_enhanced'),
            make_option_box('Erosion',          'X0.15 per card below 52', 'erosion_enhanced'),
            make_option_box('Campfire',         'Gains X0.1/sell, loses X0.25/blind', 'campfire_enhanced'),
            make_cycle_box('Delayed Grat.', 'delayed_grat_mode', { 'Vanilla', '$2/Unused', '$4 if None Used' }, 8.5),
            make_option_box('Throwback',        'X0.5 per skipped blind',        'throwback_enhanced'),
            make_option_box('Matador',          '$5 every hand in boss blind', 'matador_enhanced'),
            make_option_box('Yorick',           'Retriggers all played cards', 'yorick_enhanced'),
            make_option_box('Mr. Bones',        '25% threshold; destroys rightmost Joker', 'mr_bones_enhanced'),
            make_option_box('Séance',           'Creates a Negative Spectral', 'seance_enhanced'),
            make_option_box('Hit the Road',     'X0.75/Jack, reshuffled into deck', 'hit_the_road_enhanced'),
            make_option_box('Drunkard',         '+1 discard on blind, Blueprint/Brainstorm copyable', 'drunkard_enhanced'),
            make_option_box("Driver's License", '12 enhanced cards threshold',       'drivers_license_enhanced'),
            make_option_box('Merry Andy',       '+3 discards on blind, Blueprint/Brainstorm copyable', 'merry_andy_enhanced'),
            make_option_box('Mad Joker',        '+10 Mult for Two Pair',             'mad_enhanced'),
            make_option_box('Crazy Joker',      '+18 Mult for Straight',            'crazy_enhanced'),
            make_option_box('Droll Joker',      '+15 Mult for Flush',               'droll_enhanced'),
            make_option_box('8 Ball',           '1/2 chance per 8 scored',          'eight_ball_enhanced'),
            make_option_box('Hanging Chad',     'Uncommon/$6, retriggers first card 2x', 'hanging_chad_enhanced'),
            make_option_box('Space Joker',      '1/3 chance to level up',           'space_joker_enhanced'),
            make_option_box('Vagabond',         'Triggers at $8 or less',    'vagabond_enhanced'),
            make_option_box('Madness',          '+0.75 Xmult per blind',           'madness_enhanced'),
            make_option_box('Rocket',           'Starts at $2',                      'rocket_enhanced'),
            make_option_box('Golden Joker',     '$6/round, costs $8',      'golden_enhanced'),
            make_option_box('Todo List',        '$5 per discard',                    'todo_list_enhanced'),
            make_option_box('Obelisk',          'X0.25 per hand',                  'obelisk_enhanced'),
            make_option_box('Onyx Agate',       '+14 Mult',                          'onyx_agate_enhanced'),
            make_option_box('Rough Gem',        '$2 per Diamond scored',             'rough_gem_enhanced'),
            make_option_box('Mime',             'Rare/$8',                  'mime_enhanced'),
            make_option_box('Baron',            'Uncommon',                        'baron_enhanced'),
            make_option_box('Mail-In Rebate',   'Uncommon',                      'mail_rebate_enhanced'),
            make_option_box('Marble Joker',     'Common',                      'marble_enhanced'),
            make_option_box('Golden Ticket',    'Uncommon',                      'ticket_enhanced'),
            make_option_box('Smeared Joker',    'All cards ignore suit-based Boss Blind debuffs',  'smeared_enhanced'),
        }
    elseif key == 'consumables' then
        return {
            make_option_box('Diet Cola',          'Double Tag at end of round, expires after 3 rounds',          'diet_cola_enhanced'),
            make_option_box('Suit Tarots',        'Star/Moon/Sun/World convert up to 4 cards',                  'tarot_suit_enhanced'),
            make_option_box('The Lovers',         'Converts 2 cards to Wild',                      'lovers_enhanced'),
            make_option_box('Enhancement Tarots', 'Chariot/Justice/Devil/Tower: 2 cards; Empress/Hierophant: 3','tarot_enhance_enhanced'),
            make_option_box('Sigil / Ouija',      'Select a card to choose suit or rank',                       'sigil_ouija_enhanced'),
            make_option_box('Buffed Soul',        '1% chance in Tarot/Spectral packs',                         'buffed_soul'),
            make_option_box('Buffed Black Hole',  '3% chance in Planet packs',                                 'buffed_black_hole'),
            make_option_box('Wheel of Fortune',   '1/3 chance to apply edition',                'wheel_of_fortune_enhanced'),
            make_option_box('Ectoplasm',          'Randomly -1 hand/-1 discard/-1 hand size', 'ectoplasm_enhanced'),
        }
    elseif key == 'tags' then
        return {
            make_option_box('Pack Tags',     'add pack to next shop', 'pack_tags_enhanced'),
            make_option_box('Tag Reworks',   'Orbital: 5 levels; Economy: $50; D6: 3 free rerolls; and more',    'tag_reworks_enhanced'),
            make_option_box('Edition Tags',  'Foil/Holo/Polychrome/Negative Tags apply edition at purchase',      'edition_tags_enhanced'),
            make_option_box('Joker Tags',    'Uncommon/Rare Tags directly spawn a Joker',  'joker_tags_enhanced'),
            make_option_box('Coupon Tag',    'Also adds a free random booster pack',   'coupon_tag_enhanced'),
        }
    elseif key == 'decks' then
        return {
            make_option_box('Abandoned Deck',  'Face cards cannot appear',                'abandoned_enhanced'),
            make_option_box('Checkered Deck',  'Only Spades/Hearts; Clubs/Diamonds cannot appear',           'checkered_enhanced'),
            make_option_box('Anaglyph Deck',   'All tags gained are doubled (not Double Tags)',               'anaglyph_enhanced'),
            make_option_box('Painted Deck',    '-1 hand per round instead of -1 Joker slot',                 'painted_enhanced'),
            make_option_box('Nebula Deck',     'No -1 consumable slot penalty',                              'nebula_enhanced'),
        }
    elseif key == 'enhancements' then
        return {
            make_option_box('Mult Card',   '+6 Mult',                                           'mult_card_enhanced'),
            make_option_box('Stone Card',  '+75 Chips',                                        'stone_card_enhanced'),
            make_option_box('Wild Card',   'Resists suit-based Boss Blind debuffs',                           'wild_card_enhanced'),
        }
    elseif key == 'vouchers' then
        return {
            make_option_box('Hieroglyph / Petroglyph', 'Swapped: Hieroglyph -1 discard; Petroglyph -1 hand', 'hieroglyph_rework'),
            make_option_box('Tarot Tycoon',   'Every shop has a free Mega Arcana Pack',                      'tarot_tycoon_enhanced'),
            make_option_box('Planet Tycoon',  '1/2 Planet cards in shop are Negative',                       'planet_tycoon_enhanced'),
            make_option_box('Magic Trick',    'Shop playing cards may have enhancements, editions, seals',   'magic_trick_enhanced'),
            make_option_box('Illusion',       'Shop playing cards are clones of cards in your deck',         'illusion_enhanced'),
            make_option_box('Telescope',      '1/2 chance Planet in shop matches most-played hand',          'telescope_enhanced'),
            make_option_box('Observatory',    'X2 Mult per Planet used',                     'observatory_enhanced'),
        }
    elseif key == 'seals' then
        return {
            make_option_box('Blue Seal', 'Probability = cards in played hand / 5',       'blue_seal_enhanced'),
        }
    elseif key == 'editions' then
        return {
            make_option_box('Holo', '+20 Mult',                                                'holo_enhanced'),
        }
    elseif key == 'bosses' then
        return {
            make_option_box('The Wall',        '3x chips instead of 4x',                 'wall_enhanced'),
            make_option_box('Finisher Blinds', '3x chips (Violet Vessel: 5x)',            'finisher_blinds_enhanced'),
        }
    elseif key == 'stakes' then
        return {
            make_option_box('Blind Scaling',  'Per-stake chip targets (scales with stake)',    'blind_scaling_enhanced'),
            make_option_box('Red Stake',     '$1 less payout per blind',               'red_stake_enhanced'),
            make_option_box('Green Stake',   'Eternal Jokers available in shop',       'green_stake_enhanced'),
            make_option_box('Black Stake',   'Discards reshuffled into deck',          'black_stake_enhanced'),
            make_option_box('Blue Stake',    '+2 win ante',                            'blue_stake_enhanced'),
            make_option_box('Purple Stake',  'Perishable Jokers available in shop',    'purple_stake_enhanced'),
            make_option_box('Orange Stake',  'Rental Jokers available in shop',        'orange_stake_enhanced'),
            make_option_box('Gold Stake',    'Showdown Boss Blinds every 5 antes',     'gold_stake_enhanced'),
        }
    elseif key == 'misc' then
        return {
            make_option_box('Interest on Skip',  'Earn interest when skipping a blind',  'interest_on_skip'),
            make_option_box('Standard Packs',    '4/6/6 cards',                          'standard_packs_enhanced'),
        }
    elseif key == 'new_content' then
        return {
        }
    end
    return {}
end

-- ─── Right-side content panel ─────────────────────────────────────────────────
-- Builds the paged options list for the currently selected category.

local function build_options_panel()
    local all = get_category_options(REB4LANCED.UI.current_category)
    local per   = REB4LANCED.UI.options_per_page
    local total = math.max(1, math.ceil(#all / per))
    local cur   = math.min(REB4LANCED.UI.current_page, total)
    REB4LANCED.UI.current_page = cur

    local col = {}
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

-- ─── Category switch callback ──────────────────────────────────────────────────
-- Mirrors Cartomancer's cartomancer_settings_change_tab pattern:
--   e.UIBox:get_UIE_by_ID searches within the same UIBox that owns the button.

G.FUNCS.reb4l_change_category = function(e)
    if not e then return end
    local content = e.UIBox:get_UIE_by_ID('reb4lContent')
    if not content then return end
    if content.config.oid == e.config.id then return end  -- already on this tab

    -- Update chosen highlight
    if content.config.old_chosen then content.config.old_chosen.config.chosen = nil end
    content.config.old_chosen = e
    e.config.chosen = 'vert'
    content.config.oid = e.config.id

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
    REB4LANCED.UI.current_category = 'jokers'
    REB4LANCED.UI.current_page     = 1

    -- Left sidebar: vertical stack of category buttons
    local sidebar = {}
    for _, cat in ipairs(categories_list) do
        local sel = cat.key == REB4LANCED.UI.current_category
        sidebar[#sidebar + 1] = {
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

    -- Right content: O node with UIBox built synchronously (no Event needed)
    local content_node = {
        n = G.UIT.O,
        config = {
            id          = 'reb4lContent',
            oid         = 'reb4l_cat_jokers',  -- matches initial chosen button id
            old_chosen  = nil,                  -- filled in after first render
            object      = UIBox {
                definition = build_options_panel(),
                config     = { offset = { x = 0, y = 0 } }
            }
        }
    }

    return {
        n = G.UIT.ROOT,
        config = { emboss = 0.05, minh = 9, r = 0.1, minw = 12, align = 'cm', colour = G.C.BLACK },
        nodes = { {
            n = G.UIT.R,  -- horizontal: sidebar | content
            config = { align = 'cl', padding = 0.1, colour = G.C.BLACK },
            nodes = {
                -- Left: category sidebar
                { n = G.UIT.C, config = { align = 'tl', padding = 0.05 }, nodes = sidebar },
                -- Right: options panel (fixed size so empty categories don't collapse the panel)
                { n = G.UIT.C, config = { align = 'tl', padding = 0.05, minw = 8.5, minh = 8.2 }, nodes = { content_node } },
            }
        } }
    }
end
