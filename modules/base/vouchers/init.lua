-- REB4LANCED Vouchers Module
return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "vouchers/"

    local function load_voucher(name)
        assert(loadfile(path .. name .. ".lua"))()(REB4LANCED)
    end

    load_voucher("atlas")
    load_voucher("hieroglyph")
    load_voucher("petroglyph")
    load_voucher("tarot_tycoon")
    load_voucher("planet_tycoon")
    load_voucher("magic_trick")
    load_voucher("illusion")
    load_voucher("telescope")
    load_voucher("observatory")
    load_voucher("fork_tags")
end
