return function(REB4LANCED)
-- Tarot Tycoon: every shop has a free Mega Arcana Pack
-- extra = 1 nullifies vanilla's tarot_rate boost (4*extra); our free pack replaces it.
if REB4LANCED.config.tarot_tycoon_enhanced then
SMODS.Voucher:take_ownership('tarot_tycoon', {
    config = { extra = 1 },
    loc_txt = {
        name = 'Tarot Tycoon',
        text = {
            'Every shop has',
            'an additional {C:attention}free{}',
            '{C:tarot}Mega Arcana Pack{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_arcana_mega_1
        return { vars = {} }
    end,
    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                local booster = SMODS.add_booster_to_shop('p_arcana_mega_' .. math.random(1, 2))
                booster.ability.couponed = true
                booster:set_cost()
                return true
            end
        }))
    end,
    calculate = function(self, card, context)
        if context.starting_shop then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local booster = SMODS.add_booster_to_shop('p_arcana_mega_' .. math.random(1, 2))
                    booster.ability.couponed = true
                    booster:set_cost()
                    return true
                end
            }))
        end
    end,
}, false)
end -- REB4LANCED.config.tarot_tycoon_enhanced

end
