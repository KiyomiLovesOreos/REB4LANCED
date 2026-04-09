return function(REB4LANCED)
-- Anaglyph Deck: every tag gained creates one more of itself (deck passive, no Double Tag needed).
-- The vanilla boss-beat Double Tag is suppressed by lovely/anaglyph.toml.
if REB4LANCED.config.anaglyph_enhanced then
SMODS.Back:take_ownership('anaglyph', {
    loc_txt = {
        name = "Anaglyph Deck",
        text = {
            "Gain {C:attention}2{} of every {C:attention}Tag",
            "{C:inactive}instead of {C:attention}1",
        },
    },
    apply = function(self, back)
        G.GAME.reb4l_anaglyph_active = true
    end,
}, false)
end

end
