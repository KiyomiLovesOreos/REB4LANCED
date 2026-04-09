return function(REB4LANCED)
if REB4LANCED.config.edition_tags_enhanced then
SMODS.Tag:take_ownership('negative', {
    min_ante = 2,
    loc_txt = {
        name = 'Negative Tag',
        text = {
            'Next {C:attention}editionless{} Joker',
            'bought from the {C:attention}shop{}',
            'gains {C:dark_edition}Negative{} edition',
        },
    },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' or context.type == 'store_joker_modify' then return true end
    end,
    in_pool = function(self, args)
        return G.P_CENTERS.e_negative.discovered
    end,
}, false)
end
end
