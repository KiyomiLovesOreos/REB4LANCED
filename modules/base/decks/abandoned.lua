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
        G.GAME.reb4l_deck = 'abandoned'
    end,
}, false)
end

end
