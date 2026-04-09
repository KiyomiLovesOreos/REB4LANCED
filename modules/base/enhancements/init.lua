-- REB4LANCED Enhancements Module
return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "enhancements/"

    local function load_enhancement(name)
        assert(loadfile(path .. name .. ".lua"))()(REB4LANCED)
    end

    load_enhancement("mult_card")
    load_enhancement("stone_card")
    load_enhancement("wild_card")
end
