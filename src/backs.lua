-- Only the decks that have REB4LANCED-specific behavior get take_ownership.
-- Keys use the vanilla identifier WITHOUT the 'b_' class prefix.

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
