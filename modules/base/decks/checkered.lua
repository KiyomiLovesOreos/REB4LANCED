return function(REB4LANCED)
-- Checkered Deck: Diamonds/Clubs cannot appear anywhere; converts starting deck on apply
-- Ongoing card replacement is handled by the Card:set_base wrapper in overrides.lua.
if REB4LANCED.config.checkered_enhanced then
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
end

end
