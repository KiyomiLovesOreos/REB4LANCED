return function(REB4LANCED)
-- Workshop Deck: Overstock + Clearance Sale vouchers, -1 hand per round.
if REB4LANCED.config.workshop_deck then
SMODS.Back({
    key = 'workshop',
    atlas = 'decks',
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Workshop Deck',
        text = {
            'Start with {C:attention,T:v_overstock_norm}Overstock{}',
            'and {C:attention,T:v_clearance_sale}Clearance Sale{} vouchers',
        },
    },
    config = {},
    apply = function(self)
        -- Grant both vouchers manually.
        for _, key in ipairs({ 'v_overstock_norm', 'v_clearance_sale' }) do
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
