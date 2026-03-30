-- Standard pack sizes (4/6/6 instead of 3/5/4) — see src/patches.lua


-- Telescope rework: Celestial packs use random planets (shop rate boost handled in overrides.lua)
-- Vanilla Telescope forces first slot to most-played hand's planet; we remove that here.
SMODS.Booster:take_ownership_by_kind('Celestial', {
    create_card = function(self, card, i)
        return { set = 'Planet', area = G.pack_cards, skip_materialize = true, soulable = true, key_append = 'pl1' }
    end,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return { vars = { cfg.choose, cfg.extra }, key = self.key:sub(1, -3) }
    end,
}, true)
