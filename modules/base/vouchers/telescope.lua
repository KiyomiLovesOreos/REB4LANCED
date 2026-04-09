return function(REB4LANCED)
-- Telescope: replace forced first-slot with 50% shop rate boost for most-played hand's planet
-- (Celestial packs made random in boosters.lua; shop boost in overrides.lua)
if REB4LANCED.config.telescope_enhanced then
SMODS.Voucher:take_ownership('telescope', {
    loc_txt = {
        name = 'Telescope',
        text = {
            '{C:planet}Planet{} cards in the {C:attention}shop{}',
            'have a {C:green}1{C:inactive} in {C:green}2{} chance',
            'to be your most played',
            '{C:attention}poker hand\'s{} planet',
        },
    },
}, false)
end -- REB4LANCED.config.telescope_enhanced

end
