return function(REB4LANCED)
-- Nebula Deck: remove -1 consumable slot penalty (consumeable_size patched in patches.lua)
-- Starts with Telescope + Planet Merchant
if REB4LANCED.config.nebula_enhanced then
SMODS.Back:take_ownership('nebula', {
    loc_txt = {
        name = "Nebula Deck",
        text = {
            "Start with {C:attention,T:v_telescope}Telescope{}",
            "and {C:attention,T:v_planet_merchant}Planet Merchant{} Vouchers",
        },
    },
    apply = function(self, back)
        G.GAME.used_vouchers['v_planet_merchant'] = true
        G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
        G.E_MANAGER:add_event(Event({
            func = function()
                Card.apply_to_run(nil, G.P_CENTERS['v_planet_merchant'])
                return true
            end
        }))
    end,
}, false)
end

-- ── New Content Decks ─────────────────────────────────────────────────────────

end
