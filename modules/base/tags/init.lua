-- REB4LANCED Tags Module
return function(REB4LANCED)
    local path = REB4LANCED.module_roots.base .. "tags/"

    local function load_tag(name)
        assert(loadfile(path .. name .. ".lua"))()(REB4LANCED)
    end

    load_tag("atlas")
    load_tag("grasp")
    load_tag("surplus")
    load_tag("negative")
    load_tag("foil")
    load_tag("holo")
    load_tag("polychrome")
    load_tag("standard")
    load_tag("charm")
    load_tag("meteor")
    load_tag("buffoon")
    load_tag("ethereal")
    load_tag("uncommon")
    load_tag("rare")
    load_tag("voucher")
    load_tag("garbage")
    load_tag("coupon")
    load_tag("double")
    load_tag("orbital")
    load_tag("economy")
end
