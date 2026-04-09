return function(REB4LANCED)
-- Nebula Deck: remove -1 consumable slot penalty (consumeable_size patched in patches.lua)
-- Vanilla config.voucher = 'v_telescope' gives Telescope; we also grant Observatory.
if REB4LANCED.config.nebula_enhanced then
SMODS.Back:take_ownership('nebula', {
    loc_txt = {
        name = "Nebula Deck",
        text = {
            "Start with {C:attention,T:v_telescope}Telescope{}",
            "and {C:attention,T:v_observatory}Observatory{} Vouchers",
        },
    },
    apply = function(self, back)
        -- Vanilla handles Telescope via config.voucher; we add Observatory on top.
        G.GAME.used_vouchers['v_observatory'] = true
        G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
        G.E_MANAGER:add_event(Event({
            func = function()
                Card.apply_to_run(nil, G.P_CENTERS['v_observatory'])
                return true
            end
        }))
    end,
}, false)
end

-- ── New Content Decks ─────────────────────────────────────────────────────────

end
