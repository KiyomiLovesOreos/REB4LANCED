return function(REB4LANCED)
if not REB4LANCED.config.nc_boss_blinds then return end

local function is_fire_blind()
    return G.GAME and G.GAME.blind
        and G.GAME.blind.config and G.GAME.blind.config.blind
        and G.GAME.blind.config.blind.key == 'bl_reb4l_fire'
end

local function fire_tick(blind)
    blind.chips     = math.floor(blind.chips * 1.1)
    blind.chip_text = number_format(blind.chips)
    blind.triggered = true
    blind:wiggle()
end

-- Hook to catch joker activations (blind.calculate only sees the 'individual' area).
local _orig_calc_areas = SMODS.calculate_card_areas
SMODS.calculate_card_areas = function(_type, context, effects, ...)
    local n_before = effects and #effects or 0
    _orig_calc_areas(_type, context, effects, ...)
    if _type == 'jokers' and context.individual and is_fire_blind() then
        local blind = G.GAME.blind
        for i = n_before + 1, effects and #effects or 0 do
            local e = effects[i]
            if type(e) == 'table'
                and (e.mult or e.chips or e.x_mult or e.dollars or e.message) then
                fire_tick(blind)
            end
        end
    end
end

SMODS.Blind({
    key         = 'fire',
    mult        = 2,
    boss        = { showdown = true, min = 10, max = 10 },
    atlas       = 'reb4l_blinds',
    pos         = { x = 0, y = 0 },
    boss_colour = HEX('922525'),
    dollars     = 8,
    loc_txt = {
        name = 'The Raging Pyre',
        text = {
            'Each scoring trigger increases',
            'the blind by {C:red}X1.1{}',
        },
    },
    calculate = function(self, context)
        -- Live: each scoring card evaluation immediately grows the blind.
        if context.individual and not self.disabled then
            fire_tick(self)
        end

        -- ── Batch version (saved for reference) ────────────────────────────
        -- if context.individual and not blind.disabled then
        --     blind.reb4l_fire_count = (blind.reb4l_fire_count or 0) + 1
        -- end
        -- if context.after and not blind.disabled then
        --     local count = blind.reb4l_fire_count or 0
        --     if count > 0 then
        --         blind.chips     = math.floor(blind.chips * (1.1 ^ count))
        --         blind.chip_text = number_format(blind.chips)
        --         blind.triggered = true
        --         blind:wiggle()
        --     end
        --     blind.reb4l_fire_count = 0
        -- end
        -- ───────────────────────────────────────────────────────────────────
    end,
})

end
