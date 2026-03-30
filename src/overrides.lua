-- Card:is_suit override
-- Wild Cards resist suit-based debuffs (can never be suit-debuffed).
-- When a suit-debuff blind is active, Wild Cards count as all suits EXCEPT the debuffed suit.
-- Same suit-debuff resistance applies to all cards when Smeared Joker is in play.
function Card:is_suit(suit, bypass_debuff, flush_calc, trying_to_debuff)
    if not flush_calc and self.debuff and not bypass_debuff then
        return nil
    end
    if self.ability.effect == 'Stone Card' then
        return false
    end
    -- Wild Cards resist suit-based debuffs; count as all suits except the active debuffed suit
    if self.ability.name == "Wild Card" then
        if trying_to_debuff then return false end
        local debuffed_suit = G.GAME and G.GAME.blind and G.GAME.blind.debuff and G.GAME.blind.debuff.suit
        if debuffed_suit and suit == debuffed_suit then return false end
        return not flush_calc or not self.debuff
    end
    -- Smeared Joker cards also resist suit-based debuffs
    if REB4LANCED.config.smeared_enhanced then
        local has_smeared = next(find_joker('Smeared Joker'))
        if has_smeared then
            if trying_to_debuff then return false end
            local is_base_red = self.base.suit == 'Hearts' or self.base.suit == 'Diamonds'
            local is_target_red = suit == 'Hearts' or suit == 'Diamonds'
            if is_base_red == is_target_red then return true end
        end
    end
    return self.base.suit == suit
end

-- Blind:debuff_card override
-- Passes trying_to_debuff = true when checking suit debuffs so Wild Cards
-- (and Smeared Joker cards) resist only suit-based debuffs via is_suit.
function Blind:debuff_card(card, from_blind)
    if self.debuff and not self.disabled and card.area ~= G.jokers then
        if self.debuff.suit and card:is_suit(self.debuff.suit, true, nil, true) then
            card:set_debuff(true); return
        end
        if self.debuff.is_face == 'face' and card:is_face(true) then
            card:set_debuff(true); return
        end
        if self.name == 'The Pillar' and card.ability.played_this_ante then
            card:set_debuff(true); return
        end
        if self.debuff.value and self.debuff.value == card.base.value then
            card:set_debuff(true); return
        end
        if self.debuff.nominal and self.debuff.nominal == card.base.nominal then
            card:set_debuff(true); return
        end
    end
    if self.name == 'Crimson Heart' and not self.disabled and card.area == G.jokers then return end
    if self.name == 'Verdant Leaf' and not self.disabled and card.area ~= G.jokers then
        card:set_debuff(true); return
    end
    card:set_debuff(false)
end


-- Anaglyph Deck: copy every tag gained (except Double Tags and tags spawned by Double Tag)
local reb4l_orig_add_tag = add_tag
function add_tag(tag, ...)
    reb4l_orig_add_tag(tag, ...)
    if G.GAME and G.GAME.reb4l_anaglyph_active and not G.GAME.reb4l_dt_firing
    and tag and tag.key ~= 'tag_double' and tag.key ~= 'double' then
        if tag.ability and tag.ability.orbital_hand then
            G.orbital_hand = tag.ability.orbital_hand
        end
        reb4l_orig_add_tag(Tag(tag.key), ...)
        G.orbital_hand = nil
    end
end

-- Edition Tags (enhanced): apply edition to a joker at purchase time
local reb4l_orig_buy_card = Card.buy_card
function Card:buy_card(from_area)
    local result = reb4l_orig_buy_card(self, from_area)
    if self.ability and self.ability.set == 'Joker'
    and not self.edition and G.GAME and G.GAME.tags then
        local edition_map = {
            tag_negative   = 'e_negative',   negative   = 'e_negative',
            tag_foil       = 'e_foil',       foil       = 'e_foil',
            tag_holo       = 'e_holo',       holo       = 'e_holo',
            tag_polychrome = 'e_polychrome', polychrome = 'e_polychrome',
        }
        for i = 1, #G.GAME.tags do
            local tag = G.GAME.tags[i]
            if tag and not tag.triggered and edition_map[tag.key] then
                local edition_key = edition_map[tag.key]
                local joker_card = self
                local lock = tag.ID
                G.CONTROLLER.locks[lock] = true
                tag:yep('+', G.C.DARK_EDITION, function()
                    joker_card:set_edition(edition_key, true)
                    G.CONTROLLER.locks[lock] = nil
                    return true
                end)
                tag.triggered = true
                break
            end
        end
    end
    return result
end

-- Gold Stake: showdown boss blinds every N antes (controlled by showdown_interval modifier)
-- get_new_boss uses G.GAME.win_ante to determine showdown frequency; we temporarily
-- swap it with showdown_interval so win_ante (run length) stays unaffected.
local reb4l_orig_get_new_boss = get_new_boss
function get_new_boss()
    if not (G.GAME and G.GAME.modifiers and G.GAME.modifiers.showdown_interval) then
        return reb4l_orig_get_new_boss()
    end
    local real_win_ante = G.GAME.win_ante
    G.GAME.win_ante = G.GAME.modifiers.showdown_interval
    local result = reb4l_orig_get_new_boss()
    G.GAME.win_ante = real_win_ante
    return result
end

-- Interest on skip
if REB4LANCED.config.interest_on_skip then
    local reb4l_orig_skip_blind = G.FUNCS.skip_blind
    G.FUNCS.skip_blind = function(e)
        local interest_base = G.GAME.interest_base or 5
        local interest_amount = G.GAME.interest_amount or 1
        local interest_cap = G.GAME.interest_cap or 25
        if G.GAME.dollars >= 1 and not G.GAME.modifiers.no_interest then
            local earned = interest_amount * math.min(math.floor(G.GAME.dollars / interest_base), interest_cap / interest_base)
            if earned >= 1 then ease_dollars(earned) end
        end
        return reb4l_orig_skip_blind(e)
    end
end


-- Chicot (modes 2 & 3): Card:add_to_deck has a hardcoded ability.name == 'Chicot' check
-- (card.lua:777) that fires AFTER SMODS's add_to_deck hook, unconditionally disabling the boss
-- blind. Block it by temporarily marking the blind as already disabled so the check is a no-op.
if REB4LANCED.config.chicot_mode ~= 1 then
    local reb4l_orig_add_to_deck = Card.add_to_deck
    function Card:add_to_deck(from_debuff)
        local fake_disabled = self.ability and self.ability.name == 'Chicot'
            and G.GAME and G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled
        if fake_disabled then G.GAME.blind.disabled = true end
        reb4l_orig_add_to_deck(self, from_debuff)
        if fake_disabled then G.GAME.blind.disabled = false end
    end
end

-- Chicot Echo Tags (mode 3): intercept add_tag to record tags gained from blind skips
if REB4LANCED.config.chicot_mode == 3 then
    local reb4l_orig_add_tag = add_tag
    function add_tag(tag, ...)
        if G.GAME and G.GAME.reb4l_tracking_skip then
            G.GAME.reb4l_skip_tags = G.GAME.reb4l_skip_tags or {}
            G.GAME.reb4l_skip_tags[#G.GAME.reb4l_skip_tags + 1] = tag.key
        end
        return reb4l_orig_add_tag(tag, ...)
    end
    -- Wrap skip_blind to set tracking flag (wraps the interest override if present)
    local reb4l_chicot_orig_skip = G.FUNCS.skip_blind
    G.FUNCS.skip_blind = function(e)
        if G.GAME then G.GAME.reb4l_tracking_skip = true end
        local result = reb4l_chicot_orig_skip(e)
        if G.GAME then G.GAME.reb4l_tracking_skip = false end
        return result
    end
end

-- Card:set_base wrapper for Checkered and Abandoned deck effects.
-- context.create_card / context.modify_playing_card are CardSleeves-specific contexts
-- injected via their own set_base wrapper, not standard SMODS Back:calculate contexts.
-- We replicate that pattern here so our deck effects fire from the same hook point.
local reb4l_orig_set_base = Card.set_base
function Card:set_base(card, initial)
    local output = reb4l_orig_set_base(self, card, initial)
    if not (G.GAME and G.GAME.reb4l_deck) then return output end
    if not (self.ability and (self.ability.set == "Default" or self.ability.set == "Enhanced")
        and self.config and self.config.card_key) then
        return output
    end

    if G.GAME.reb4l_deck == 'checkered' then
        local remap = { Clubs = 'Spades', Diamonds = 'Hearts' }
        local to_suit = remap[self.base.suit]
        if to_suit then
            local suit_key = SMODS.Suits[to_suit].card_key
            local rank_obj = SMODS.Ranks[self.base.value]
            if suit_key and rank_obj then
                local base_key = suit_key .. "_" .. rank_obj.card_key
                if G.P_CARDS[base_key] then
                    self:set_base(G.P_CARDS[base_key], initial)
                end
            end
        end
    elseif G.GAME.reb4l_deck == 'abandoned' then
        local rank = SMODS.Ranks[self.base.value]
        if rank and rank.face then
            local suit_obj = SMODS.Suits[self.base.suit]
            if suit_obj then
                local candidates = {}
                for _, r in pairs(SMODS.Ranks) do
                    if not r.face then
                        local base_key = suit_obj.card_key .. "_" .. r.card_key
                        if G.P_CARDS[base_key] then
                            candidates[#candidates + 1] = G.P_CARDS[base_key]
                        end
                    end
                end
                if #candidates > 0 then
                    table.sort(candidates, function(a, b) return (a.name or "") < (b.name or "") end)
                    self:set_base(
                        pseudorandom_element(candidates, pseudoseed('reb4l_abandoned')),
                        initial
                    )
                end
            end
        end
    end

    return output
end

-- Game:update safety net: clear suit-based debuffs from Wild Cards each frame
-- Belt-and-suspenders alongside the debuff_card override above.
-- Only runs when the active blind has a suit debuff; other debuffs still apply.
local reb4l_orig_game_update = Game.update
function Game:update(dt)
    reb4l_orig_game_update(self, dt)
    if G.playing_cards and G.GAME and G.GAME.blind and G.GAME.blind.debuff and G.GAME.blind.debuff.suit then
        for _, v in ipairs(G.playing_cards) do
            if v.debuff and v.config.center and v.config.center.key == 'm_wild' then
                v.debuff = false
            end
        end
    end
end

-- create_card_for_shop override for Magic Trick / Illusion voucher reworks
-- Magic Trick: playing cards may spawn with random enhancement, edition, or seal
-- Illusion: playing cards are clones of a random card from the player's deck (no upgrade rerolls)
local reb4l_orig_create_card_for_shop = create_card_for_shop
function create_card_for_shop(area)
    local card = reb4l_orig_create_card_for_shop(area)
    if card and card.ability and (card.ability.set == 'Default' or card.ability.set == 'Enhanced') then
        local has_magic   = G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers['v_magic_trick']
        local has_illusion = G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers['v_illusion']

        if has_illusion and G.playing_cards and #G.playing_cards > 0 then
            -- Clone a random deck card: copy base, enhancement, edition, seal
            local deck_card = pseudorandom_element(
                G.playing_cards,
                pseudoseed('reb4l_illusion' .. (G.GAME.round_resets and G.GAME.round_resets.ante or 1))
            )
            if deck_card then
                card:set_base(G.P_CARDS[deck_card.config.card_key])
                if deck_card.edition  then card:set_edition(deck_card.edition) end
                if deck_card.seal     then card:set_seal(deck_card.seal) end
                if deck_card.config.center.set == 'Enhanced' then
                    card:set_ability(deck_card.config.center)
                    if card.config.card_key and G.P_CARDS[card.config.card_key] then
                        card:set_base(G.P_CARDS[card.config.card_key])
                    end
                end
            end
        elseif has_magic then
            -- Random enhancement (~40% chance via mod=2.5)
            local enh = SMODS.poll_enhancement({ key = 'reb4l_magic_enh', mod = 2.5 })
            if enh then
                card:set_ability(G.P_CENTERS[enh])
                if card.config.card_key and G.P_CARDS[card.config.card_key] then
                    card:set_base(G.P_CARDS[card.config.card_key])
                end
            end
            -- Random edition
            local ed = poll_edition('reb4l_magic_ed', 1, false, false)
            if ed then card:set_edition(ed) end
            -- Random seal (~20% chance via mod=10)
            local seal = SMODS.poll_seal({ key = 'reb4l_magic_seal', mod = 10 })
            if seal then card:set_seal(seal) end
        end

        -- Recalculate cost if anything was added
        if has_magic or has_illusion then
            local extra = 0
            if card.edition then
                extra = extra + (card.edition.polychrome and 3 or 2)
            end
            if card.seal then extra = extra + 1 end
            if card.ability.set == 'Enhanced' then extra = extra + 1 end
            card.cost = math.max(1, math.floor(
                (card.base_cost + extra + 0.5) * (100 - G.GAME.discount_percent) / 100
            ))
            card.sell_cost = math.max(1, math.floor(card.cost / 2)) + (card.ability.extra_value or 0)
            card.sell_cost_label = card.sell_cost
        end
    end

    -- Telescope: 50% chance to replace a shop Planet with most-played hand's planet
    if card and card.ability and card.ability.set == 'Planet'
        and G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers['v_telescope'] then
        if pseudorandom(pseudoseed('reb4l_telescope')) < 0.5 then
            local best_hand, best_tally = nil, 0
            for _, handname in ipairs(G.handlist) do
                if SMODS.is_poker_hand_visible and SMODS.is_poker_hand_visible(handname)
                    and G.GAME.hands[handname] and G.GAME.hands[handname].played > best_tally then
                    best_hand = handname
                    best_tally = G.GAME.hands[handname].played
                end
            end
            if best_hand and best_tally > 0 then
                for _, v in pairs(G.P_CENTER_POOLS['Planet'] or {}) do
                    if v.config and v.config.hand_type == best_hand then
                        card:set_ability(G.P_CENTERS[v.key])
                        break
                    end
                end
            end
        end
    end

    return card
end

-- Card:set_cost override: ensure from_tag couponed cards are always free
local reb4l_orig_set_cost = Card.set_cost
function Card:set_cost()
    reb4l_orig_set_cost(self)
    if self.from_tag and self.ability and self.ability.couponed then
        self.cost = 0
    end
end

-- Per-stake chip scaling and Red Stake payout reduction
-- Maps vanilla stake keys to our internal difficulty index 1-8.
-- G.GAME.stake is a pool index that shifts when mods add stakes; using the key is stable.
local reb4l_stake_index = {
    stake_white  = 1,
    stake_red    = 2,
    stake_green  = 3,
    stake_black  = 4,
    stake_blue   = 5,
    stake_purple = 6,
    stake_orange = 7,
    stake_gold   = 8,
}

-- reb4l_base_chips: Small Blind base values for antes 1-8, indexed [stake][ante]
local reb4l_base_chips = {
    [1] = {  300,   800,  2000,  5000, 11000,  20000,  35000,  50000 },  -- White
    [2] = {  300,   850,  2200,  5600, 12500,  23000,  41000,  60000 },  -- Red
    [3] = {  300,   900,  2400,  6400, 14500,  27000,  49000,  75000 },  -- Green
    [4] = {  300,   950,  2700,  7400, 17000,  32000,  60000,  90000 },  -- Black
    [5] = {  300,  1000,  3000,  8600, 20000,  39000,  75000, 110000 },  -- Blue
    [6] = {  300,  1050,  3400, 10000, 24000,  50000,  95000, 135000 },  -- Purple
    [7] = {  300,  1125,  3900, 12000, 30000,  65000, 125000, 165000 },  -- Orange
    [8] = {  300,  1200,  4500, 14500, 38000,  85000, 160000, 200000 },  -- Gold
}

-- Vanilla White Stake Small Blind values for antes 9-14.
-- Used as the endless-mode growth reference for all stakes:
-- base(stake, ante) = (our_ante8[stake] / 50000) * vanilla_white[ante]
-- This mimics vanilla's ramping but anchored to each stake's ante-8 target.
local reb4l_vw = { 110000, 560000, 7200000, 300000000, 47000000000, 29000000000000 }
--                  ^ante9   ^10       ^11        ^12          ^13          ^14

-- Returns the vanilla White Stake Small Blind base for any ante.
-- For ante > 14, extrapolates via chip(N) ≈ 4 * chip(N-1)^2 / chip(N-2),
-- which matches the observed step-multiplier converging to ×4 per ante.
local function reb4l_vanilla_white(ante)
    if ante <= 8 then return reb4l_base_chips[1][ante] end
    local idx = ante - 8
    if reb4l_vw[idx] then return reb4l_vw[idx] end
    local a, b = reb4l_vw[5], reb4l_vw[6]  -- antes 13 and 14
    for _ = 15, ante do
        a, b = b, 4 * b * b / a
    end
    return b
end

-- Red Stake: also show reduced payout on the blind select screen.
-- The select screen bakes blind_choice.config.dollars (G.P_BLINDS[key].dollars) as a
-- static text node, so temporarily patch the value, call original, then restore it.
local reb4l_orig_UIBox_blind_choice = create_UIBox_blind_choice
function create_UIBox_blind_choice(type, run_info)
    local restored = {}
    if G.GAME and G.GAME.modifiers and G.GAME.modifiers.reb4l_payout_decrease
        and G.GAME.round_resets and G.GAME.round_resets.blind_choices then
        local dec = G.GAME.modifiers.reb4l_payout_decrease
        local key = G.GAME.round_resets.blind_choices[type]
        if key and G.P_BLINDS[key] and _G['type'](G.P_BLINDS[key].dollars) == 'number' then
            restored[key] = G.P_BLINDS[key].dollars
            G.P_BLINDS[key].dollars = math.max(0, G.P_BLINDS[key].dollars - dec)
        end
    end
    local result = reb4l_orig_UIBox_blind_choice(type, run_info)
    for k, v in pairs(restored) do G.P_BLINDS[k].dollars = v end
    return result
end

local reb4l_orig_blind_set_blind = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
    local result = reb4l_orig_blind_set_blind(self, blind, reset, silent)
    if not reset and G.GAME and G.GAME.round_resets then
        local ante  = G.GAME.round_resets.ante
        local stake = reb4l_stake_index[SMODS.stake_from_index(G.GAME.stake)]
        -- Per-stake chip scaling
        if REB4LANCED.config.blind_scaling_enhanced
            and ante and stake then
            local base
            if ante <= 8 then
                base = reb4l_base_chips[stake][ante]
            else
                local vw = reb4l_vanilla_white(ante)
                base = math.ceil(reb4l_base_chips[stake][8] / 50000 * vw)
            end
            local mult = self.mult or 1
            if base then
                self.chips     = math.ceil(base * mult)
                self.chip_text = number_format(self.chips)
                if G.HUD_blind then G.HUD_blind:recalculate() end
            end
        end
        -- Red Stake payout reduction (self.dollars is the blind payout field in blind.lua)
        if G.GAME.modifiers and G.GAME.modifiers.reb4l_payout_decrease
            and self.dollars and type(self.dollars) == 'number' then
            self.dollars = math.max(0, self.dollars - G.GAME.modifiers.reb4l_payout_decrease)
            G.GAME.current_round.dollars_to_be_earned =
                self.dollars > 0 and string.rep(localize('$'), self.dollars) or ''
        end
    end
    return result
end

-- Black Stake: discarded cards are reshuffled into the deck.
-- Must wrap G.FUNCS.discard_cards_from_highlighted, not the pre_discard context:
-- pre_discard fires BEFORE draw_card events are queued, so an event queued there
-- would land ahead of the discard animations. Wrapping the FUNCS entry point lets
-- us queue the reshuffle AFTER the original runs (and its draw_card events are queued).
local reb4l_orig_discard_highlighted = G.FUNCS.discard_cards_from_highlighted
G.FUNCS.discard_cards_from_highlighted = function(e, hook)
    local to_reshuffle = {}
    if REB4LANCED.config.black_stake_enhanced
        and G.GAME and G.GAME.stake and G.GAME.stake >= 4
        and G.hand and G.hand.highlighted then
        for _, card in ipairs(G.hand.highlighted) do
            to_reshuffle[#to_reshuffle + 1] = card
        end
    end
    reb4l_orig_discard_highlighted(e, hook)
    if #to_reshuffle > 0 then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            blocking = true,
            blockable = true,
            func = function()
                for i, card in ipairs(to_reshuffle) do
                    draw_card(G.discard, G.deck, (i * 100) / #to_reshuffle, 'back', true, card)
                end
                G.deck:shuffle('reb4l_black_' .. G.GAME.hands_played .. '_' .. (G.GAME.current_round.discards_left or 0))
                return true
            end
        }))
    end
end

local reb4l_orig_level_up_hand = level_up_hand
function level_up_hand(card, hand, instant, amount, statustext)
    reb4l_orig_level_up_hand(card, hand, instant, amount, statustext)
    local levels = (amount and amount > 0) and amount or 1
    if G.jokers then
        for _, joker in ipairs(G.jokers.cards) do
            if joker.config.center.key == 'j_constellation' and not joker.debuff then
                joker.ability.extra.Xmult = joker.ability.extra.Xmult + joker.ability.extra.Xmult_mod * levels
                joker:juice_up(0.5, 0.3)
            end
        end
    end
    -- Satellite mode 3: fire per-level-up earning through SMODS context so Blueprint/Brainstorm copy it
    if REB4LANCED.config.satellite_mode == 3 then
        SMODS.calculate_context({ satellite_level_up = true, levels = levels })
    end
end
