return function(REB4LANCED)
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
end
