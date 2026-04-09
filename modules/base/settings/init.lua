return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "settings/"
    assert(loadfile(path .. "settings.lua"))()
end
