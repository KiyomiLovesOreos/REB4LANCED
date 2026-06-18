-- REB4LANCED Seals Module
return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "seals/"
    assert(loadfile(path .. "blue_seal.lua"))()(REB4LANCED)
end
