return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "settings/"
    assert(loadfile(path .. "presets.lua"))()
    assert(loadfile(path .. "settings.lua"))()
end
