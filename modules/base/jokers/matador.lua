return function(REB4LANCED)
-- Matador: $5 every hand played in any blind (vanilla: $8 when playing boss blind's required hand)
-- Cost patched in src/patches.lua
if REB4LANCED.config.matador_enhanced then
SMODS.Joker:take_ownership('matador', {
    config = { extra = 5 },
    loc_txt = {
        name = 'Matador',
        text = {
            'Earn {C:money}$#1#{} every time',
            'a {C:attention}hand{} is played',
            'during a {C:attention}Boss Blind{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calculate = function(self, card, context)
        if context.after and G.GAME.blind and G.GAME.blind.boss then
            return {
                dollars = card.ability.extra,
                message = localize { type = 'variable', key = 'a_dollars', vars = { card.ability.extra } },
                colour = G.C.MONEY,
            }
        end
    end,
}, false)
end -- REB4LANCED.config.matador_enhanced

end
