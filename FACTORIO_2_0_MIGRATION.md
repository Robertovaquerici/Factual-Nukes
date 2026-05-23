# Factorio 1.1 → 2.0 Mod Migration Guide

Derived from migrating True-Nukes, Warheads, and True-Nukes-Graphics to Factorio 2.0.

---

## 1. `global` → `storage` (control scripts)

In all runtime Lua files (`control.lua`, etc.), rename every reference to the `global` table:

```lua
-- Before
global.my_data = {}
if global.some_value then ...

-- After
storage.my_data = {}
if storage.some_value then ...
```

---

## 2. `game.active_mods` → `script.active_mods`

```lua
-- Before
if game.active_mods["some-mod"] then ...

-- After
if script.active_mods["some-mod"] then ...
```

---

## 3. Rendering API: static setters → property assignment

The rendering API moved from static functions to object-property style:

```lua
-- Before
rendering.set_visible(id, false)
rendering.set_color(id, {r=1,g=0,b=0})

-- After
local obj = rendering.get_object_by_id(id)
obj.visible = false
obj.color = {r=1,g=0,b=0}
```

---

## 4. `hr_version` removed from sprites/entities

The `hr_version` sub-table inside sprite/animation definitions no longer exists. Remove it entirely from all sprite layers. The engine handles resolution automatically.

```lua
-- Before
picture = {
  filename = "foo.png",
  width = 64, height = 64,
  hr_version = {
    filename = "foo-hr.png",
    width = 128, height = 128,
  }
}

-- After
picture = {
  filename = "foo-hr.png",   -- just use the HR asset directly
  width = 128, height = 128,
}
```

---

## 5. `icon_mipmaps` removed

Remove all `icon_mipmaps = N` fields from item, recipe, technology, and entity definitions. The engine generates mipmaps automatically.

---

## 6. Collision mask format

Old string-with-hyphens → new underscore/short names inside a `layers` table:

```lua
-- Before (1.1 format — a plain array or old string keys)
collision_mask = {"water-tile", "player-layer", "item-layer"}

-- After (2.0 format)
collision_mask = {
  layers = {
    water_tile = true,
    player = true,
    item = true,
  }
}
```

Full rename table (1.1 → 2.0):

| 1.1 name | 2.0 name |
|---|---|
| `"water-tile"` | `water_tile` |
| `"ground-tile"` | `ground_tile` |
| `"resource-layer"` | `resource` |
| `"item-layer"` | `item` |
| `"object-layer"` | `object` |
| `"player-layer"` | `player` |
| `"doodad-layer"` | `doodad` |
| `"floor-layer"` | `floor` |

---

## 7. Recipe ingredients: shorthand → explicit dict

Recipe ingredients no longer accept the `{"name", count}` shorthand. Use explicit dicts:

```lua
-- Before
ingredients = {{"iron-plate", 5}, {"copper-plate", 2}}

-- After
ingredients = {
  {type="item", name="iron-plate", amount=5},
  {type="item", name="copper-plate", amount=2},
}
```

**IMPORTANT:** This applies to recipes only. Technology `unit.ingredients` still use the OLD shorthand format (see §8).

---

## 8. Technology `unit.ingredients`: still uses shorthand

Unlike recipes, technology research cost ingredients kept the old list format:

```lua
-- Correct for technologies in 2.0
unit = {
  count = 100,
  time = 30,
  ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
  }
}
```

Do NOT convert these to `{type="item", name=..., amount=N}` — that format is wrong for technologies and will cause a load error.

---

## 9. Recipe `result`/`result_count` → `results`

The single-output shorthand is gone. All recipes must use the `results` array:

```lua
-- Before
result = "iron-gear-wheel"
result_count = 2

-- After
results = {{type="item", name="iron-gear-wheel", amount=2}}
```

---

## 10. `emissions_per_second`: number → dict

Fire and smoke entities changed from a bare number to a named-pollution dict:

```lua
-- Before
emissions_per_second = 0.005

-- After
emissions_per_second = {pollution = 0.005}
```

---

## 11. Ammo items require top-level `ammo_category`

In 2.0, ammo items must have `ammo_category` as a top-level field in addition to (or instead of) `ammo_type.category`:

```lua
-- Before (1.1 — only inside ammo_type)
{
  type = "ammo",
  name = "my-rocket",
  ammo_type = {
    category = "rocket",
    -- ...
  }
}

-- After (2.0 — required at top level too)
{
  type = "ammo",
  name = "my-rocket",
  ammo_category = "rocket",   -- required at top level
  ammo_type = {
    category = "rocket",
    -- ...
  }
}
```

---

## 12. Tile transitions format completely changed

The old per-direction sprite-table format (`main`, `inner_corner`, `outer_corner`, etc. with arrays of `{picture, count, ...}`) was replaced by a `spritesheet + layout` format in 2.0.

**Recommended approach:** If your mod deepcopies a base-game tile that already has 2.0-format transitions, the deepcopy inherits them for free. Remove all custom transition-generation code and let the engine handle it.

If you need truly custom transitions, refer to the Factorio 2.0 tile prototype documentation for the new `spritesheet`/`layout` format.

---

## 13. Renamed/removed items

| 1.1 item name | 2.0 replacement |
|---|---|
| `empty-barrel` | `barrel` |
| `rocket-control-unit` | **removed** — delete from recipes and technology prerequisites |

---

## 14. Custom science packs must be added to a lab's `inputs`

In 2.0, Factorio validates that every science pack used by a technology is accepted by at least one lab. If your mod creates custom `tool`-type science packs, add them to `data.raw["lab"]["lab"].inputs` in `data-final-fixes.lua`:

```lua
-- data-final-fixes.lua
local my_custom_packs = {
  "my-science-pack-1",
  "my-science-pack-2",
}
for _, pack in pairs(my_custom_packs) do
  if data.raw.tool[pack] then
    table.insert(data.raw["lab"]["lab"].inputs, pack)
  end
end
```

---

## 15. Technology prerequisites: remove dead references

Check all `prerequisites` arrays for technologies that no longer exist in 2.0 (e.g. `rocket-control-unit`). Remove them. Common ones that moved or were removed:

- `rocket-control-unit` — **removed entirely**

---

## General approach

1. Load the mod, read the first error, fix it.
2. After each fix, grep the whole mod directory for similar patterns to fix them all at once before reloading.
3. When something is removed from the base game, check `C:\Program Files (x86)\Steam\steamapps\common\Factorio\data\base\prototypes\` to find what replaced it.
4. The base game's own files are the ground truth for correct 2.0 format — when in doubt, find an analogous vanilla entity and copy its structure.
