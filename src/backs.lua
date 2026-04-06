-- Only the decks that have REB4LANCED-specific behavior get take_ownership.
-- Keys use the vanilla identifier WITHOUT the 'b_' class prefix.

-- Atlas for new REB4LANCED decks (placeholder sprite sheet; replace with real art later).
SMODS.Atlas({
    key  = 'decks',
    path = 'Decks.png',
    px   = 71,
    py   = 95,
})

-- Abandoned Deck: face cards cannot appear anywhere (packs, shop, Strength tarot, etc.)
-- Card replacement is handled by the Card:set_base wrapper in overrides.lua.
if REB4LANCED.config.abandoned_enhanced then
SMODS.Back:take_ownership('abandoned', {
    loc_txt = {
        name = "Abandoned Deck",
        text = {
            "Start run without any {C:attention}Face Cards{}",
            "{C:attention}Face Cards{} cannot appear",
        },
    },
    apply = function(self, back)
        G.GAME.reb4l_deck = 'abandoned'
    end,
}, false)
end

-- Checkered Deck: Diamonds/Clubs cannot appear anywhere; converts starting deck on apply
-- Ongoing card replacement is handled by the Card:set_base wrapper in overrides.lua.
if REB4LANCED.config.checkered_enhanced then
SMODS.Back:take_ownership('checkered', {
    loc_txt = {
        name = "Checkered Deck",
        text = {
            "Start with {C:spades}26 Spades{} and {C:hearts}26 Hearts{}",
            "{C:clubs}Clubs{} and {C:diamonds}Diamonds{} cannot appear",
        },
    },
    apply = function(self, back)
        G.GAME.reb4l_deck = 'checkered'
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, v in pairs(G.playing_cards) do
                    if v.base.suit == 'Clubs' then
                        v:change_suit('Spades')
                    elseif v.base.suit == 'Diamonds' then
                        v:change_suit('Hearts')
                    end
                end
                return true
            end
        }))
    end,
}, false)
end

-- Anaglyph Deck: every tag gained creates one more of itself (deck passive, no Double Tag needed).
-- The vanilla boss-beat Double Tag is suppressed by lovely/anaglyph.toml.
if REB4LANCED.config.anaglyph_enhanced then
SMODS.Back:take_ownership('anaglyph', {
    loc_txt = {
        name = "Anaglyph Deck",
        text = {
            "Gain {C:attention}2{} of every {C:attention}Tag",
            "{C:inactive}instead of {C:attention}1",
        },
    },
    apply = function(self, back)
        G.GAME.reb4l_anaglyph_active = true
    end,
}, false)
end

-- Black Deck: start at Ante 0 (keeps vanilla -1 hand, +1 joker slot)
if REB4LANCED.config.black_deck_enhanced then
SMODS.Back:take_ownership('black', {
    loc_txt = {
        name = "Black Deck",
        text = {
            "Start at {C:attention}Ante 0{},",
            "{C:red}-1{} Hand, {C:attention}+1{} Joker slot",
        },
    },
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
    apply = function(self, back)
        G.GAME.modifiers.reb4l_start_ante_zero = true
    end,
}, false)
end

-- Painted Deck: -1 hand or -1 discard per round instead of -1 joker slot (joker_size patched in patches.lua)
-- painted_mode: 1=Vanilla, 2=-1 Hand/Round, 3=-1 Discard/Round
if REB4LANCED.config.painted_mode and REB4LANCED.config.painted_mode > 1 then
SMODS.Back:take_ownership('painted', {
    loc_txt = {
        name = "Painted Deck",
        text = {
            "Start with {C:attention}+2{} hand size,",
            "{C:blue}-1{} {C:attention}#1#{} per round",
        },
    },
    loc_vars = function(self, info_queue)
        local mode = REB4LANCED.config.painted_mode or 2
        return { vars = { mode == 3 and 'discard' or 'hand' } }
    end,
    apply = function(self, back)
        local mode = REB4LANCED.config.painted_mode or 2
        if mode == 3 then
            G.GAME.round_resets.discards = G.GAME.round_resets.discards - 1
        else
            G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
        end
    end,
}, false)
end

-- Nebula Deck: remove -1 consumable slot penalty (consumeable_size patched in patches.lua)
-- Vanilla config.voucher = 'v_telescope' gives Telescope; we also grant Observatory.
if REB4LANCED.config.nebula_enhanced then
SMODS.Back:take_ownership('nebula', {
    loc_txt = {
        name = "Nebula Deck",
        text = {
            "Start with {C:attention,T:v_telescope}Telescope{}",
            "and {C:attention,T:v_observatory}Observatory{} Vouchers",
        },
    },
    apply = function(self, back)
        -- Vanilla handles Telescope via config.voucher; we add Observatory on top.
        G.GAME.used_vouchers['v_observatory'] = true
        G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
        G.E_MANAGER:add_event(Event({
            func = function()
                Card.apply_to_run(nil, G.P_CENTERS['v_observatory'])
                return true
            end
        }))
    end,
}, false)
end

-- ── New Content Decks ─────────────────────────────────────────────────────────

-- Burnt Deck (mode 2): start with half the deck randomly destroyed.
-- Scorched Deck (mode 3): after each hand, level down the played hand (min 1)
--   and destroy half the scoring cards.
-- Both share one SMODS.Back with loc_txt and behavior driven by burnt_mode.
if REB4LANCED.config.burnt_mode and REB4LANCED.config.burnt_mode > 1 then
local burnt_mode = REB4LANCED.config.burnt_mode
SMODS.Back({
    key = 'burnt',
    atlas = 'decks',
    pos = { x = 2, y = 0 },
    loc_txt = {
        name = burnt_mode == 3 and 'Burnt Deck' or 'Burnt Deck',
        text = burnt_mode == 3 and {
            'After playing a hand,',
            '{C:red}level down{} the played hand {C:inactive}(min 1){}',
            'and {C:red}destroy{} half of scoring cards',
        } or {
            'Start with {C:red}half{} the deck',
            '{C:red}destroyed{} at random',
        },
    },
    config = {},
    apply = function(self)
        if burnt_mode ~= 2 then return end
        G.E_MANAGER:add_event(Event({
            func = function()
                local cards = {}
                for i = 1, #G.playing_cards do cards[i] = G.playing_cards[i] end
                local n = #cards
                local num_remove = math.floor(n / 2)
                if num_remove <= 0 then return true end
                for i = n, 2, -1 do
                    local j = math.floor(pseudorandom('burnt_destroy_' .. i) * i) + 1
                    cards[i], cards[j] = cards[j], cards[i]
                end
                for i = n - num_remove + 1, n do
                    local card = cards[i]
                    card:remove()
                    for k = #G.playing_cards, 1, -1 do
                        if G.playing_cards[k] == card then
                            table.remove(G.playing_cards, k)
                            break
                        end
                    end
                end
                return true
            end
        }))
    end,
    calculate = function(self, back, context)
        if burnt_mode ~= 3 then return end
        if not context.after then return end
        local hand_name = context.scoring_name
        if not hand_name then return end
        local h = G.GAME.hands[hand_name]
        if not h or h.level <= 1 then return end
        h.level = h.level - 1
        h.mult  = math.max(h.s_mult  + h.l_mult  * (h.level - 1), 1)
        h.chips = math.max(h.s_chips + h.l_chips * (h.level - 1), 0)
        local scoring = context.scoring_hand or {}
        local n = #scoring
        local to_remove = math.floor(n / 2)
        if to_remove > 0 then
            local pool = {}
            for _, c in ipairs(scoring) do pool[#pool + 1] = c end
            for i = #pool, 2, -1 do
                local j = math.floor(pseudorandom('scorched_' .. i) * i) + 1
                pool[i], pool[j] = pool[j], pool[i]
            end
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = 1, to_remove do
                        local card = pool[i]
                        if card and card.added_to_deck then
                            card:start_dissolve(nil, nil, 1.4)
                        end
                    end
                    return true
                end
            }))
        end
    end,
})
end

-- Anchor Deck: hand size is permanently locked; change_size on G.hand is a no-op.
-- The actual blocking happens in the CardArea.change_size override in overrides.lua.
if REB4LANCED.config.anchor_deck then
SMODS.Back({
    key = 'anchor',
    atlas = 'decks',
    pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'Anchor Deck',
        text = {
            '{C:attention}Hand size{} is {C:attention}locked{}',
            '{C:inactive}(Cannot be gained or lost)',
        },
    },
    config = {},
    apply = function(self)
        G.GAME.reb4l_anchor_deck = true
    end,
})
end

-- Workshop Deck: Overstock + Clearance Sale vouchers, -1 hand per round.
if REB4LANCED.config.workshop_deck then
SMODS.Back({
    key = 'workshop',
    atlas = 'decks',
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Workshop Deck',
        text = {
            'Start with {C:attention,T:v_overstock_norm}Overstock{}',
            'and {C:attention,T:v_clearance_sale}Clearance Sale{} vouchers,',
            '{C:red}-1{} Hand per round',
        },
    },
    config = {},
    apply = function(self)
        -- Grant both vouchers manually.
        for _, key in ipairs({ 'v_overstock_norm', 'v_clearance_sale' }) do
            G.GAME.used_vouchers[key] = true
            G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
            local k = key
            G.E_MANAGER:add_event(Event({
                func = function()
                    Card.apply_to_run(nil, G.P_CENTERS[k])
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
                G.GAME.current_round.hands_left = G.GAME.current_round.hands_left - 1
                return true
            end
        }))
    end,
})
end

-- Fork Deck: Split Tags + Fork Tags vouchers from the start.
if REB4LANCED.config.fork_tag_vouchers then
SMODS.Back({
    key   = 'fork',
    atlas = 'decks',
    pos   = { x = 4, y = 0 },   -- placeholder sprite
    loc_txt = {
        name = 'Fork Deck',
        text = {
            'Start with {C:attention,T:v_reb4l_split_tag}Split Tags{}',
            'and {C:attention,T:v_reb4l_fork_tag}Fork Tags{} vouchers',
        },
    },
    config = {},
    apply = function(self)
        for _, key in ipairs({ 'v_reb4l_split_tag', 'v_reb4l_fork_tag' }) do
            G.GAME.used_vouchers[key] = true
            G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
            local k = key
            G.E_MANAGER:add_event(Event({
                func = function()
                    Card.apply_to_run(nil, G.P_CENTERS[k])
                    return true
                end
            }))
        end
    end,
})
end

-- Magician Deck: Magic Trick + Illusion vouchers from the start.
if REB4LANCED.config.magician_deck then
SMODS.Back({
    key = 'magician',
    atlas = 'decks',
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'Magician Deck',
        text = {
            'Start with {C:attention,T:v_magic_trick}Magic Trick{}',
            'and {C:attention,T:v_illusion}Illusion{} vouchers',
        },
    },
    config = {},
    apply = function(self)
        for _, key in ipairs({ 'v_magic_trick', 'v_illusion' }) do
            G.GAME.used_vouchers[key] = true
            G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
            local k = key
            G.E_MANAGER:add_event(Event({
                func = function()
                    Card.apply_to_run(nil, G.P_CENTERS[k])
                    return true
                end
            }))
        end
    end,
})
end

-- Burnt Deck: ~half the starting deck is randomly destroyed.
if REB4LANCED.config.burnt_deck then
SMODS.Back({
    key = 'burnt',
    atlas = 'decks',
    pos = { x = 2, y = 0 },
    loc_txt = {
        name = 'Burnt Deck',
        text = {
            'Start with {C:red}half{} the deck',
            '{C:red}destroyed{} at random',
        },
    },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local cards = {}
                for i = 1, #G.playing_cards do
                    cards[i] = G.playing_cards[i]
                end
                local n = #cards
                local num_remove = math.floor(n / 2)
                if num_remove <= 0 then return true end
                -- Fisher-Yates shuffle, then remove the last num_remove cards.
                for i = n, 2, -1 do
                    local j = math.floor(pseudorandom('burnt_destroy_' .. i) * i) + 1
                    cards[i], cards[j] = cards[j], cards[i]
                end
                for i = n - num_remove + 1, n do
                    local card = cards[i]
                    card:remove()
                    for k = #G.playing_cards, 1, -1 do
                        if G.playing_cards[k] == card then
                            table.remove(G.playing_cards, k)
                            break
                        end
                    end
                end
                return true
            end
        }))
    end,
})
end
