-- Only jokers that actually differ from vanilla get take_ownership.
-- Keys use the vanilla identifier WITHOUT the 'j_' class prefix.

-- Satellite: mode-selectable rework
-- Mode 1 (Vanilla): $1 per planet card used this run
-- Mode 2: earns $ceil(highest_hand_level / 2) at end of round
-- Mode 3: earns $1 per level immediately on any hand level-up; Blueprint/Brainstorm copyable
if REB4LANCED.config.satellite_mode == 2 then
SMODS.Joker:take_ownership('satellite', {
    loc_txt = {
        name = 'Satellite',
        text = {
            'Earn {C:money}$#1#{} at end of round for every',
            '{C:attention}2{} levels of your highest poker hand',
            '{C:inactive}(Currently {C:money}$#2#{C:inactive})',
        },
    },
    loc_vars = function(self, info_queue, card)
        local highest = 0
        for _, hand in pairs(G.GAME and G.GAME.hands or {}) do
            local lv = type(hand.level) == 'number' and hand.level
                or tonumber(tostring(hand.level)) or 0
            if lv > highest then highest = lv end
        end
        return { vars = { card.ability.extra, math.ceil(highest / 2) } }
    end,
    calc_dollar_bonus = function(self, card)
        if card.debuff then return end
        local highest = 0
        for _, hand in pairs(G.GAME.hands) do
            local lv = type(hand.level) == 'number' and hand.level
                or tonumber(tostring(hand.level)) or 0
            if lv > highest then highest = lv end
        end
        local amount = math.ceil(highest / 2)
        if amount > 0 then return amount end
    end,
}, false)
elseif REB4LANCED.config.satellite_mode == 3 then
SMODS.Joker:take_ownership('satellite', {
    loc_txt = {
        name = 'Satellite',
        text = {
            'Earns {C:money}$1{} each time any',
            '{C:planet}Poker Hand{} levels up',
            '{C:inactive}(Orbital Tag: {C:money}+$5{C:inactive})',
        },
    },
    calculate = function(self, card, context)
        if context.satellite_level_up and not card.debuff then
            local earn = context.levels or 1
            ease_dollars(earn)
            card:juice_up(0.3, 0.4)
            return { message = localize{type='variable', key='a_dollars', vars={earn}}, colour = G.C.MONEY }
        end
    end,
}, false)
end

-- Flower Pot: each scoring Wild Card gives +15 Chips (stacking per wild)
if REB4LANCED.config.flower_pot_enhanced then
SMODS.Joker:take_ownership('flower_pot', {
    config = { extra = 15 },
    loc_txt = {
        name = 'Flower Pot',
        text = {
            'scored {C:attention}Wild Card{}',
            'give {C:chips}+#1#{} Chips per',
            '{C:attention}Wild Card{} in played hand',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return nil, true  -- block vanilla's all-suits X3 dispatch; we handle chips in individual
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_wild' then
                local wild_count = 0
                for _, c in ipairs(context.scoring_hand) do
                    if c.config.center.key == 'm_wild' then wild_count = wild_count + 1 end
                end
                return { chips = card.ability.extra * wild_count }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.flower_pot_enhanced

-- Delayed Gratification: mode-selectable rework
-- Mode 1 (Vanilla): $2 per unused discard if no discards used this round
-- Mode 2: $2 per unused discard regardless of discards used
-- Mode 3: $4 per unused discard if no discards used this round
if REB4LANCED.config.delayed_grat_mode and REB4LANCED.config.delayed_grat_mode ~= 1 then
local _mode = REB4LANCED.config.delayed_grat_mode
SMODS.Joker:take_ownership('delayed_grat', {
    loc_txt = {
        name = 'Delayed Gratification',
        text = (_mode == 2) and {
            'Earn {C:money}$2{} for each',
            '{C:attention}Discard{} not used this round',
        } or {
            'Earn {C:money}$4{} for each',
            '{C:attention}Discard{} not used this round',
            'if {C:attention}no discards{} were used',
        },
    },
    calc_dollar_bonus = function(self, card)
        if card.debuff then return end
        local unused = G.GAME.current_round.discards_left or 0
        if _mode == 2 then
            if unused > 0 then return unused * 2 end
        elseif _mode == 3 then
            if (G.GAME.current_round.discards_used or 0) == 0 and unused > 0 then
                return unused * 4
            end
        end
    end,
}, false)
end

-- We block vanilla's joker_main dispatch (return nil, true) and apply xmult per individual card.
-- Vanilla's calculate_joker checks obj.calculate first; returning a truthy second value prevents
-- the vanilla branch from running while producing no effect itself.
if REB4LANCED.config.seeing_double_enhanced then
SMODS.Joker:take_ownership('seeing_double', {
    config = { extra = 1.25 },
    loc_txt = {
        name = 'Seeing Double',
        text = {
            'Each scoring card gives',
            '{X:mult,C:white} X#1# {} Mult if',
            '{C:attention}played hand{} contains a',
            '{C:clubs}Club{} and one other suit',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return nil, true  -- block vanilla's joker_main dispatch; we handle this in individual
        end
        if context.individual and context.cardarea == G.play then
            if not card.debuff and #context.scoring_hand >= 2
                and SMODS.seeing_double_check(context.scoring_hand, 'Clubs') then
                return { xmult = card.ability.extra }
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)
end -- REB4LANCED.config.seeing_double_enhanced

-- Smeared Joker: add description note that suit-based boss debuffs are also ignored
-- (behavior is implemented in overrides.lua Card:is_suit)
if REB4LANCED.config.smeared_enhanced then
SMODS.Joker:take_ownership('smeared', {
    loc_txt = {
        name = 'Smeared Joker',
        text = {
            '{C:hearts}Hearts{} and {C:diamonds}Diamonds',
            'count as the same suit,',
            '{C:spades}Spades{} and {C:clubs}Clubs',
            'count as the same suit.',
            '{C:inactive}All cards ignore suit-based',
            '{C:inactive}Boss Blind debuffs',
        },
    },
}, false)
end

-- Mime: Rare/$8 (vanilla: Uncommon/$7)
if REB4LANCED.config.mime_enhanced then
SMODS.Joker:take_ownership('mime', {
    rarity = 3,
    cost = 8,
}, false)
end

-- Baron: Uncommon (vanilla: Rare)
if REB4LANCED.config.baron_enhanced then
SMODS.Joker:take_ownership('baron', {
    rarity = 2,
}, false)
end

-- Mail-In Rebate: Uncommon (vanilla: Common)
if REB4LANCED.config.mail_rebate_enhanced then
SMODS.Joker:take_ownership('mail', {
    rarity = 2,
}, false)
end

-- Marble Joker: Common (vanilla: Uncommon)
if REB4LANCED.config.marble_enhanced then
SMODS.Joker:take_ownership('marble', {
    rarity = 1,
}, false)
end

-- Golden Ticket: Uncommon, $5 per Gold Card scored (vanilla: Common, $4)
if REB4LANCED.config.ticket_enhanced then
SMODS.Joker:take_ownership('ticket', {
    rarity = 2,
    config = { extra = 5 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
}, false)
end

-- Mad Joker: +10 Mult for Two Pair (vanilla: +8)
if REB4LANCED.config.mad_enhanced then
SMODS.Joker:take_ownership('mad', {
    config = { extra = { t_mult = 10, type = 'Two Pair' } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.t_mult, localize(card.ability.extra.type, 'poker_hands') } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
            return { mult = card.ability.extra.t_mult }
        end
    end,
}, false)
end

-- Crazy Joker: +18 Mult for Straight (vanilla: +12)
if REB4LANCED.config.crazy_enhanced then
SMODS.Joker:take_ownership('crazy', {
    config = { extra = { t_mult = 18, type = 'Straight' } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.t_mult, localize(card.ability.extra.type, 'poker_hands') } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
            return { mult = card.ability.extra.t_mult }
        end
    end,
}, false)
end

-- Droll Joker: +15 Mult for Flush (vanilla: +10)
if REB4LANCED.config.droll_enhanced then
SMODS.Joker:take_ownership('droll', {
    config = { extra = { t_mult = 15, type = 'Flush' } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.t_mult, localize(card.ability.extra.type, 'poker_hands') } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
            return { mult = card.ability.extra.t_mult }
        end
    end,
}, false)
end

-- 8 Ball: 1/3 chance per 8 scored (vanilla: 1/4)
-- Vanilla's card.lua dispatch reads self.ability.extra as the denominator via
-- SMODS.pseudorandom_probability(self, '8ball', 1, self.ability.extra).
-- We only change config.extra; vanilla handles the rest.
-- add_to_deck migrates old saves where ability.extra was incorrectly set to a table.
if REB4LANCED.config.eight_ball_enhanced then
SMODS.Joker:take_ownership('8_ball', {
    config = { extra = 3 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)
end

-- Bloodstone: 1/3 for X2 Mult on scoring Hearts card (vanilla: 1/2 for X1.5)
if REB4LANCED.config.bloodstone_enhanced then
SMODS.Joker:take_ownership('bloodstone', {
    config = { extra = { odds = 3, Xmult = 2 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, 3, 'reb4l_bloodstone')
        return { vars = { numerator, denominator, 2 } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit("Hearts") then
            if SMODS.pseudorandom_probability(card, 'reb4l_bloodstone', 1, 3) then
                return { xmult = 2 }
            end
        end
    end,
}, false)
end

-- Hanging Chad: Uncommon/$6, retriggers first scoring card 2 times
if REB4LANCED.config.hanging_chad_enhanced then
SMODS.Joker:take_ownership('hanging_chad', {
    rarity = 2,
    cost = 6,
    loc_txt = {
        name = 'Hanging Chad',
        text = {
            'Retriggers the {C:attention}first{}',
            'scored card {C:attention}#1#{} time(s)',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 2 } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[1] then
            return { repetitions = 2 }
        end
    end,
}, false)
end

-- The Idol
-- Mode 1: Vanilla (Uncommon/$6/X2, rank+suit rotates each round)
-- Mode 2: Rare/$8/X2.5, rank+suit rotates each round
-- Mode 3: Uncommon/$6/X2, rank+suit fixed per card on first generation
-- reb4l_idol_card mirrors vanilla's idol_card each round; used by modes 1+2.

-- Helper: generate and store a fixed rank/suit on the card (mode 3 only).
-- Safe to call multiple times; no-ops if already set.
local function reb4l_idol3_generate(card)
    if card.ability.reb4l_idol_rank then return end
    local rank, suit, id
    if G.playing_cards and #G.playing_cards > 0 then
        local valid = {}
        for _, c in ipairs(G.playing_cards) do
            if not SMODS.has_no_suit(c) and not SMODS.has_no_rank(c) then
                valid[#valid + 1] = c
            end
        end
        if #valid > 0 then
            local picked = valid[math.random(#valid)]
            rank = picked.base.value
            suit = picked.base.suit
            id   = picked.base.id
        end
    end
    if not rank then
        -- Fallback when outside a run (e.g. collection screen)
        local ranks = {'2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace'}
        local suits = {'Spades','Hearts','Clubs','Diamonds'}
        local ids   = {['2']=2,['3']=3,['4']=4,['5']=5,['6']=6,['7']=7,['8']=8,['9']=9,
                       ['10']=10,Jack=11,Queen=12,King=13,Ace=14}
        rank = ranks[math.random(#ranks)]
        suit = suits[math.random(#suits)]
        id   = ids[rank]
    end
    card.ability.reb4l_idol_rank = rank
    card.ability.reb4l_idol_suit = suit
    card.ability.reb4l_idol_id   = id
end

if REB4LANCED.config.idol_mode == 2 then
SMODS.Joker:take_ownership('idol', {
    rarity = 3,
    cost   = 8,
    config = { extra = 2.5 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)
end

if REB4LANCED.config.idol_mode == 3 then
SMODS.Joker:take_ownership('idol', {
    -- Vanilla rarity/cost/xmult unchanged.
    -- Rank and suit are fixed per card, stored in ability.reb4l_idol_rank/suit/id.
    loc_txt = {
        name = 'The Idol',
        text = {
            '{X:mult,C:white} X#1# {} Mult for each',
            'scored {C:attention}#2#{} of {C:attention}#3#{}',
        },
    },
    set_ability = function(self, card, initial, delay_sprites)
        if initial then reb4l_idol3_generate(card) end
    end,
    add_to_deck = function(self, card, from_debuff)
        reb4l_idol3_generate(card)  -- backup if set_ability ran outside a run
    end,
    loc_vars = function(self, info_queue, card)
        reb4l_idol3_generate(card)  -- lazy init when hovered in shop
        local rank = card.ability.reb4l_idol_rank or 'Ace'
        local suit = card.ability.reb4l_idol_suit or 'Spades'
        local xmult = type(card.ability.extra) == 'number' and card.ability.extra or 2
        return { vars = {
            xmult,
            localize(rank, 'ranks'),
            localize(suit, 'suits_plural'),
            colours = { G.C.SUITS[suit] },
        }}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local rank = card.ability.reb4l_idol_rank or 'Ace'
            local suit = card.ability.reb4l_idol_suit or 'Spades'
            local id   = card.ability.reb4l_idol_id   or 14
            local xmult = type(card.ability.extra) == 'number' and card.ability.extra or 2
            if context.other_card:get_id() and context.other_card:get_id() == id
               and context.other_card:is_suit(suit) then
                return { xmult = xmult }
            end
        end
    end,
}, false)
end

-- Mirror vanilla's idol_card into reb4l_idol_card each round for jokerdisplay.
-- Vanilla's reset_game_globals runs first, so idol_card is already set when this runs.
function SMODS.current_mod.reset_game_globals(run_start)
    G.GAME.current_round.reb4l_idol_card = G.GAME.current_round.idol_card
        or { rank = 'Ace', suit = 'Spades', id = 14 }
end

-- Baron: Uncommon (vanilla: Rare) — see src/patches.lua
-- Mail-in Rebate: Uncommon (vanilla: Common) — see src/patches.lua

-- Chicot mode 2: reduces all blind chip requirements by 33%, Blueprint/Brainstorm copyable
if REB4LANCED.config.chicot_mode == 2 then
SMODS.Joker:take_ownership('chicot', {
    blueprint_compat = true,
    loc_txt = {
        name = 'Chicot',
        text = {
            'When entering a {C:attention}Blind{},',
            'chip requirement reduced by {C:attention}33%',
        },
    },
    calculate = function(self, card, context)
        if context.setting_blind then
            -- Only the first non-debuffed Chicot in the joker area drives the events.
            -- It queues one reduction event *per Chicot* in order, so each event reads
            -- the value already reduced by the previous one (true diminishing returns).
            -- Other Chicots bail out here to avoid queuing duplicate events.
            if G.jokers then
                for _, joker in ipairs(G.jokers.cards) do
                    if joker.config.center.key == 'j_chicot' and not joker.debuff then
                        if joker ~= card then return nil end
                        break
                    end
                end
            end
            local count = 0
            if G.jokers then
                for _, joker in ipairs(G.jokers.cards) do
                    if joker.config.center.key == 'j_chicot' and not joker.debuff then
                        count = count + 1
                    end
                end
            end
            for _ = 1, count do
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.GAME.blind.chips = math.ceil(G.GAME.blind.chips * (2 / 3))
                        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                        if G.HUD_blind then G.HUD_blind:recalculate() end
                        return true
                    end
                }))
            end
            return nil
        end
    end,
}, false)
end

-- Chicot mode 3: on defeating a boss blind, gain a copy of every tag gained from blind skips this run
if REB4LANCED.config.chicot_mode == 3 then
SMODS.Joker:take_ownership('chicot', {
    blueprint_compat = true,
    loc_txt = {
        name = 'Chicot',
        text = {
            'On defeating a {C:attention}Boss Blind{},',
            'gain a copy of every {C:attention}Tag{}',
            'gained from {C:attention}Blind Skips{} this run',
            '{C:inactive}(Currently {C:attention}#1#{C:inactive} skip tags)',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME and #(G.GAME.reb4l_skip_tags or {}) or 0 } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            return nil
        end
        if context.end_of_round and context.game_over == false and context.main_eval
            and context.beat_boss then
            local skip_tags = G.GAME and G.GAME.reb4l_skip_tags or {}
            if #skip_tags > 0 then
                local snapshot = {}
                for _, key in ipairs(skip_tags) do
                    snapshot[#snapshot + 1] = key
                end
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for _, key in ipairs(snapshot) do
                            add_tag(Tag(key))
                            play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                        end
                        return true
                    end
                }))
                return { message = 'Echo!', colour = G.C.GREEN }
            end
        end
    end,
}, false)
end

-- Space Joker: 1/3 chance (vanilla: 1/4)
-- Vanilla's dispatch reads self.ability.extra as the bare odds denominator.
if REB4LANCED.config.space_joker_enhanced then
SMODS.Joker:take_ownership('space', {
    config = { extra = 3 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)
end

-- Vagabond: triggers at $8 or less (vanilla: $4 or less)
-- Vanilla's dispatch reads self.ability.extra as the bare dollar threshold.
if REB4LANCED.config.vagabond_enhanced then
SMODS.Joker:take_ownership('vagabond', {
    config = { extra = 8 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)
end

-- Madness: xmult_gain +0.75 per blind (vanilla: +0.5)
-- Vanilla's dispatch reads self.ability.extra as bare xmult_gain; current xmult in ability.x_mult.
if REB4LANCED.config.madness_enhanced then
SMODS.Joker:take_ownership('madness', {
    config = { extra = 0.75 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.x_mult = card.ability.extra.xmult or 1
            card.ability.extra = self.config.extra
        end
    end,
}, false)
end

-- Rocket: starts at $2, +$2 per boss (vanilla: $1, +$2)
if REB4LANCED.config.rocket_enhanced then
SMODS.Joker:take_ownership('rocket', {
    config = { extra = { dollars = 2, increase = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.increase } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and context.beat_boss then
            card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.increase
            return { message = localize('k_upgrade_ex'), colour = G.C.MONEY }
        end
    end,
    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end,
}, false)
end

-- Hit the Road: xmult_gain +0.75 per Jack (vanilla: +0.5); resets end of round; Jacks reshuffled into deck
-- REB4LANCED.htr_jacks is a shared table (accessible from overrides.lua) so the
-- draw_from_deck_to_hand wrapper can process it after cards reach G.discard.
REB4LANCED.htr_jacks = REB4LANCED.htr_jacks or {}
if REB4LANCED.config.hit_the_road_enhanced then
SMODS.Joker:take_ownership('hit_the_road', {
    config = { extra = { xmult_gain = 0.75, xmult = 1 } },
    loc_txt = {
        name = "Hit the Road",
        text = {
            "Gains {X:mult,C:white} X#1# {} Mult per",
            "{C:attention}Jack{} discarded,",
            "{C:attention}Jacks{} reshuffled into deck",
            "{C:inactive}Resets each round{}",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if not context.blueprint then
            if context.pre_discard and context.full_hand then
                for _, c in ipairs(context.full_hand) do
                    if not c.debuff and c:get_id() == 11 then
                        REB4LANCED.htr_jacks[c.unique_val or c] = c
                    end
                end
            end
            if context.discard and not context.other_card.debuff and context.other_card:get_id() == 11 then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
                return {
                    message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } },
                    colour = G.C.RED,
                    delay = 0.45
                }
            end
            if context.end_of_round and context.game_over == false and context.main_eval and card.ability.extra.xmult > 1 then
                card.ability.extra.xmult = 1
                return { message = localize('k_reset'), colour = G.C.RED }
            end
        end
        if context.joker_main then
            return { xmult = card.ability.extra.xmult }
        end
    end,
}, false)
end -- REB4LANCED.config.hit_the_road_enhanced

-- Diet Cola: Double Tag at end of round (3 uses), then self-destructs (vanilla: Double Tag on sell)
if REB4LANCED.config.diet_cola_enhanced then
SMODS.Joker:take_ownership('diet_cola', {
    config = { extra = { tags_remaining = 3 } },
    loc_txt = {
        name = "Diet Cola",
        text = {
            "Creates a {C:attention}#1#{}",
            "#2#",
        },
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'tag_double', set = 'Tag' }
        local tag_name = localize { type = 'name_text', set = 'Tag', key = 'tag_double' }
        local uses = card.ability and card.ability.extra.tags_remaining or 3
        return { vars = { tag_name, 'at end of round (' .. uses .. ' uses left)' } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            card.ability.extra.tags_remaining = card.ability.extra.tags_remaining - 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    add_tag(Tag('tag_double'))
                    play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end
            }))
            if card.ability.extra.tags_remaining <= 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.5,
                    func = function()
                        card:start_dissolve()
                        return true
                    end
                }))
            end
            return { message = localize { type = 'name_text', set = 'Tag', key = 'tag_double' }, colour = G.C.GREEN }
        end
    end,
}, false)
end

-- Constellation: gains X0.1 Mult on ANY hand level-up (planet card, Space Joker, Orbital Tag, Burnt Joker)
-- Xmult accumulation handled in overrides.lua level_up_hand; here we just apply joker_main
if REB4LANCED.config.constellation_enhanced then
SMODS.Joker:take_ownership('constellation', {
    config = { extra = 1, Xmult_mod = 0.1 },
    loc_txt = {
        name = 'Constellation',
        text = {
            'Gains {X:mult,C:white} X#1# {} Mult every time',
            'a {C:planet}Poker Hand{} levels up',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    loc_vars = function(self, info_queue, card)
        -- Migrate old save: ability.extra was {Xmult=n, Xmult_mod=0.1}
        if type(card.ability.extra) == 'table' then
            card.ability.Xmult_mod = card.ability.extra.Xmult_mod or 0.1
            card.ability.extra = card.ability.extra.Xmult or 1
        end
        return { vars = { card.ability.Xmult_mod, card.ability.extra } }
    end,
    calculate = function(self, card, context)
        -- Migrate old save: ability.extra was {Xmult=n, Xmult_mod=0.1}
        if type(card.ability.extra) == 'table' then
            card.ability.Xmult_mod = card.ability.extra.Xmult_mod or 0.1
            card.ability.extra = card.ability.extra.Xmult or 1
        end
        if context.joker_main then
            return { xmult = card.ability.extra }
        end
    end,
}, false)
end -- REB4LANCED.config.constellation_enhanced

-- Splash: every played card counts in scoring; debuffs cleared before hand scores
if REB4LANCED.config.splash_enhanced then
SMODS.Joker:take_ownership('splash', {
    loc_txt = {
        name = 'Splash',
        text = {
            'Every {C:attention}played card{}',
            'counts in scoring',
            '{C:inactive}Debuffs are cleared',
            '{C:inactive}before scoring{}',
        },
    },
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            for i = 1, #G.play.cards do
                G.play.cards[i]:set_debuff(false)
            end
        end
        if context.modify_scoring_hand then
            return { add_to_hand = true }
        end
    end,
}, false)
end -- REB4LANCED.config.splash_enhanced

-- Superposition: generates The Fool if straight + ace in full played hand (Four Fingers synergy)
if REB4LANCED.config.superposition_enhanced then
SMODS.Joker:take_ownership('superposition', {
    loc_txt = {
        name = 'Superposition',
        text = {
            'If {C:attention}played hand{} contains',
            'a {C:attention}Straight{} and an {C:attention}Ace{},',
            'create {C:tarot}The Fool{}',
            '{C:inactive}(if room)',
        },
    },
    calculate = function(self, card, context)
        if context.joker_main and context.scoring_name == 'Straight' then
            local has_ace = false
            for i = 1, #G.play.cards do
                if G.play.cards[i]:get_id() == 14 then
                    has_ace = true
                    break
                end
            end
            if has_ace and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local fool = SMODS.add_card({ key = 'c_fool', key_append = 'reb4l_superposition' })
                        G.GAME.consumeable_buffer = 0
                        if fool then fool:juice_up(0.3, 0.5) end
                        return true
                    end
                }))
                return { message = localize('k_plus_tarot') }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.superposition_enhanced

-- Bootstraps: scoring Hearts/Diamonds cards give +1 Mult per $5 (vanilla: +2 Mult per $5, no suit restriction)
if REB4LANCED.config.bootstraps_enhanced then
SMODS.Joker:take_ownership('bootstraps', {
    config = { extra = { mult = 1, dollars = 5 } },
    loc_txt = {
        name = 'Bootstraps',
        text = {
            'Scoring {C:hearts}Hearts{} and {C:diamonds}Diamonds{}',
            'cards give {C:mult}+#1#{} Mult',
            'for every {C:money}$#2#{} you have',
            '{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local current = card.ability.extra.mult *
            math.floor(((G.GAME and G.GAME.dollars or 0) + (G.GAME and G.GAME.dollar_buffer or 0)) /
                card.ability.extra.dollars)
        return { vars = { card.ability.extra.mult, card.ability.extra.dollars, current } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
            (context.other_card:is_suit('Hearts') or context.other_card:is_suit('Diamonds')) then
            local mult = card.ability.extra.mult *
                math.floor(((G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)) / card.ability.extra.dollars)
            if mult > 0 then
                return { mult = mult }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.bootstraps_enhanced

-- Bull: scoring Spades/Clubs cards give +1 Chip per $5 (vanilla: +1 Chip per $1, no suit restriction)
-- Note: vanilla card.lua does arithmetic on card.ability.extra directly (expects a number),
-- so we don't touch config and hardcode our values instead.
if REB4LANCED.config.bull_enhanced then
SMODS.Joker:take_ownership('bull', {
    loc_txt = {
        name = 'Bull',
        text = {
            'Scoring {C:spades}Spades{} and {C:clubs}Clubs{}',
            'cards give {C:chips}+#1#{} Chips',
            'for every {C:money}$#2#{} you have',
            '{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local current = 3 * math.floor(((G.GAME and G.GAME.dollars or 0) + (G.GAME and G.GAME.dollar_buffer or 0)) / 5)
        return { vars = { 3, 5, current } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
            (context.other_card:is_suit('Spades') or context.other_card:is_suit('Clubs')) then
            local chips = 3 * math.floor(((G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)) / 5)
            if chips > 0 then
                return { chips = chips }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.bull_enhanced

-- Erosion: X0.15 Mult for every card below 52 in deck (vanilla: +4 Mult per card below starting size)
if REB4LANCED.config.erosion_enhanced then
SMODS.Joker:take_ownership('erosion', {
    loc_txt = {
        name = 'Erosion',
        text = {
            '{X:mult,C:white} X#1# {} Mult for every',
            'card below {C:attention}52{} in your deck',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local missing = math.max(0, 52 - (G.playing_cards and #G.playing_cards or 52))
        local current = 1 + 0.15 * missing
        return { vars = { 0.15, string.format("%.2f", current) } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local missing = math.max(0, 52 - #G.playing_cards)
            if missing > 0 then
                return { xmult = 1 + 0.15 * missing }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.erosion_enhanced

-- Throwback: X1.0 per skipped blind (vanilla: X0.25)
if REB4LANCED.config.throwback_enhanced then
SMODS.Joker:take_ownership('throwback', {
    config = { extra = 1.0 },
    loc_txt = {
        name = 'Throwback',
        text = {
            '{X:mult,C:white} X#1# {} Mult for each',
            '{C:attention}Blind{} skipped this run',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local current = 1 + card.ability.extra * (G.GAME and G.GAME.skips or 0)
        return { vars = { card.ability.extra, string.format('%.2f', current) } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local xmult = 1 + card.ability.extra * (G.GAME.skips or 0)
            if xmult > 1 then
                return { xmult = xmult }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.throwback_enhanced

-- Golden Joker: $6/round, cost $8 (vanilla: $4/round, cost $6)
-- Cost patched in src/patches.lua
if REB4LANCED.config.golden_enhanced then
SMODS.Joker:take_ownership('golden', {
    config = { extra = 6 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calc_dollar_bonus = function(self, card)
        return card.ability.extra
    end,
}, false)
end -- REB4LANCED.config.golden_enhanced

-- Matador: $5 every hand played in any blind (vanilla: $8 when playing boss blind's required hand)
-- Cost patched in src/patches.lua
if REB4LANCED.config.matador_enhanced then
SMODS.Joker:take_ownership('matador', {
    config = { extra = 5 },
    loc_txt = {
        name = 'Matador',
        text = {
            'Earn {C:money}$#1#{} every time',
            'a {C:attention}hand{} is played',
            'during a {C:attention}Boss Blind{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calculate = function(self, card, context)
        if context.after and G.GAME.blind and G.GAME.blind.boss then
            return {
                dollars = card.ability.extra,
                message = localize { type = 'variable', key = 'a_dollars', vars = { card.ability.extra } },
                colour = G.C.MONEY,
            }
        end
    end,
}, false)
end -- REB4LANCED.config.matador_enhanced

-- Yorick: retriggers all played cards N times; N starts at 1, +1 every 23 hands played
if REB4LANCED.config.yorick_enhanced then
SMODS.Joker:take_ownership('yorick', {
    loc_txt = {
        name = 'Yorick',
        text = {
            'Retriggers all {C:attention}played cards{}',
            '{C:attention}#1#{} time(s)',
            '{C:inactive}(+1 retrigger every {C:attention}23{}{C:inactive} hands){}',
            '{C:inactive}(Next in {C:attention}#2#{C:inactive} hands)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local played = G.GAME and G.GAME.hands_played or 0
        local retriggers = 1 + math.floor(played / 23)
        local next_in = 23 - (played % 23)
        return { vars = { retriggers, next_in } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local played = G.GAME and G.GAME.hands_played or 0
            local retriggers = 1 + math.floor(played / 23)
            return { repetitions = retriggers }
        end
    end,
}, false)
end -- REB4LANCED.config.yorick_enhanced

-- Mr. Bones: 25% threshold; destroys rightmost joker on trigger; self-destructs if it is the rightmost
if REB4LANCED.config.mr_bones_enhanced then
SMODS.Joker:take_ownership('mr_bones', {
    loc_txt = {
        name = 'Mr. Bones',
        text = {
            'Prevents {C:attention}losing{} the run if',
            'chips scored are at least',
            '{C:attention}25%{} of required chips',
            '{C:inactive}Destroys the {C:attention}rightmost Joker{}',
        },
    },
    calculate = function(self, card, context)
        if context.game_over and not context.blueprint and
            G.GAME.chips >= math.floor(G.GAME.blind.chips * 0.25) then
            local rightmost = nil
            for i = #G.jokers.cards, 1, -1 do
                if not G.jokers.cards[i].getting_sliced then
                    rightmost = G.jokers.cards[i]
                    break
                end
            end
            if rightmost then
                rightmost.getting_sliced = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        rightmost:start_dissolve({ G.C.RED }, nil, 1.6)
                        return true
                    end
                }))
            end
            return {
                message = localize('k_saved_ex'),
                saved = true,
            }
        end
    end,
}, false)
end -- REB4LANCED.config.mr_bones_enhanced

-- Séance: same trigger, but creates a Negative Spectral (no consumable slot used)
if REB4LANCED.config.seance_enhanced then
SMODS.Joker:take_ownership('seance', {
    loc_txt = {
        name = 'Séance',
        text = {
            'If played hand is a {C:attention}#1#{},',
            'create a {C:dark_edition}Negative{} {C:spectral}Spectral{} card',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { localize(card.ability.extra.poker_hand, 'poker_hands') } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and context.scoring_name == card.ability.extra.poker_hand then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            return {
                extra = {
                    message = localize('k_plus_spectral'),
                    message_card = card,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local c = SMODS.add_card({ set = 'Spectral', key_append = 'reb4l_seance' })
                                if c then c:set_edition('e_negative', true) end
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                    end
                }
            }
        end
    end,
}, false)
end -- REB4LANCED.config.seance_enhanced

-- Campfire: gains X0.1 Mult per card sold; loses X0.25 Mult after each blind defeated
-- Vanilla: gains xmult based on sell value; loses ALL xmult after boss blind
if REB4LANCED.config.campfire_enhanced then
SMODS.Joker:take_ownership('campfire', {
    config = { extra = { xmult = 1, xmult_gain = 0.1, xmult_loss = 0.25 } },
    loc_txt = {
        name = 'Campfire',
        text = {
            'Gains {X:mult,C:white} X#1# {} Mult for each',
            '{C:attention}card{} sold',
            'Loses {X:mult,C:white} X#2# {} Mult after',
            'each {C:attention}Blind{} is defeated',
            '{C:inactive}(Currently {X:mult,C:white} X#3# {C:inactive} Mult)',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.xmult_gain,
            card.ability.extra.xmult_loss,
            string.format('%.2f', card.ability.extra.xmult),
        } }
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card ~= card and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } },
                colour = G.C.MULT,
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval
            and not context.blueprint and card.ability.extra.xmult > 1 then
            card.ability.extra.xmult = math.max(1, card.ability.extra.xmult - card.ability.extra.xmult_loss)
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } },
                colour = G.C.MULT,
            }
        end
        if context.joker_main and card.ability.extra.xmult > 1 then
            return { xmult = card.ability.extra.xmult }
        end
    end,
}, false)
end -- REB4LANCED.config.campfire_enhanced

-- Drunkard: +1 discard on entering blind; copyable by Blueprint/Brainstorm
-- Vanilla fires setting_blind with `not context.blueprint`, blocking copies.
if REB4LANCED.config.drunkard_enhanced then
SMODS.Joker:take_ownership('drunkard', {
    blueprint_compat = true,
    config = { extra = { discards = 1 } },
    loc_txt = {
        name = 'Drunkard',
        text = {
            'When {C:attention}Blind{} is entered,',
            'gain {C:red}+#1#{} Discard this round',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.discards } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            ease_discard(self.config.extra.discards)
            return { message = localize{type='variable', key='a_discards', vars={self.config.extra.discards}}, colour = G.C.RED }
        end
    end,
}, false)
end -- REB4LANCED.config.drunkard_enhanced

-- Driver's License: X4 Mult at 16 enhanced cards (vanilla: X3 at 16)
if REB4LANCED.config.drivers_license_enhanced then
SMODS.Joker:take_ownership('drivers_license', {
    config = { extra = 4 },
    loc_txt = {
        name = "Driver's License",
        text = {
            'If you have atleast {C:attention}16{} Enhanced',
            'cards in your full deck,',
            '{X:mult,C:white} X#1# {} Mult',
            '{C:inactive}(Currently {C:attention}#2#{C:inactive} Enhanced)',
        },
    },
    loc_vars = function(self, info_queue, card)
        local enhanced_count = 0
        for _, c in ipairs(G.playing_cards or {}) do
            if c.config.center.set == 'Enhanced' then
                enhanced_count = enhanced_count + 1
            end
        end
        return { vars = { card.ability.extra, enhanced_count } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local enhanced_count = 0
            for _, c in ipairs(G.playing_cards or {}) do
                if c.config.center.set == 'Enhanced' then
                    enhanced_count = enhanced_count + 1
                end
            end
            if enhanced_count >= 16 and not card.debuff then
                return { xmult = card.ability.extra }
            end
        end
    end,
}, false)
end -- REB4LANCED.config.drivers_license_enhanced

-- Merry Andy: +3 discards and -1 hand on entering blind; copyable by Blueprint/Brainstorm
-- config added explicitly because vanilla merry_andy does not store discards in config.extra
-- Merry Andy: discards given on entering blind (copyable); -1 hand size is vanilla passive (not copied)
if REB4LANCED.config.merry_andy_enhanced then
SMODS.Joker:take_ownership('merry_andy', {
    blueprint_compat = true,
    config = { extra = { discards = 3 } },
    loc_txt = {
        name = 'Merry Andy',
        text = {
            'When {C:attention}Blind{} is entered,',
            '{C:red}+#1#{} Discards this round',
            '{C:red}-1{} Hand Size',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.discards } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            ease_discard(self.config.extra.discards)
            return { message = localize{type='variable', key='a_discards', vars={self.config.extra.discards}}, colour = G.C.RED }
        end
    end,
}, false)
end -- REB4LANCED.config.merry_andy_enhanced

-- Obelisk: X0.25 per consecutive most-played hand (vanilla X0.2)
-- patches.lua cannot set config.extra = 0.25 because vanilla config.extra is a table
if REB4LANCED.config.obelisk_enhanced then
SMODS.Joker:take_ownership('obelisk', {
    config = { extra = 0.25, x_mult = 1 },
}, false)
end -- REB4LANCED.config.obelisk_enhanced
