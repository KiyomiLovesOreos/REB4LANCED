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
    -- Deck changes
    abandoned_enhanced = false,
    checkered_enhanced = false,
    anaglyph_enhanced = false,
    painted_mode = 1,
    nebula_enhanced = false,
    -- Stake changes
    stakes_enhanced = false,
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
            make_cycle_box('Chicot', 'chicot_mode', { 'Vanilla', '-33% Blind Chips', 'Skip Tags' }),
            make_option_box('Bloodstone',       '1/3 chance for X2 Mult on Hearts',              'bloodstone_enhanced'),
            make_cycle_box('The Idol', 'idol_mode', { 'Vanilla', 'Rare/X2.5', 'Fixed Rank/Suit' }),
            make_option_box('Seeing Double',    'X1.25 per scoring card (Club + other suit)',      'seeing_double_enhanced'),
            make_option_box('Flower Pot',       '+15 Chips per scoring Wild Card',                 'flower_pot_enhanced'),
            make_cycle_box('Satellite', 'satellite_mode', { 'Vanilla', 'End of Round', 'On Level Up' }),
            make_option_box('Constellation',    'X0.1 Mult gain on any hand level-up',             'constellation_enhanced'),
            make_option_box('Splash',           'Every played card scores; debuffs cleared',       'splash_enhanced'),
            make_option_box('Superposition',    'Creates The Fool if hand is Straight + Ace',      'superposition_enhanced'),
            make_option_box('Bootstraps',       '+1 Mult per $5 per scoring Heart/Diamond',        'bootstraps_enhanced'),
            make_option_box('Bull',             '+3 Chips per $5 per scoring Spade/Club',          'bull_enhanced'),
            make_option_box('Erosion',          'X0.15 Mult per card below 52 in deck',            'erosion_enhanced'),
            make_option_box('Campfire',         'X0.1 per sell; loses X0.25 per blind beaten',     'campfire_enhanced'),
            make_cycle_box('Delayed Grat.', 'delayed_grat_mode', { 'Vanilla', '$2/Unused Discard', '$4 if 0 Used' }, 8.5),
            make_option_box('Throwback',        'X1.0 per skipped blind',                          'throwback_enhanced'),
            make_option_box('Matador',          '$5 per hand played in Boss Blind',                'matador_enhanced'),
            make_option_box('Yorick',           '+1 retrigger all cards every 23 hands played',    'yorick_enhanced'),
            make_option_box('Mr. Bones',        '25% threshold; destroys rightmost Joker',         'mr_bones_enhanced'),
            make_option_box('Séance',           'Creates a Negative Spectral',                     'seance_enhanced'),
            make_option_box('Hit the Road',     'X0.75/Jack discarded; Jacks reshuffled',          'hit_the_road_enhanced'),
            make_option_box('Drunkard',         '+1 discard on blind entry; Blueprint copyable',   'drunkard_enhanced'),
            make_option_box("Driver's License", 'X4 Mult at 16+ enhanced cards in deck',          'drivers_license_enhanced'),
            make_option_box('Merry Andy',       '+3 discards, -1 hand size on blind entry',        'merry_andy_enhanced'),
            make_option_box('Mad Joker',        '+10 Mult for Two Pair',                           'mad_enhanced'),
            make_option_box('Crazy Joker',      '+18 Mult for Straight',                           'crazy_enhanced'),
            make_option_box('Droll Joker',      '+15 Mult for Flush',                              'droll_enhanced'),
            make_option_box('8 Ball',           '1/3 chance per 8 scored',                         'eight_ball_enhanced'),
            make_option_box('Hanging Chad',     'Uncommon/$6; retriggers first card 2x',           'hanging_chad_enhanced'),
            make_option_box('Space Joker',      '1/3 chance to level up played hand',              'space_joker_enhanced'),
            make_option_box('Vagabond',         'Triggers at $8 or less',                          'vagabond_enhanced'),
            make_option_box('Madness',          '+0.75 Xmult per blind beaten',                    'madness_enhanced'),
            make_option_box('Rocket',           'Starts at $2; +$2 per boss beaten',               'rocket_enhanced'),
            make_option_box('Golden Joker',     '$6/round; costs $8',                              'golden_enhanced'),
            make_option_box('Todo List',        '$5 per discard',                                  'todo_list_enhanced'),
            make_option_box('Obelisk',          'X0.25 per consecutive most-played hand',          'obelisk_enhanced'),
            make_option_box('Onyx Agate',       '+14 Mult',                                        'onyx_agate_enhanced'),
            make_option_box('Rough Gem',        '$2 per Diamond scored',                           'rough_gem_enhanced'),
            make_option_box('Mime',             'Rare; costs $8',                                  'mime_enhanced'),
            make_option_box('Baron',            'Rarity: Uncommon',                                'baron_enhanced'),
            make_option_box('Mail-In Rebate',   'Rarity: Uncommon',                                'mail_rebate_enhanced'),
            make_option_box('Marble Joker',     'Rarity: Common',                                  'marble_enhanced'),
            make_option_box('Golden Ticket',    'Uncommon; $5 per Gold Card scored',               'ticket_enhanced'),
            make_option_box('Smeared Joker',    'All cards ignore suit-based Boss Blind debuffs',  'smeared_enhanced'),
            make_option_box('Diet Cola',          'Double Tag at end of round, expires after 3 rounds',          'diet_cola_enhanced'),
        }
    elseif key == 'consumables' then
        return {
            make_option_box('The Lovers',         'Converts 2 cards to Wild',                      'lovers_enhanced'),
            make_option_box('Enhancement Tarots', 'Chariot/Justice/Devil/Tower: 2 cards; Empress/Hierophant: 3','tarot_enhance_enhanced'),
            make_option_box('Sigil / Ouija',      'Select a card to choose suit or rank',                       'sigil_ouija_enhanced'),
            make_option_box('Buffed Soul',        '0.5% chance in Tarot/Spectral packs',  'buffed_soul'),
            make_option_box('Buffed Black Hole',  '1.5% chance in Planet packs',          'buffed_black_hole'),
            make_option_box('Wheel of Fortune',   '1/3 chance to apply edition',                'wheel_of_fortune_enhanced'),
            make_option_box('Ectoplasm',          'Randomly -1 hand/-1 discard/-1 hand size', 'ectoplasm_enhanced'),
        }
    elseif key == 'tags' then
        return {
            make_option_box('Pack Tags',     'add pack to next shop', 'pack_tags_enhanced'),
            make_option_box('Tag Reworks',   'Orbital: 5 levels; Economy: $50',    'tag_reworks_enhanced'),
            make_option_box('Edition Tags',  'Foil/Holo/Polychrome/Negative Tags apply edition at purchase',      'edition_tags_enhanced'),
            make_option_box('Joker Tags',    'Uncommon/Rare Tags directly spawn a Joker',  'joker_tags_enhanced'),
            make_option_box('Coupon Tag',    'Also adds a free random booster pack',   'coupon_tag_enhanced'),
            make_option_box('Garbage Tag',   '$2 per unused discard',               'garbage_tag_enhanced'),
            make_option_box('Voucher Tag',   'Adds a free Voucher to the next shop', 'voucher_tag_enhanced'),
        }
    elseif key == 'decks' then
        return {
            make_option_box('Abandoned Deck',  'Face cards cannot appear',                'abandoned_enhanced'),
            make_option_box('Checkered Deck',  'Only Spades/Hearts; Clubs/Diamonds cannot appear',           'checkered_enhanced'),
            make_option_box('Anaglyph Deck',   'All tags gained are doubled (including Double Tags)',         'anaglyph_enhanced'),
            make_cycle_box('Painted Deck', 'painted_mode', { 'Vanilla', '-1 Hand/Round', '-1 Discard/Round' }),
            make_option_box('Nebula Deck',     'No -1 consumable slot penalty',                              'nebula_enhanced'),
        }
    elseif key == 'enhancements' then
        return {
            make_option_box('Mult Card',   '+6 Mult',                                           'mult_card_enhanced'),
            make_option_box('Stone Card',  '+75 Chips',                                        'stone_card_enhanced'),
            make_option_box('Wild Card',   'Acts as *any* suit, not *all* suits',                           'wild_card_enhanced'),
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
            --make_option_box('Finisher Blinds', '3x chips (Violet Vessel: 5x)',            'finisher_blinds_enhanced'),
        }
    elseif key == 'misc' then
        return {
            make_option_box('Stake Changes',     'All stake reworks (scaling, modifiers, reroll/interest/showdown changes)', 'stakes_enhanced'),
            make_option_box('Perishable Rework', 'Debuffs after 6 rounds instead of 5', 'perishable_enhanced'),
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

    -- Right content: O node. The initial UIBox is a stub; a deferred event immediately
    -- replaces it with one that has parent = content so it gets destroyed with the tab.
    local stub = UIBox {
        definition = { n = G.UIT.ROOT, config = { colour = G.C.CLEAR, minh = 0.1, minw = 0.1 }, nodes = {} },
        config     = { offset = { x = 0, y = 0 } },
    }
    local content_node = {
        n = G.UIT.O,
        config = {
            id          = 'reb4lContent',
            oid         = 'reb4l_cat_jokers',
            old_chosen  = nil,
            object      = stub,
        }
    }
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0,
        func = function()
            local ref = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('reb4lContent')
            if ref then
                if ref.config.object then ref.config.object:remove() end
                ref.config.object = UIBox {
                    definition = build_options_panel(),
                    config     = { offset = { x = 0, y = 0 }, parent = ref },
                }
                ref.UIBox:recalculate()
            end
            return true
        end,
    }))

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
