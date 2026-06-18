# REB4LANCED — Copilot Instructions

## Project Overview

REB4LANCED is a balance mod for the game **Balatro**, built on the **Steamodded** framework. It reworks 100+ pieces of vanilla content (jokers, tarots, spectrals, tags, decks, stakes, vouchers, etc.) while making every change individually toggleable through an in-game settings UI.

- **Mod ID / prefix**: `reb4l`
- **Framework**: Steamodded `>=1.0.0~BETA-1221a`
- **Optional dependency**: JokerDisplay
- **Language**: Lua

## Architecture

There is no build/test/lint toolchain — the mod is loaded and run directly by Balatro via Steamodded. Testing means launching the game.

**Load order** (`REB4LANCED.lua` loads these in sequence):
1. `src/settings.lua` — config defaults and settings UI (must be first)
2. `src/patches.lua` — unconditional stat patches
3. `src/overrides.lua` — game function wrapping
4. Content files: `jokers`, `backs`, `enhancements`, `seals`, `tarots`, `editions`, `spectrals`, `stakes`, `tags`, `boosters`, `vouchers`
5. `src/jokerdisplay.lua` — JokerDisplay compatibility layer (loaded last, optional)

**Lovely patches** (`lovely/soul_rates.toml`) are applied at the engine level before Lua runs; they patch Soul and Black Hole spawn rates conditionally based on `REB4LANCED.config`.

## Key Conventions

### Always use `take_ownership`, never replace vanilla directly

```lua
SMODS.Joker:take_ownership('satellite', {
    loc_txt = { name = '...', text = { '...' } },
    config = { extra = { chips = 10 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { chips = card.ability.extra.chips }
        end
    end,
}, false)  -- false = don't create new content if key not found
```

The key passed to `take_ownership` is the bare vanilla identifier — **no class prefix** (e.g., `'satellite'` not `'j_satellite'`).

### Wrap all balance changes in a config check

Every non-patch rework must be guarded:

```lua
if REB4LANCED.config.feature_name then
    SMODS.Joker:take_ownership('key', { ... })
end
```

Unconditional stat patches (rarity, cost, pack size, enhancement/edition values) live in `src/patches.lua` and are the only changes that apply regardless of settings.

### Function override pattern

```lua
local reb4l_orig_function = ClassName.method_name
function ClassName:method_name(...)
    -- pre-logic if needed
    local result = reb4l_orig_function(self, ...)
    -- post-logic if needed
    return result
end
```

Override references are named with the `reb4l_orig_` prefix to avoid collisions with other mods.

### Pseudorandom seeding

Always use a descriptive key with the `reb4l_` prefix:

```lua
if pseudorandom(pseudoseed('reb4l_feature_name')) < 0.333 then
    -- ~33% chance
end
```

This prevents seed collisions with vanilla and other mods.

### Config keys

Config defaults are set at the top of `src/settings.lua`. Keys are lowercase with underscores. When adding a new toggle, add it there **and** add a corresponding UI element in the page-based settings builder.

### JokerDisplay

Any joker whose displayed stats or calculation logic changes must get a matching entry in `src/jokerdisplay.lua`. The mod must still function correctly when JokerDisplay is absent — guard all JokerDisplay code appropriately (it is already isolated to that file).

## Reference

`CHANGES.txt` documents every balance change with before/after values. Update it when adding or modifying a rework.

`DEV/REFERENCES/` contains vanilla and third-party reference implementations — useful for understanding baseline behavior before overriding it.
