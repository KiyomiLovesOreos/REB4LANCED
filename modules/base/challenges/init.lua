return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "challenges/"
    assert(loadfile(path .. "stake_selection.lua"))()(REB4LANCED)
    assert(loadfile(path .. "challenge_progress.lua"))()(REB4LANCED)
    assert(loadfile(path .. "drifting.lua"))()(REB4LANCED)
end
