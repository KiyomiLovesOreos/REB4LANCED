return function(REB4LANCED)
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

end
