return function(REB4LANCED)
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
        G.E_MANAGER:add_event(Event({
            func = function()
                local face_ranks = { Jack = true, Queen = true, King = true }
                local to_remove, kept = {}, {}
                for _, card in ipairs(G.playing_cards) do
                    if card and card.base and face_ranks[card.base.value] then
                        table.insert(to_remove, card)
                    else
                        table.insert(kept, card)
                    end
                end
                G.playing_cards = kept
                for _, card in ipairs(to_remove) do
                    if card.area then card.area:remove_card(card) end
                    card:remove()
                end
                return true
            end
        }))
    end,
}, false)
end

end
