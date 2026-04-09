-- REB4LANCED Blinds Module
return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "blinds/"
    assert(loadfile(path .. "wall.lua"))()(REB4LANCED)
end
