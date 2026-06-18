return function(REB4LANCED)
if not REB4LANCED.config.magnet_vouchers then return end

-- Scry helpers: define if not already provided by Pokermon or another REB4LANCED module.
if type(create_scry_cardarea) ~= "function" then
    create_scry_cardarea = function()
        local config = { card_limit = 0, type = 'scry' }
        config.major = G.deck
        local scry_view = CardArea(0, 0, 2 * G.CARD_W, 0.5 * G.CARD_H, config)
        scry_view.T.x = G.TILE_W - G.deck.T.w / 2 - scry_view.T.w / 2 - 0.4
        scry_view.T.y = G.TILE_H - G.deck.T.h - scry_view.T.h
        scry_view:hard_set_VT()
        G.GAME.scry_amount = G.GAME.scry_amount or 0
        return scry_view
    end
end

if type(hide_scry_cardarea) ~= "function" then
    hide_scry_cardarea = function()
        G.scry_view.states.visible = false
        for i = #G.scry_view.cards, 1, -1 do
            G.scry_view.cards[i]:remove()
        end
    end
end

if type(update_scry_cardarea) ~= "function" then
    local function cards_dont_match(c1, c2)
        if type(c1) ~= type(c2) then return true end
        if c1.config.center   ~= c2.config.center   then return true end
        if c1.config.card_key ~= c2.config.card_key then return true end
        if c1.base.name  ~= c2.base.name  then return true end
        if c1.base.suit  ~= c2.base.suit  then return true end
        if c1.base.value ~= c2.base.value then return true end
        if type(c1.edition) ~= type(c2.edition) then return true end
        if c1.edition and c1.edition.type ~= c2.edition.type then return true end
        if c1.seal   ~= c2.seal   then return true end
        if c1.debuff ~= c2.debuff then return true end
        if c1.pinned ~= c2.pinned then return true end
        return false
    end

    update_scry_cardarea = function(scry_view)
        if not scry_view.states.visible then
            for i = #scry_view.cards, 1, -1 do scry_view.cards[i]:remove() end
            scry_view.states.visible = true
        end
        if scry_view.children.area_uibox then
            scry_view.children.area_uibox.states.visible = false
        end
        if scry_view.adjusting_cards then return end
        scry_view.adjusting_cards = true

        local deck = {}
        for i = 1, G.GAME.scry_amount do
            if #G.deck.cards + 1 <= i then break end
            deck[i] = G.deck.cards[#G.deck.cards + 1 - i]
        end
        deck[G.GAME.scry_amount + 1] = true

        local i = 1
        for k, card in pairs(deck) do
            while i <= #scry_view.cards and cards_dont_match(card, scry_view.cards[i]) do
                scry_view.cards[i]:start_dissolve({ G.C.PURPLE })
                i = i + 1
            end
            if k <= G.GAME.scry_amount and cards_dont_match(card, scry_view.cards[i]) then
                local temp = copy_card(card, nil, 0.7)
                temp.states.drag.can  = false
                temp.states.hover.can = false
                scry_view:emplace(temp)
                temp:start_materialize({ G.C.PURPLE })
            end
            i = i + 1
        end
        G.E_MANAGER:add_event(Event({
            func = function() scry_view.adjusting_cards = false; return true end
        }))
    end
end

SMODS.Voucher({
    key        = 'magnet',
    atlas      = 'vouchers',
    pos        = { x = 2, y = 0 },
    cost       = 10,
    unlocked   = true,
    discovered = false,
    available  = true,
    config     = { scry = 2 },
    loc_txt = {
        name = 'Magnet',
        text = {
            'See the top {C:purple}#1#{} cards',
            'of your deck while in blind',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.scry } }
    end,
    redeem = function(self, card)
        G.GAME.scry_amount = (G.GAME.scry_amount or 0) + self.config.scry
    end,
})

SMODS.Voucher({
    key        = 'electromagnet',
    atlas      = 'vouchers',
    pos        = { x = 3, y = 0 },
    cost       = 10,
    unlocked   = true,
    discovered = false,
    available  = true,
    requires   = { 'v_reb4l_magnet' },
    config     = { scry = 2 },
    loc_txt = {
        name = 'Electromagnet',
        text = {
            'See an additional {C:purple}+#1#{} cards',
            'of your deck while in blind',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.scry } }
    end,
    redeem = function(self, card)
        G.GAME.scry_amount = (G.GAME.scry_amount or 0) + self.config.scry
    end,
})

end
