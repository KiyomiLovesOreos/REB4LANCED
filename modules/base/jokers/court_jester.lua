return function(REB4LANCED)
-- Court Jester: a random source rank counts as a random target rank; changes each round.
-- Rank substitution is handled globally via the Card.get_id override in overrides.lua,
-- so it applies to scoring, discards, Hit the Road, and all cross-mod jokers automatically.
if REB4LANCED.config.joker_set_rank then
SMODS.Joker({
    key    = 'court_jester',
    atlas  = 'reb4l_jokers',
    pos    = { x = 8, y = 0 },
    rarity = 2,
    cost   = 5,
    config = { extra = { source_rank = 0, target_rank = 0, source_name = '?', target_name = '?' } },
    loc_txt = {
        name = 'Court Jester',
        text = {
            '{C:attention}#1#{}s count as {C:attention}#2#{}s',
            'Changes each {C:attention}round{}',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.source_name, card.ability.extra.target_name } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            local seen = {}
            local pool = {}
            for _, c in ipairs(G.playing_cards) do
                if not seen[c.base.id] then
                    seen[c.base.id] = true
                    pool[#pool + 1] = c
                end
            end
            if #pool >= 2 then
                local src_idx = math.floor(pseudorandom('reb4l_cj_src') * #pool) + 1
                local src     = pool[src_idx]
                local tgt_pool = {}
                for _, c in ipairs(pool) do
                    if c.base.id ~= src.base.id then
                        tgt_pool[#tgt_pool + 1] = c
                    end
                end
                local tgt_idx = math.floor(pseudorandom('reb4l_cj_tgt') * #tgt_pool) + 1
                local tgt     = tgt_pool[tgt_idx]
                card.ability.extra.source_rank = src.base.id
                card.ability.extra.target_rank = tgt.base.id
                card.ability.extra.source_name = src.base.value
                card.ability.extra.target_name = tgt.base.value
                return {
                    message = src.base.value .. 's → ' .. tgt.base.value .. 's',
                    colour  = G.C.FILTER,
                }
            end
        end
    end,
})
end -- REB4LANCED.config.joker_set_rank

end
