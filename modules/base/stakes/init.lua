-- REB4LANCED Stakes Module
return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "stakes/"

    local function load_stake(name)
        assert(loadfile(path .. name .. ".lua"))()(REB4LANCED)
    end

    load_stake("red_stake")
    load_stake("green_stake")
    load_stake("black_stake")
    load_stake("blue_stake")
    load_stake("purple_stake")
    load_stake("orange_stake")
    load_stake("gold_stake")
    load_stake("perishable_sticker")
end
