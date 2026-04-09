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
            'and {C:attention,T:v_clearance_sale}Clearance Sale{} vouchers,',
            '{C:red}-1{} Hand per round',
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
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
                G.GAME.current_round.hands_left = G.GAME.current_round.hands_left - 1
                return true
            end
        }))
    end,
})
end

end
