return function(REB4LANCED)

local function reb4l_erratic_randomize()
    local suit_keys, rank_keys = {}, {}
    for _, v in pairs(SMODS.Suits) do
        if not v.disabled then table.insert(suit_keys, v.card_key) end
    end
    for _, v in pairs(SMODS.Ranks) do
        if not v.disabled then table.insert(rank_keys, v.card_key) end
    end
    table.sort(suit_keys)
    table.sort(rank_keys)

    for i, card in ipairs(G.playing_cards) do
        local si = math.floor(pseudorandom(pseudoseed('reb4l_err_s' .. i)) * #suit_keys) + 1
        local ri = math.floor(pseudorandom(pseudoseed('reb4l_err_r' .. i)) * #rank_keys) + 1
        local key = suit_keys[si] .. '_' .. rank_keys[ri]
        if G.P_CARDS[key] then card:set_base(G.P_CARDS[key]) end
    end
end

SMODS.Back:take_ownership('erratic', {
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                reb4l_erratic_randomize()
                return true
            end
        }))
    end,
}, false)

end
