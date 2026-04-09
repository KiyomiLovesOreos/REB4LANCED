return function(REB4LANCED)
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

end
