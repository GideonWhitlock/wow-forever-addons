local F = {}

DEFAULT_CHAT_FRAME = { AddMessage = function() end }
function InCombatLockdown() return false end

local core = assert(loadfile("work/MinimapButtonForever/Core.lua"))
core("MinimapButtonForever", F)
local ui = assert(loadfile("work/MinimapButtonForever/UI.lua"))
ui("MinimapButtonForever", F)

MinimapButtonForeverDB = { vertical = true }
F.LoadSettings()
assert(F.GetLayoutMode() == "vertical", "legacy vertical layouts should migrate unchanged")
assert(F.db.vertical == true, "legacy vertical compatibility flag should remain synchronized")
assert(F.db.gridColumns == 4, "grid width should default to four columns")

local layoutCalls, syncCalls = 0, 0
F.Layout = function() layoutCalls = layoutCalls + 1 end
F.SyncOptions = function() syncCalls = syncCalls + 1 end
F.SetLayoutMode("grid")
assert(F.GetLayoutMode() == "grid", "grid should become the saved layout")
assert(F.db.vertical == false, "grid must not masquerade as the legacy vertical layout")
assert(layoutCalls == 1 and syncCalls == 1, "changing layout should redraw and synchronize settings")

F.SetGridColumns(12)
assert(F.db.gridColumns == 8, "grid columns should clamp to eight")
F.SetGridColumns(1)
assert(F.db.gridColumns == 2, "grid columns should clamp to two")

local width, height, columns = F.GetLayoutDimensions(7, 32, 4, "grid", 4)
assert(width == 148 and height == 76 and columns == 4,
    "seven buttons should form a four-by-two grid with the expected spacing")
width, height, columns = F.GetLayoutDimensions(1, 32, 4, "grid", 4)
assert(width == 40 and height == 40 and columns == 1,
    "a collapsed grid should keep the controller in one square cell")

print("Minimap grid layout tests passed")
