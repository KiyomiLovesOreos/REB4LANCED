-- REB4LANCED Boosters Module
return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "boosters/"
    assert(loadfile(path .. "celestial.lua"))()(REB4LANCED)
end
