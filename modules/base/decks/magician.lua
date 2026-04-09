return function(REB4LANCED)
-- Magician Deck: Magic Trick + Illusion vouchers from the start.
if REB4LANCED.config.magician_deck then
SMODS.Back({
    key = 'magician',
    atlas = 'decks',
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'Magician Deck',
        text = {
            'Start with {C:attention,T:v_magic_trick}Magic Trick{}',
            'and {C:attention,T:v_illusion}Illusion{} vouchers',
        },
    },
    config = {},
    apply = function(self)
        for _, key in ipairs({ 'v_magic_trick', 'v_illusion' }) do
            G.GAME.used_vouchers[key] = true
            G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
            local k = key
            G.E_MANAGER:add_event(Event({
                func = function()
                    Card.apply_to_run(nil, G.P_CENTERS[k])
                    return true
                end
            }))
        end
    end,
})
end

end
