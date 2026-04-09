return function(REB4LANCED)
-- Mail-In Rebate: Uncommon (vanilla: Common)
if REB4LANCED.config.mail_rebate_enhanced then
SMODS.Joker:take_ownership('mail', {
    rarity = 2,
}, false)
end

end
