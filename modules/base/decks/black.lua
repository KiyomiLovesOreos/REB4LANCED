return function(REB4LANCED)
-- Black Deck: start at Ante 0 (keeps vanilla -1 hand, +1 joker slot)
if REB4LANCED.config.black_deck_enhanced then
SMODS.Back:take_ownership('black', {
    loc_txt = {
        name = "Black Deck",
        text = {
            "Start at {C:attention}Ante 0{},",
            "{C:red}-1{} Hand, {C:attention}+1{} Joker slot",
        },
    },
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.5,
            func = function()
                local rr = G.GAME and G.GAME.round_resets
                if rr then
                    rr.ante      = 0
                    rr.ante_disp = number_format(0)
                    rr.blind_ante = 0
                    if rr.blind_choices then rr.blind_choices.Boss = get_new_boss() end
                    if rr.blind_tags then
                        rr.blind_tags.Small = get_next_tag_key()
                        rr.blind_tags.Big   = get_next_tag_key()
                    end
                end
                return true
            end
        }))
    end,
}, false)
end

end
