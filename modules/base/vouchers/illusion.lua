return function(REB4LANCED)
-- Illusion: playing cards in shop are clones of cards in your deck, and their
-- upgrades are rerolled while preserving copied ones if no new roll lands.
if REB4LANCED.config.illusion_enhanced then
SMODS.Voucher:take_ownership('illusion', {
    loc_txt = {
        name = 'Illusion',
        text = {
            '{C:attention}Playing cards{} in shop are',
            '{C:attention}clones{} of cards in your {C:attention}deck{},',
            'and their upgrades can be {C:attention}rerolled{}',
        },
    },
}, false)
end -- REB4LANCED.config.illusion_enhanced

end
