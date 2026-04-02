-- JokerDisplay compatibility for REB4LANCED.
-- Overrides vanilla JokerDisplay definitions for every joker whose
-- behavior or data-storage path changed.  Jokers whose only change is
-- a rarity/cost tweak (Mime, Baron, Mail-in Rebate) or whose vanilla
-- definition already references the correct field (Rocket, Golden,
-- Mr. Bones) are intentionally left alone.

if not JokerDisplay then return end

-- ─── Drunkard ─────────────────────────────────────────────────────────────────
-- Gives +1 discard on entering blind; show count with round indicator.
-- Uses calc_function so Blueprint/Brainstorm copies display correctly.
JokerDisplay.Definitions["j_drunkard"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "discards" },
        { text = " / blind)", colour = G.C.UI.TEXT_INACTIVE },
    },
    calc_function = function(card)
        card.joker_display_values.discards =
            (type(card.ability.extra) == "table" and card.ability.extra.discards) or 1
    end,
}

-- ─── Merry Andy ───────────────────────────────────────────────────────────────
-- Gives +3 discards and -1 hand on entering blind; show counts.
-- Uses calc_function so Blueprint/Brainstorm copies display correctly.
JokerDisplay.Definitions["j_merry_andy"] = {
    reminder_text = {
        { text = "(" },
        { text = "+",                                                             colour = G.C.RED },
        { ref_table = "card.joker_display_values", ref_value = "discards",        colour = G.C.RED },
        { text = " Disc / blind | -1 Hand Size)", colour = G.C.UI.TEXT_INACTIVE },
    },
    calc_function = function(card)
        card.joker_display_values.discards =
            (type(card.ability.extra) == "table" and card.ability.extra.discards) or 3
    end,
}

-- ─── Satellite ────────────────────────────────────────────────────────────────
-- Pays $ceil(highest_hand_level / 2) per round instead of $1 per planet used.
JokerDisplay.Definitions["j_satellite"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    calc_function = function(card)
        local highest = 0
        for _, hand in pairs(G.GAME and G.GAME.hands or {}) do
            local lv = type(hand.level) == 'number' and hand.level
                or tonumber(tostring(hand.level)) or 0
            if lv > highest then highest = lv end
        end
        card.joker_display_values.dollars = math.ceil(highest / 2)
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
    end,
}

-- ─── Flower Pot ───────────────────────────────────────────────────────────────
-- Each scoring Wild Card gives +extra Chips per Wild Card in played hand (context.individual).
-- Display sums chips across all wild triggers, accounting for card retriggers.
JokerDisplay.Definitions["j_flower_pot"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local chips = 0
        if text ~= "Unknown" then
            local wild_count = 0
            for _, c in ipairs(scoring_hand) do
                if c.config.center.key == "m_wild" then wild_count = wild_count + 1 end
            end
            if wild_count > 0 then
                for _, c in ipairs(scoring_hand) do
                    if c.config.center.key == "m_wild" then
                        chips = chips + card.ability.extra * wild_count *
                            JokerDisplay.calculate_card_triggers(c, scoring_hand)
                    end
                end
            end
        end
        card.joker_display_values.chips = chips
    end,
}

-- ─── Mad / Crazy / Droll Joker ────────────────────────────────────────────────
-- Vanilla stored t_mult in card.ability.t_mult; REB4LANCED stores it in
-- card.ability.extra.t_mult (via config = { extra = { t_mult = N, type = '...' } }).
local function hand_type_mult_calc(card)
    local mult = 0
    local _, poker_hands, _ = JokerDisplay.evaluate_hand()
    local hand_type = card.ability.extra and card.ability.extra.type or card.ability.type
    if hand_type and poker_hands[hand_type] and next(poker_hands[hand_type]) then
        mult = (card.ability.extra and card.ability.extra.t_mult) or card.ability.t_mult or 0
    end
    card.joker_display_values.mult = mult
    card.joker_display_values.localized_text = hand_type and localize(hand_type, "poker_hands") or ""
end

local hand_type_mult_def = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.ORANGE },
        { text = ")" },
    },
    calc_function = hand_type_mult_calc,
}

JokerDisplay.Definitions["j_mad"]   = hand_type_mult_def
JokerDisplay.Definitions["j_crazy"] = hand_type_mult_def
JokerDisplay.Definitions["j_droll"] = hand_type_mult_def

-- ─── 8 Ball ───────────────────────────────────────────────────────────────────
-- Odds changed to 1/2 via config.extra = 2 (vanilla reads ability.extra as denominator).
-- Vanilla's calculate and loc_vars run unmodified; only display logic overridden here.
JokerDisplay.Definitions["j_8_ball"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.SECONDARY_SET.Tarot },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        },
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card:get_id() and scoring_card:get_id() == 8 then
                    count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                end
            end
        end
        card.joker_display_values.count = count
        local odds = type(card.ability.extra) == "number" and card.ability.extra or 3
        local numerator, denominator = SMODS.get_probability_vars(card, 1, odds, "8ball")
        card.joker_display_values.odds = localize {
            type = "variable", key = "jdis_odds", vars = { numerator, denominator },
        }
    end,
}

-- ─── Bloodstone (enhanced) ────────────────────────────────────────────────────
-- Odds changed to 1/3, Xmult to X2; SMODS key changed to 'reb4l_bloodstone'.
if REB4LANCED.config.bloodstone_enhanced then
    JokerDisplay.Definitions["j_bloodstone"] = {
        text = {
            { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
            { text = "x", scale = 0.35 },
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability.extra", ref_value = "Xmult" },
                },
            },
        },
        reminder_text = {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "localized_text" },
            { text = ")" },
        },
        extra = {
            {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "odds" },
                { text = ")" },
            },
        },
        extra_config = { colour = G.C.GREEN, scale = 0.3 },
        calc_function = function(card)
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            local count = 0
            if text ~= "Unknown" then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card:is_suit("Hearts") then
                        count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                    end
                end
            end
            card.joker_display_values.count = count
            local odds = card.ability.extra and card.ability.extra.odds or 3
            local numerator, denominator = SMODS.get_probability_vars(card, 1, odds, "reb4l_bloodstone")
            card.joker_display_values.odds = localize {
                type = "variable", key = "jdis_odds", vars = { numerator, denominator },
            }
            card.joker_display_values.localized_text = localize("Hearts", "suits_plural")
        end,
        style_function = function(card, text, reminder_text, extra)
            local suit_node = reminder_text and reminder_text.children and reminder_text.children[2]
            if suit_node then suit_node.config.colour = lighten(G.C.SUITS["Hearts"], 0.35) end
        end,
    }
end

-- ─── Hanging Chad ─────────────────────────────────────────────────────────────
-- Now retriggers the first scoring card 2 times (vanilla: 1).
-- Vanilla retrigger_function read ability.extra (= 1); hardcode 2 here.
JokerDisplay.Definitions["j_hanging_chad"] = {
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand then return 0 end
        local first_card = scoring_hand and JokerDisplay.calculate_leftmost_card(scoring_hand)
        return first_card and playing_card == first_card and
            2 * JokerDisplay.calculate_joker_triggers(joker_card) or 0
    end,
}

-- ─── The Idol ────────────────────────────────────────────────────────────────
-- Mode 1/2: reb4l_idol_card mirrors vanilla idol_card (rotating each round).
-- Mode 3: per-card fixed rank/suit stored in card.ability.reb4l_idol_rank/suit/id.
JokerDisplay.Definitions["j_idol"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" },
            },
        },
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "idol_card", colour = G.C.FILTER },
        { text = ")" },
    },
    calc_function = function(card)
        local idol
        if REB4LANCED.config.idol_mode == 3 and card.ability.reb4l_idol_rank then
            idol = {
                rank = card.ability.reb4l_idol_rank,
                suit = card.ability.reb4l_idol_suit,
                id   = card.ability.reb4l_idol_id,
            }
        else
            idol = (G.GAME and G.GAME.current_round and G.GAME.current_round.reb4l_idol_card)
                or { rank = "Ace", suit = "Spades", id = 14 }
        end
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card:is_suit(idol.suit) and scoring_card:get_id() and
                   scoring_card:get_id() == idol.id then
                    count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                end
            end
        end
        local xmult = type(card.ability.extra) == "number" and card.ability.extra or 2
        card.joker_display_values.x_mult = xmult ^ count
        card.joker_display_values.idol_card = localize {
            type = "variable", key = "jdis_rank_of_suit",
            vars = { localize(idol.rank, "ranks"), localize(idol.suit, "suits_plural") },
        }
    end,
    style_function = function(card, text, reminder_text, extra)
        local suit
        if REB4LANCED.config.idol_mode == 3 and card.ability.reb4l_idol_suit then
            suit = card.ability.reb4l_idol_suit
        else
            local idol = G.GAME and G.GAME.current_round and G.GAME.current_round.reb4l_idol_card
            suit = idol and idol.suit or "Spades"
        end
        if reminder_text and reminder_text.children and reminder_text.children[2] then
            reminder_text.children[2].config.colour = lighten(G.C.SUITS[suit], 0.35)
        end
    end,
}

-- ─── Chicot (mode 3 only) ─────────────────────────────────────────────────────
-- Mode 1 (vanilla disable): handled correctly by vanilla JokerDisplay definition.
-- Mode 2 (reduce 33%):      vanilla active/inactive display is still accurate.
-- Mode 3 (echo skip tags):  show current skip-tag count instead.
if REB4LANCED.config.chicot_mode == 3 then
    JokerDisplay.Definitions["j_chicot"] = {
        text = {
            { ref_table = "card.joker_display_values", ref_value = "tag_count" },
        },
        text_config = { colour = G.C.ORANGE },
        reminder_text = {
            { text = "(skip tags)", colour = G.C.UI.TEXT_INACTIVE },
        },
        calc_function = function(card)
            card.joker_display_values.tag_count = G.GAME and #(G.GAME.reb4l_skip_tags or {}) or 0
        end,
    }
end

-- ─── Space Joker ──────────────────────────────────────────────────────────────
-- Odds changed to 1/3 via config.extra = 3 (vanilla reads ability.extra as bare denominator).
JokerDisplay.Definitions["j_space"] = {
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        },
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local odds = type(card.ability.extra) == "number" and card.ability.extra or 3
        local numerator, denominator = SMODS.get_probability_vars(card, 1, odds, "space")
        card.joker_display_values.odds = localize {
            type = "variable", key = "jdis_odds", vars = { numerator, denominator },
        }
    end,
}

-- ─── Vagabond ─────────────────────────────────────────────────────────────────
-- Triggers at $8 or less (vanilla: $4) via config.extra = 8 (bare number).
JokerDisplay.Definitions["j_vagabond"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.SECONDARY_SET.Tarot },
    calc_function = function(card)
        local threshold = type(card.ability.extra) == "number" and card.ability.extra or 8
        card.joker_display_values.active = (G.GAME.dollars or 0) <= threshold
        card.joker_display_values.count = card.joker_display_values.active and 1 or 0
    end,
}

-- ─── Campfire ────────────────────────────────────────────────────────────────
-- xmult moved from card.ability.x_mult to card.ability.extra.xmult.
JokerDisplay.Definitions["j_campfire"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" },
            },
        },
    },
}

-- ─── Madness ──────────────────────────────────────────────────────────────────
-- config.extra = 0.75 (bare xmult_gain); current xmult lives in card.ability.x_mult (vanilla).
JokerDisplay.Definitions["j_madness"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability", ref_value = "x_mult", retrigger_type = "exp" },
            },
        },
    },
}

-- ─── Hit the Road ─────────────────────────────────────────────────────────────
-- xmult stored in card.ability.extra.xmult (vanilla used card.ability.x_mult).
-- Gain rate: +0.75 per Jack (vanilla: +0.5). Jacks reshuffled into deck each round.
JokerDisplay.Definitions["j_hit_the_road"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" },
            },
        },
    },
}

-- ─── Diet Cola (enhanced) ─────────────────────────────────────────────────────
-- Creates Double Tag at end of round (3 uses then self-destructs).
-- Vanilla definition was empty; show remaining uses in reminder text.
if REB4LANCED.config.diet_cola_enhanced then
    JokerDisplay.Definitions["j_diet_cola"] = {
        reminder_text = {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "uses_remaining" },
            { text = " uses)", colour = G.C.UI.TEXT_INACTIVE },
        },
        calc_function = function(card)
            card.joker_display_values.uses_remaining =
                (card.ability and card.ability.extra and card.ability.extra.tags_remaining) or 0
        end,
    }
end

-- ─── Constellation ────────────────────────────────────────────────────────────
-- Xmult stored in card.ability.extra (bare number; vanilla used card.ability.x_mult).
JokerDisplay.Definitions["j_constellation"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability", ref_value = "extra", retrigger_type = "exp" },
            },
        },
    },
}

-- ─── Superposition ────────────────────────────────────────────────────────────
-- Now checks the full played hand (not just scoring cards) for an Ace.
-- JokerDisplay.current_hand holds all currently selected cards.
JokerDisplay.Definitions["j_superposition"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.SECONDARY_SET.Tarot },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text_ace",      colour = G.C.ORANGE },
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text_straight", colour = G.C.ORANGE },
        { text = ")" },
    },
    calc_function = function(card)
        local is_superposition = false
        local _, poker_hands, _ = JokerDisplay.evaluate_hand()
        if poker_hands["Straight"] and next(poker_hands["Straight"]) then
            -- REB4LANCED checks the full played hand, not just scoring cards.
            for _, played_card in pairs(JokerDisplay.current_hand or {}) do
                if played_card:get_id() and played_card:get_id() == 14 then
                    is_superposition = true
                    break
                end
            end
        end
        card.joker_display_values.count = is_superposition and 1 or 0
        card.joker_display_values.localized_text_straight = localize("Straight", "poker_hands")
        card.joker_display_values.localized_text_ace = localize("Ace", "ranks")
    end,
}

-- ─── Bootstraps ───────────────────────────────────────────────────────────────
-- Now restricted to Hearts/Diamonds; +1 Mult per $5 (vanilla: +2 per $5, all suits).
-- Display shows per-card mult for qualifying cards (correct ref paths unchanged).
JokerDisplay.Definitions["j_bootstraps"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        card.joker_display_values.mult = card.ability.extra.mult *
            math.floor(
                ((G.GAME and G.GAME.dollars or 0) + (G.GAME and G.GAME.dollar_buffer or 0))
                / card.ability.extra.dollars
            )
    end,
}

-- ─── Bull ─────────────────────────────────────────────────────────────────────
-- Now restricted to Spades/Clubs; +1 Chip per $5 (vanilla: +1 per $1, all suits).
-- config.extra is NOT changed (vanilla code reads it directly), so hardcode divisor of 5.
JokerDisplay.Definitions["j_bull"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function(card)
        card.joker_display_values.chips = math.floor(
            math.max(0, (G.GAME and G.GAME.dollars or 0) + (G.GAME and G.GAME.dollar_buffer or 0)) / 5
        )
    end,
}

-- ─── Erosion ──────────────────────────────────────────────────────────────────
-- Changed from +Mult to XMult; now compares against 52 (not starting_deck_size);
-- gain is X0.15 per missing card instead of +4 per missing card.
JokerDisplay.Definitions["j_erosion"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" },
            },
        },
    },
    calc_function = function(card)
        local missing = math.max(0, 52 - (G.playing_cards and #G.playing_cards or 52))
        card.joker_display_values.xmult = string.format("%.2f", 1 + 0.15 * missing)
    end,
}

-- ─── Delayed Gratification ────────────────────────────────────────────────────
-- Mode 1 (Vanilla): $2/unused discard, only if no discards used this round
-- Mode 2: $2/unused discard regardless of discards used
-- Mode 3: $4/unused discard, only if no discards used this round
JokerDisplay.Definitions["j_delayed_grat"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "localized_text" },
    },
    calc_function = function(card)
        local mode  = REB4LANCED.config.delayed_grat_mode or 1
        local unused = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        local used   = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_used) or 0
        local rate   = (mode == 3) and 4 or card.ability.extra
        local payout = (mode == 2 or used == 0) and (unused * rate) or 0
        card.joker_display_values.dollars = payout
        card.joker_display_values.localized_text = "(" .. localize("k_round") .. ")"
    end,
}

-- ─── Throwback ────────────────────────────────────────────────────────────────
-- Gain rate changed to X0.5 per skip (vanilla: X0.25).
-- Value is computed dynamically; vanilla definition pointed at card.ability.x_mult
-- which is never updated by the REB4LANCED calculate function.
JokerDisplay.Definitions["j_throwback"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" },
            },
        },
    },
    calc_function = function(card)
        local xmult = 1 + card.ability.extra * (G.GAME and G.GAME.skips or 0)
        card.joker_display_values.xmult = string.format("%.2f", xmult)
    end,
}

-- ─── Matador ──────────────────────────────────────────────────────────────────
-- Now earns $5 on EVERY hand played during a boss blind (vanilla: $8 only when
-- playing the required hand of the boss blind).
JokerDisplay.Definitions["j_matador"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.ability", ref_value = "extra", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { text = "(", colour = G.C.UI.TEXT_INACTIVE },
        { ref_table = "card.joker_display_values", ref_value = "active_text" },
        { text = ")", colour = G.C.UI.TEXT_INACTIVE },
    },
    calc_function = function(card)
        local boss_active = G.GAME.blind and G.GAME.blind.get_type and
            (not G.GAME.blind.disabled) and (G.GAME.blind:get_type() == "Boss")
        card.joker_display_values.active = boss_active
        card.joker_display_values.active_text = localize(boss_active and "jdis_active" or "jdis_inactive")
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children and reminder_text.children[2] then
            reminder_text.children[2].config.colour =
                card.joker_display_values.active and G.C.GREEN or G.C.UI.TEXT_INACTIVE
        end
    end,
}

-- ─── Yorick ───────────────────────────────────────────────────────────────────
-- Completely reworked: retriggers all played cards N times where
-- N = 1 + floor(hands_played / 23).  Vanilla tracked discards to upgrade.
JokerDisplay.Definitions["j_yorick"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "retriggers", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.ORANGE },
    reminder_text = {
        { text = "(next in ",                              colour = G.C.UI.TEXT_INACTIVE },
        { ref_table = "card.joker_display_values", ref_value = "next_in" },
        { text = ")",                                      colour = G.C.UI.TEXT_INACTIVE },
    },
    calc_function = function(card)
        local played = G.GAME and G.GAME.hands_played or 0
        card.joker_display_values.retriggers = 1 + math.floor(played / 23)
        card.joker_display_values.next_in    = 23 - (played % 23)
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand then return 0 end
        local played = G.GAME and G.GAME.hands_played or 0
        local retriggers = 1 + math.floor(played / 23)
        return retriggers * JokerDisplay.calculate_joker_triggers(joker_card)
    end,
}

-- ─── Rough Gem ────────────────────────────────────────────────────────────────
-- Payout changed to $2 per scoring Diamond (vanilla: $1).
-- Vanilla JokerDisplay may reference card.ability.extra as a bare number (old API);
-- this override reads card.ability.extra.dollars to match SMODS 1.x storage.
JokerDisplay.Definitions["j_rough_gem"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        local total = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" then
            local dollars = (type(card.ability.extra) == "number") and card.ability.extra or 2
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card:is_suit("Diamonds") then
                    total = total + dollars * JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                end
            end
        end
        card.joker_display_values.dollars = total
    end,
}

-- ─── Seeing Double ────────────────────────────────────────────────────────────
-- Changed from single X2 (joker_main) to X1.25 per scoring card (individual).
-- Shows total combined xmult across all scoring card triggers.
JokerDisplay.Definitions["j_seeing_double"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult" },
            },
        },
    },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local has_club = false
        local has_other = false
        if text ~= "Unknown" then
            for _, c in pairs(scoring_hand) do
                if c:is_suit("Clubs") then has_club = true
                else has_other = true end
            end
        end
        local xmult = type(card.ability.extra) == "number" and card.ability.extra or 1.25
        if has_club and has_other then
            local total_triggers = 0
            for _, c in pairs(scoring_hand) do
                total_triggers = total_triggers + JokerDisplay.calculate_card_triggers(c, scoring_hand)
            end
            card.joker_display_values.xmult = string.format("%.2f", xmult ^ total_triggers)
        else
            card.joker_display_values.xmult = "1.00"
        end
    end,
}

-- ─── Driver's License ─────────────────────────────────────────────────────────
-- X4 Mult at 16 enhanced cards (vanilla: X3 at 16).
JokerDisplay.Definitions["j_drivers_license"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" },
            },
        },
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "count" },
        { text = "/" },
        { ref_table = "card.joker_display_values", ref_value = "threshold" },
        { text = ")", colour = G.C.UI.TEXT_INACTIVE },
    },
    calc_function = function(card)
        local count = 0
        for _, c in ipairs(G.playing_cards or {}) do
            if c.config.center and c.config.center.set == "Enhanced" then
                count = count + 1
            end
        end
        local xmult = type(card.ability.extra) == "number" and card.ability.extra or 4
        card.joker_display_values.count     = count
        card.joker_display_values.threshold = 16
        card.joker_display_values.xmult     = count >= 16 and xmult or 1
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children then
            local count = card.joker_display_values.count or 0
            local colour = count >= 16 and G.C.GREEN or G.C.UI.TEXT_INACTIVE
            for _, child in ipairs(reminder_text.children) do
                if child.config then child.config.colour = colour end
            end
        end
    end,
}
