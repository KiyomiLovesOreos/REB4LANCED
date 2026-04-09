return function(REB4LANCED)
-- ── Fork Tag Vouchers ─────────────────────────────────────────────────────────
-- T1 Split Tags: when you skip a blind, choose 1 of 2 offered tags.
-- T2 Fork Tags : when you skip a blind, gain both tags (upgrades T1).
if REB4LANCED.config.fork_tag_vouchers then

SMODS.Voucher({
    key          = 'split_tag',
    atlas        = 'vouchers',
    pos          = { x = 0, y = 0 },
    cost         = 6,
    unlocked     = true,
    discovered   = false,
    available    = true,
    loc_txt = {
        name = 'Split Tags',
        text = {
            'When you {C:attention}skip{} a blind,',
            'choose {C:attention}1{} of {C:attention}3{} offered Tags',
        },
    },
})

SMODS.Voucher({
    key          = 'fork_tag',
    atlas        = 'vouchers',
    pos          = { x = 1, y = 0 },   -- placeholder sprite
    cost         = 8,
    unlocked     = true,
    discovered   = false,
    available    = true,
    requires     = { 'v_reb4l_split_tag' },
    loc_txt = {
        name = 'Fork Tags',
        text = {
            'When you {C:attention}skip{} a blind,',
            'choose {C:attention}2{} of {C:attention}3{} offered Tags',
        },
    },
})

end -- REB4LANCED.config.fork_tag_vouchers
end
