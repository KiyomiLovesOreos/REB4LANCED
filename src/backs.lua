-- Only the 3 decks that have REB4LANCED-specific behavior get take_ownership.
-- Keys use the vanilla identifier WITHOUT the 'b_' class prefix.

-- Abandoned Deck: face cards cannot appear anywhere (packs, shop, Strength tarot, etc.)
-- Card replacement is handled by the Card:set_base wrapper in overrides.lua.
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

-- Checkered Deck: Diamonds/Clubs cannot appear anywhere; converts starting deck on apply
-- Ongoing card replacement is handled by the Card:set_base wrapper in overrides.lua.
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

-- Anaglyph Deck: sets flag for the add_tag doubling override
-- Vanilla already gives Double Tag after each boss blind — we only add the doubling behaviour
SMODS.Back:take_ownership('anaglyph', {
    loc_txt = {
        name = "Anaglyph Deck",
        text = {
            "After each {C:attention}Boss Blind{} is defeated,",
            "receive a {C:attention}Double Tag",
            "All other tags gained are also doubled",
            "{C:inactive}(Double Tags are not doubled)",
        },
    },
    apply = function(self, back)
        G.GAME.reb4l_anaglyph_active = true
    end,
}, false)

-- Painted Deck: -1 hand per round instead of -1 joker slot (joker_size patched in patches.lua)
SMODS.Back:take_ownership('painted', {
    loc_txt = {
        name = "Painted Deck",
        text = {
            "Start with {C:attention}+2{} hand size,",
            "{C:blue}-1{} hand per round",
        },
    },
    apply = function(self, back)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
    end,
}, false)

-- Nebula Deck: remove -1 consumable slot penalty (consumeable_size patched in patches.lua)
-- Vanilla apply still runs, giving the Telescope voucher. No other effect.
SMODS.Back:take_ownership('nebula', {
    loc_txt = {
        name = "Nebula Deck",
        text = {
            "Start with {C:attention,T:v_telescope}Telescope{} Voucher",
        },
    },
}, false)
