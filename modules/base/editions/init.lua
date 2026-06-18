-- REB4LANCED Editions Module
return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "editions/"
    assert(loadfile(path .. "holo.lua"))()(REB4LANCED)
end
