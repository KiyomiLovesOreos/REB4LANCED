local REB4LANCED = SMODS.current_mod
_G.REB4LANCED = REB4LANCED

REB4LANCED.module_roots = {
    base = REB4LANCED.path .. "modules/base/",
    crossmod = REB4LANCED.path .. "modules/crossmod/",
}

local function load_module(path)
    local chunk, err = loadfile(REB4LANCED.module_roots.base .. path)
    if not chunk then
        print("[REB4LANCED] Failed to load " .. path .. ": " .. tostring(err))
        return
    end

    local ok, init = pcall(chunk)
    if not ok then
        print("[REB4LANCED] Error in " .. path .. ": " .. tostring(init))
        return
    end

    if type(init) == "function" then
        local success, msg = pcall(init, REB4LANCED)
        if not success then
            print("[REB4LANCED] " .. path .. " failed: " .. tostring(msg))
        end
    end
end

load_module("settings/init.lua")
load_module("hooks/init.lua")
load_module("jokers/init.lua")
load_module("decks/init.lua")
load_module("enhancements/init.lua")
load_module("seals/init.lua")
load_module("consumables/init.lua")
load_module("editions/init.lua")
load_module("stakes/init.lua")
load_module("blinds/init.lua")
load_module("tags/init.lua")
load_module("boosters/init.lua")
load_module("vouchers/init.lua")
load_module("displays/init.lua")
