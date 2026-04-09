return function(REB4LANCED)
-- Anchor Deck: hand size is permanently locked; change_size on G.hand is a no-op.
-- The actual blocking happens in the CardArea.change_size override in overrides.lua.
if REB4LANCED.config.anchor_deck ~= 1 then
local reb4l_anchor_text = REB4LANCED.config.anchor_deck == 3 and {
    '{C:money}Rerolls{} cost {C:money}$2{} more,',
    'but their price is {C:attention}fixed{}',
} or {
    '{C:attention}Hand size{} is {C:attention}locked{}',
    '{C:inactive}(Cannot be gained or lost)',
}
SMODS.Back({
    key = 'anchor',
    atlas = 'decks',
    pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'Anchor Deck',
        text = reb4l_anchor_text,
    },
    config = {},
    apply = function(self)
        G.GAME.modifiers = G.GAME.modifiers or {}
        if REB4LANCED.config.anchor_deck == 3 then
            G.GAME.modifiers.reb4l_fixed_reroll_cost = true
            G.GAME.modifiers.reb4l_fixed_reroll_cost_bonus =
                (G.GAME.modifiers.reb4l_fixed_reroll_cost_bonus or 0) + 2
        else
            G.GAME.reb4l_anchor_deck = true
        end
    end,
})
end

end
