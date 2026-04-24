return function(REB4LANCED)
-- Fork Deck: Split Tags + Fork Tags vouchers from the start.
if REB4LANCED.config.fork_tag_vouchers then
SMODS.Back({
    key   = 'fork',
    atlas = 'decks',
    pos   = { x = 4, y = 0 },   -- placeholder sprite
    loc_txt = {
        name = 'Fork Deck',
        text = {
            'Start with {C:attention,T:v_reb4l_split_tag}Split Tags{}',
            'and {C:attention,T:v_reb4l_fork_tag}Fork Tags{} vouchers',
        },
    },
    config = {},
    apply = function(self)
        for _, key in ipairs({ 'v_reb4l_split_tag', 'v_reb4l_fork_tag' }) do
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
        -- Blind select UI for ante 1 is built during start_run before apply fires.
        -- Queue a refresh so the fork tag picker shows on the first blind select screen.
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.blind_select_opts then
                    reb4l_refresh_blind_option('Small')
                    reb4l_refresh_blind_option('Big')
                end
                return true
            end
        }))
    end,
})
end

end
