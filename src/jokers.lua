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
            if hand.level > highest then highest = hand.level end
        end
        return { vars = { card.ability.extra, math.ceil(highest / 2) } }
    end,
    calc_dollar_bonus = function(self, card)
        if card.debuff then return end
        local highest = 0
        for _, hand in pairs(G.GAME.hands) do
            if hand.level > highest then highest = hand.level end
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

-- Delayed Gratification: mode-selectable rework
-- Mode 1 (Vanilla): $2 per unused discard if no discards used this round
-- Mode 2: $2 per unused discard regardless of discards used
-- Mode 3: $4 per unused discard if no discards used this round
if REB4LANCED.config.delayed_grat_mode and REB4LANCED.config.delayed_grat_mode ~= 1 then
local _mode = REB4LANCED.config.delayed_grat_mode
SMODS.Joker:take_ownership('delayed_gratification', {
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
            if not card.debuff and SMODS.seeing_double_check(context.scoring_hand, 'Clubs') then
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
SMODS.Joker:take_ownership('mail_in_rebate', {
    rarity = 2,
}, false)
end

-- Marble Joker: Common (vanilla: Uncommon)
if REB4LANCED.config.marble_enhanced then
SMODS.Joker:take_ownership('marble', {
    rarity = 1,
}, false)
end

-- Golden Ticket: Uncommon (vanilla: Common)
if REB4LANCED.config.ticket_enhanced then
SMODS.Joker:take_ownership('ticket', {
    rarity = 2,
}, false)
end

-- Mad Joker: +10 Mult for Two Pair (vanilla: +8)
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

-- Crazy Joker: +18 Mult for Straight (vanilla: +12)
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

-- Droll Joker: +15 Mult for Flush (vanilla: +10)
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

-- 8 Ball: 1/2 chance per 8 scored (vanilla: 1/4)
-- Vanilla's card.lua dispatch reads self.ability.extra as the denominator via
-- SMODS.pseudorandom_probability(self, '8ball', 1, self.ability.extra).
-- We only change config.extra; vanilla handles the rest.
-- add_to_deck migrates old saves where ability.extra was incorrectly set to a table.
SMODS.Joker:take_ownership('8_ball', {
    config = { extra = 2 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)

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

-- The Idol: configurable Uncommon/$6/X2 (vanilla) or Rare/$8/X2.5 (default enhanced)
-- Vanilla's dispatch reads self.ability.extra as bare xmult and fires per scored idol card.
-- reb4l_idol_card mirrors vanilla's idol_card so jokerdisplay can reference it.
SMODS.Joker:take_ownership('idol', {
    rarity = REB4LANCED.config.idol_enhanced and 3 or 2,
    cost   = REB4LANCED.config.idol_enhanced and 8 or 6,
    config = { extra = REB4LANCED.config.idol_enhanced and 2.5 or 2 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)

-- Mirror vanilla's idol_card into reb4l_idol_card each round for jokerdisplay.
-- Vanilla's reset_game_globals runs first, so idol_card is already set when this runs.
function SMODS.current_mod.reset_game_globals(run_start)
    G.GAME.current_round.reb4l_idol_card = G.GAME.current_round.idol_card
        or { rank = 'Ace', suit = 'Spades', id = 14 }
end

-- Baron: Uncommon (vanilla: Rare) — see src/patches.lua
-- Mail-in Rebate: Uncommon (vanilla: Common) — see src/patches.lua

-- Chicot mode 2: reduces boss blind chip requirement by 33% (no blind disable)
if REB4LANCED.config.chicot_mode == 2 then
SMODS.Joker:take_ownership('chicot', {
    loc_txt = {
        name = 'Chicot',
        text = {
            '{C:attention}Boss Blind{} chip',
            'requirement reduced by {C:attention}33%',
        },
    },
    calculate = function(self, card, context)
        if context.setting_blind and context.blind.boss and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.blind.chips = math.ceil(G.GAME.blind.chips * (2 / 3))
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                    if G.HUD_blind then G.HUD_blind:recalculate() end
                    return true
                end
            }))
            return nil, true  -- block vanilla's blind:disable()
        end
    end,
}, false)
end

-- Chicot mode 3: on defeating a boss blind, gain a copy of every tag gained from blind skips this run
if REB4LANCED.config.chicot_mode == 3 then
SMODS.Joker:take_ownership('chicot', {
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
            return nil, true  -- block vanilla's blind:disable()
        end
        if context.end_of_round and context.game_over == false and context.main_eval
            and context.beat_boss and not context.blueprint then
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
SMODS.Joker:take_ownership('space', {
    config = { extra = 3 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)

-- Vagabond: triggers at $8 or less (vanilla: $4 or less)
-- Vanilla's dispatch reads self.ability.extra as the bare dollar threshold.
SMODS.Joker:take_ownership('vagabond', {
    config = { extra = 8 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.extra = self.config.extra
        end
    end,
}, false)

-- Madness: xmult_gain +0.75 per blind (vanilla: +0.5)
-- Vanilla's dispatch reads self.ability.extra as bare xmult_gain; current xmult in ability.x_mult.
SMODS.Joker:take_ownership('madness', {
    config = { extra = 0.75 },
    add_to_deck = function(self, card, from_debuff)
        if type(card.ability.extra) ~= 'number' then
            card.ability.x_mult = card.ability.extra.xmult or 1
            card.ability.extra = self.config.extra
        end
    end,
}, false)

-- Rocket: starts at $2, +$2 per boss (vanilla: $1, +$2)
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

-- Hit the Road: xmult_gain +0.75 per Jack (vanilla: +0.5); resets end of round; Jacks reshuffled into deck
local reb4l_htr_jacks = {}
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
        if context.blueprint then return end
        if context.pre_discard and context.full_hand then
            for _, c in ipairs(context.full_hand) do
                if not c.debuff and c:get_id() == 11 then
                    -- use card id as key to avoid double-adding if Blueprinted
                    reb4l_htr_jacks[c.unique_val or c] = c
                end
            end
            local jacks_list = {}
            for _, jc in pairs(reb4l_htr_jacks) do jacks_list[#jacks_list + 1] = jc end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                blocking = true,
                blockable = true,
                func = function()
                    for i, jack_card in ipairs(jacks_list) do
                        draw_card(G.discard, G.deck, (i * 100) / #jacks_list, 'up', true, jack_card)
                    end
                    reb4l_htr_jacks = {}
                    G.deck:shuffle('reb4l_htr_' .. G.GAME.hands_played .. '_' .. G.GAME.current_round.discards_left)
                    return true
                end
            }))
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
        if context.joker_main then
            return { xmult = card.ability.extra.xmult }
        end
    end,
}, false)

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
SMODS.Joker:take_ownership('constellation', {
    config = { extra = { Xmult = 1, Xmult_mod = 0.1 } },
    loc_txt = {
        name = 'Constellation',
        text = {
            'Gains {X:mult,C:white} X#1# {} Mult every',
            'time a {C:planet}Poker Hand{}',
            'levels up',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
}, false)

-- Splash: every played card counts in scoring; debuffs cleared before hand scores
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

-- Superposition: generates The Fool if straight + ace in full played hand (Four Fingers synergy)
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

-- Bootstraps: scoring Hearts/Diamonds cards give +1 Mult per $5 (vanilla: +2 Mult per $5, no suit restriction)
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

-- Bull: scoring Spades/Clubs cards give +1 Chip per $5 (vanilla: +1 Chip per $1, no suit restriction)
-- Note: vanilla card.lua does arithmetic on card.ability.extra directly (expects a number),
-- so we don't touch config and hardcode our values instead.
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
        local current = math.floor(((G.GAME and G.GAME.dollars or 0) + (G.GAME and G.GAME.dollar_buffer or 0)) / 5)
        return { vars = { 3, 5, current } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
            (context.other_card:is_suit('Spades') or context.other_card:is_suit('Clubs')) then
            local chips = math.floor(((G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)) / 5)
            if chips > 0 then
                return { chips = chips }
            end
        end
    end,
}, false)


-- Erosion: X0.15 Mult for every card below 52 in deck (vanilla: +4 Mult per card below starting size)
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

-- Throwback: X0.5 per skipped blind (vanilla: X0.25)
SMODS.Joker:take_ownership('throwback', {
    config = { extra = 0.5 },
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

-- Golden Joker: $6/round, cost $8 (vanilla: $4/round, cost $6)
-- Cost patched in src/patches.lua
SMODS.Joker:take_ownership('golden', {
    config = { extra = 6 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calc_dollar_bonus = function(self, card)
        return card.ability.extra
    end,
}, false)

-- Matador: $5 every hand played in any blind (vanilla: $8 when playing boss blind's required hand)
-- Cost patched in src/patches.lua
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
        if context.after and not context.blueprint
            and G.GAME.blind and G.GAME.blind.boss then
            return {
                dollars = card.ability.extra,
                message = localize { type = 'variable', key = 'a_dollars', vars = { card.ability.extra } },
                colour = G.C.MONEY,
            }
        end
    end,
}, false)

-- Yorick: retriggers all played cards N times; N starts at 1, +1 every 23 hands played
SMODS.Joker:take_ownership('yorick', {
    loc_txt = {
        name = 'Yorick',
        text = {
            'Retriggers all {C:attention}played cards{}',
            '{C:attention}#1#{} time(s)',
            '{C:inactive}(+1 retrigger every {C:attention}23{} hands)',
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

-- Mr. Bones: 25% threshold; destroys rightmost joker on trigger; self-destructs if it is the rightmost
SMODS.Joker:take_ownership('mr_bones', {
    loc_txt = {
        name = 'Mr. Bones',
        text = {
            'Prevents {C:attention}losing{} the run if',
            'chips scored are at least',
            '{C:attention}25%{} of required chips',
            '{C:inactive}Destroys the {C:attention}rightmost Joker{}',
            '{C:inactive}Self destructs if rightmost{}',
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

-- Séance: same trigger, but creates a Negative Spectral (no consumable slot used)
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

-- Campfire: gains X0.1 Mult per card sold; loses X0.25 Mult after each blind defeated
-- Vanilla: gains xmult based on sell value; loses ALL xmult after boss blind
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

-- Drunkard: +1 discard on entering blind; copyable by Blueprint/Brainstorm
-- Vanilla fires setting_blind with `not context.blueprint`, blocking copies.
SMODS.Joker:take_ownership('drunkard', {
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
            ease_discard(card.ability.extra.discards)
            return { message = localize('k_plus_discard'), colour = G.C.RED }
        end
    end,
}, false)

-- Driver's License: activates at 12 enhanced cards (vanilla: 16)
-- config.extra is a bare number (xmult = 3); driver_amount is hardcoded in vanilla calculate
SMODS.Joker:take_ownership('drivers_license', {
    loc_txt = {
        name = "Driver's License",
        text = {
            'If you have {C:attention}12{}+ Enhanced',
            'cards in your full deck,',
            '{X:mult,C:white} X#1# {} Mult',
            '{C:inactive}(Currently {C:attention}#2#{C:inactive} Enhanced)',
        },
    },
    calculate = function(self, card, context)
        if context.joker_main then
            local enhanced_count = 0
            for _, c in ipairs(G.playing_cards) do
                if c.config.center.set == 'Enhanced' then
                    enhanced_count = enhanced_count + 1
                end
            end
            if enhanced_count >= 12 and not card.debuff then
                return { xmult = card.ability.extra }
            end
        end
    end,
}, false)

-- Merry Andy: +3 discards and -1 hand on entering blind; copyable by Blueprint/Brainstorm
-- config added explicitly because vanilla merry_andy does not store discards in config.extra
-- Merry Andy: discards given on entering blind (copyable); -1 hand size is vanilla passive (not copied)
SMODS.Joker:take_ownership('merry_andy', {
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
            ease_discard(card.ability.extra.discards)
            return { message = localize('k_plus_discard'), colour = G.C.RED }
        end
    end,
}, false)
