-- REB4LANCED Blinds Module
return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "blinds/"
    assert(loadfile(path .. "atlas.lua"))()
    assert(loadfile(path .. "wall.lua"))()(REB4LANCED)
    assert(loadfile(path .. "fire.lua"))()(REB4LANCED)
end
