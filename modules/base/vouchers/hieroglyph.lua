return function(REB4LANCED)
if REB4LANCED.config.hieroglyph_rework then
SMODS.Voucher:take_ownership('hieroglyph', {
    loc_txt = {
        name = 'Hieroglyph',
        text = {
            '{C:attention}-#1#{} Ante,',
            '{C:red}-#1#{} discard',
            'each round',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    redeem = function(self, card)
        ease_ante(-card.ability.extra)
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - card.ability.extra
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra
        ease_discard(-card.ability.extra)
    end,
}, false)
end
end
