
table.insert(water_tile_type_names, "nuclear-shallow")
table.insert(water_tile_type_names, "nuclear-crater")
table.insert(water_tile_type_names, "nuclear-deep")
table.insert(water_tile_type_names, "nuclear-crater-shallow-fill")
table.insert(water_tile_type_names, "nuclear-deep-shallow-fill")
table.insert(water_tile_type_names, "nuclear-deep-fill")

if(settings.startup["enable-medium-atomics"].value and settings.startup["enable-nuclear-tests"].value) then
  data.raw.technology["atomic-bomb"].unit.ingredients = {{"test-pack-atomic-20t-1", 1}}
  data.raw.technology["atomic-bomb"].unit.count = 1
  data.raw.technology["atomic-bomb"].unit.time = 1
end

local test_packs = {
  "test-pack-atomic-20t-1",
  "test-pack-atomic-500t-1",
  "test-pack-atomic-20t-3",
  "test-pack-atomic-1kt-1",
  "test-pack-atomic-15kt-1",
  "test-pack-atomic-2-stage-100kt-1",
}
for _, pack in pairs(test_packs) do
  if data.raw.tool[pack] then
    table.insert(data.raw["lab"]["lab"].inputs, pack)
  end
end

-- SchallTankPlatoon 2.0.2 references a removed base-game graphic; patch it to use the 2.0 smoke animation
if mods["SchallTankPlatoon"] and data.raw["smoke-with-trigger"]["Schall-poison-cloud"] then
  data.raw["smoke-with-trigger"]["Schall-poison-cloud"].animation = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud"].animation)
end

if mods["Atomic_Overhaul"] then
  require("compatibility.atomic-overhaul-final-fixes")
end

if mods["Krastorio2"] then
  require("compatibility.K2-final-fixes")
end

if mods["space-exploration"] then
  require("compatibility.SE-final-fixes")
end

if mods["apm_nuclear_ldinc"] then
  require("compatibility.APM-final-fixes")
end
