-- REB4LANCED Consumables Module
return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "consumables/"

    local function load_tarot(name)
        assert(loadfile(path .. "tarots/" .. name .. ".lua"))()(REB4LANCED)
    end

    local function load_spectral(name)
        assert(loadfile(path .. "spectrals/" .. name .. ".lua"))()(REB4LANCED)
    end

    load_tarot("empress")
    load_tarot("heirophant")
    load_tarot("chariot")
    load_tarot("justice")
    load_tarot("devil")
    load_tarot("tower")
    load_tarot("lovers")
    load_tarot("wheel_of_fortune")
    load_spectral("sigil")
    load_spectral("ouija")
    load_spectral("ectoplasm")
end
