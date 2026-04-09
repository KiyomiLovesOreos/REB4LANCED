return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "hooks/"
    assert(loadfile(path .. "patches.lua"))()
    assert(loadfile(path .. "overrides.lua"))()
end
