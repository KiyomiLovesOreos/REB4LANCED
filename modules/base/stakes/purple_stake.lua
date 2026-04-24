return function(REB4LANCED)
if REB4LANCED.config.stakes_enhanced then

local mode = REB4LANCED.config.purple_stake_mode or 1

-- Give Pinned a badge sprite (vanilla has none).
-- Sprite sits at position x=0, y=0 in assets/Stickers.png.
SMODS.Sticker:take_ownership('pinned', {
    atlas = 'reb4l_stickers',
    pos   = { x = 0, y = 0 },
}, true)

if mode == 1 then
    SMODS.Stake:take_ownership('stake_purple', {
        loc_txt = {
            name = "Purple Stake",
            text = {
                "{C:attention}Vouchers{} cost {C:money}$2{} more",
            },
        },
        modifiers = function()
            G.GAME.modifiers.reb4l_voucher_cost_bonus = 2
        end,
    }, true)
else
    SMODS.Stake:take_ownership('stake_purple', {
        loc_txt = {
            name = "Purple Stake",
            text = {
                "Shop can have {C:attention}Pinned{} Jokers",
                "{C:inactive,s:0.8}(Cannot be {C:attention,s:0.8}moved {C:inactive,s:0.8}from the {C:attention,s:0.8}leftmost position{})",
            },
        },
        modifiers = function()
            G.GAME.modifiers.reb4l_enable_pinned_in_shop = true
        end,
    }, true)

    local reb4l_orig_create_card = create_card
    function create_card(_type, area, legendary, rarity, skip_materialize, soulable, forced_key, seed)
        local card = reb4l_orig_create_card(_type, area, legendary, rarity, skip_materialize, soulable, forced_key, seed)
        if card and _type == 'Joker' and area == G.shop_jokers
            and G.GAME and G.GAME.modifiers and G.GAME.modifiers.reb4l_enable_pinned_in_shop then
            if pseudorandom('reb4l_shop_pinned') > 0.7 then
                card:add_sticker('pinned', true)
            end
        end
        return card
    end
end

end
end
