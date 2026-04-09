-- REB4LANCED Decks Module
return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "decks/"

    local function load_deck(name)
        assert(loadfile(path .. name .. ".lua"))()(REB4LANCED)
    end

    load_deck("atlas")
    load_deck("abandoned")
    load_deck("checkered")
    load_deck("anaglyph")
    load_deck("black")
    load_deck("painted")
    load_deck("nebula")
    load_deck("burnt")
    load_deck("anchor")
    load_deck("workshop")
    load_deck("fork")
    load_deck("magician")
    load_deck("burnt_legacy")
end
