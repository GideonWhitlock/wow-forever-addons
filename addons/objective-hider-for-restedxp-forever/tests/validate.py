from __future__ import annotations

import math
import re
import sys
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "addon" / "RXPObjectiveHiderForever"
WORKSPACE = ROOT.parents[1]
sys.path.insert(0, str(WORKSPACE / "work" / "test-deps"))

from luaparser import ast  # type: ignore
from lupa import LuaRuntime  # type: ignore
from PIL import Image, ImageStat  # type: ignore


def check(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def syntax_checks() -> None:
    lua_files = sorted(ADDON.rglob("*.lua"))
    check(lua_files, "No Lua files found")
    for path in lua_files:
        ast.parse(path.read_text(encoding="utf-8"))


def toc_and_package_checks() -> None:
    toc = (ADDON / "RXPObjectiveHiderForever.toc").read_text(encoding="utf-8")
    check("## Interface: 16001" in toc, "Forever interface must be 16001")
    check("## Version: 1.0.1" in toc, "Unexpected release version")
    check("RXPObjectiveHiderForeverDB, RXPObjectiveHiderForeverBackupDB" in toc, "Safe variables/backup missing")
    check("OptionalDeps: RXPGuides, Questie" in toc, "Compatibility dependencies must remain optional")
    expected = ["Locale\\enUS.lua", "LegacyCleanup.lua", "Core.lua", "UI.lua", "Minimap.lua"]
    order = [line.strip() for line in toc.splitlines() if line.strip().endswith((".lua", ".xml"))]
    check(order == expected, f"Unexpected TOC load order: {order}")
    for relative in expected:
        check((ADDON / Path(relative.replace("\\", "/"))).is_file(), f"Missing TOC file: {relative}")
    check(not (ADDON / "Bindings.xml").exists(), "Forever-incompatible Bindings.xml remains in the package")
    check("Bindings.xml" not in toc and "<Binding" not in toc, "Forever-incompatible binding declaration remains")
    with tempfile.TemporaryDirectory() as tmp:
        archive = Path(tmp) / "candidate.zip"
        with zipfile.ZipFile(archive, "w") as zf:
            for path in ADDON.rglob("*"):
                if path.is_file():
                    zf.write(path, Path("RXPObjectiveHiderForever") / path.relative_to(ADDON))
        with zipfile.ZipFile(archive) as zf:
            names = zf.namelist()
            check("RXPObjectiveHiderForever/RXPObjectiveHiderForever.toc" in names, "TOC is not one folder below ZIP root")
            check(all(name.startswith("RXPObjectiveHiderForever/") for name in names), "Unexpected ZIP root")


def boundary_checks() -> None:
    source = "\n".join(path.read_text(encoding="utf-8") for path in ADDON.rglob("*.lua"))
    forbidden = {
        "RXPSettings": "RestedXP SavedVariables",
        "RXPCData": "RestedXP character data",
        "QuestieConfig": "Questie SavedVariables",
        "SendAddonMessage": "cross-addon messaging",
        "SetAttribute": "secure attributes",
        "UnregisterAllEvents": "Blizzard event removal",
        "ObjectiveTrackerFrame:SetParent": "tracker reparenting",
        "ObjectiveTrackerFrame:SetPoint": "tracker anchoring",
        "SetBinding": "binding mutation",
        "SetOverrideBinding": "override binding mutation",
        "BINDING_": "binding registration",
    }
    for needle, reason in forbidden.items():
        check(needle not in source, f"Forbidden {reason} surface present: {needle}")
    check("InCombatLockdown" in source and "PLAYER_REGEN_ENABLED" in source, "Combat deferral is incomplete")
    check("HookScript" in source and '"OnShow"' in source, "Tracker re-show suppression hook is missing")
    check('button:GetParent() ~= Minimap' in source, "Button collector ownership guard is missing")
    minimap = (ADDON / "Minimap.lua").read_text(encoding="utf-8")
    check(minimap.count("CreateTexture") == 1, "Launcher must have exactly one texture layer")
    check("CreateFontString" not in minimap and "button.state" not in minimap,
          "Artifact-prone minimap status glyph remains")
    check(not (ADDON / "KeyBinding.lua").exists(), "Unverified runtime keybinding implementation remains")
    check("SetBindingClick" not in source, "Unverified keybinding installation API remains")
    cleanup = (ADDON / "LegacyCleanup.lua").read_text(encoding="utf-8")
    non_cleanup = "\n".join(path.read_text(encoding="utf-8") for path in ADDON.rglob("*.lua")
                            if path.name != "LegacyCleanup.lua")
    for needle in ("EnableKeyboard", "SetPropagateKeyboardInput", "OnKeyDown", "OnKeyUp",
                   "ClearOverrideBindings", "ClearBindings"):
        check(needle not in non_cleanup, f"Keyboard/binding operation escaped legacy cleanup: {needle}")
    check("CreateFrame" not in cleanup, "Legacy cleanup must not create an input-owning frame")
    check("SetOverrideBinding" not in cleanup and "SetBindingClick" not in cleanup,
          "Legacy cleanup must not install a binding")
    check('pcall(panel.EnableKeyboard, panel, false)' in cleanup,
          "Legacy keyboard capture is not explicitly disabled")
    check('pcall(panel.SetPropagateKeyboardInput, panel, true)' in cleanup,
          "Legacy keyboard propagation is not explicitly restored")
    check('pcall(_G.ClearOverrideBindings, owner)' in cleanup,
          "Legacy override release is missing")


def artwork_checks() -> None:
    path = ADDON / "Media" / "Icon.tga"
    check(path.is_file(), "WoW TGA texture is missing")
    with Image.open(path) as image:
        image = image.convert("RGBA")
        check(image.size == (128, 128), f"Icon must be 128x128, got {image.size}")
        check(image.mode == "RGBA", f"Icon must retain alpha, got {image.mode}")
        alpha = image.getchannel("A")
        corners = [alpha.getpixel((0, 0)), alpha.getpixel((127, 0)), alpha.getpixel((0, 127)), alpha.getpixel((127, 127))]
        check(corners == [0, 0, 0, 0], f"Icon corners are not transparent: {corners}")
        bbox = alpha.getbbox()
        check(bbox is not None, "Icon alpha is empty")
        left, top, right, bottom = bbox
        check(min(left, top, 128 - right, 128 - bottom) >= 6, f"Circular frame lacks transparent safety margin: {bbox}")
        pixels = alpha.load()
        total = weighted_x = weighted_y = 0
        outside = opaque = 0
        for y in range(128):
            for x in range(128):
                value = pixels[x, y]
                total += value
                weighted_x += x * value
                weighted_y += y * value
                if value > 20:
                    opaque += 1
                    if math.hypot(x - 63.5, y - 63.5) > 59:
                        outside += 1
        centroid = (weighted_x / total, weighted_y / total)
        check(abs(centroid[0] - 63.5) <= 4 and abs(centroid[1] - 63.5) <= 4,
              f"Subject is not visually centered: {centroid}")
        check(outside / max(1, opaque) < 0.01, "Alpha silhouette is not cleanly circular")
        small = image.resize((32, 32), Image.Resampling.LANCZOS)
        stat = ImageStat.Stat(small.convert("RGB"), small.getchannel("A"))
        check(max(stat.rms) - min(stat.rms) > 8, "Minimap-size icon has weak color separation")


def minimap_geometry_checks() -> None:
    source = (ADDON / "Minimap.lua").read_text(encoding="utf-8")
    for needle in (
        'button:SetPoint("CENTER", Minimap, "CENTER", x, y)',
        "math.cos(angle) * width / 2",
        "math.sin(angle) * height / 2",
        'frame:RegisterEvent("DISPLAY_SIZE_CHANGED")',
        'frame:RegisterEvent("UI_SCALE_CHANGED")',
        "addon.db.minimap.angle = cursorAngle()",
    ):
        check(needle in source, f"Minimap rim geometry requirement missing: {needle}")
    for degrees in (0, 45, 90, 135, 180, 225, 270, 315):
        radians = math.radians(degrees)
        x, y = math.cos(radians) * 70, math.sin(radians) * 70
        ellipse = (x / 70) ** 2 + (y / 70) ** 2
        check(abs(ellipse - 1) < 1e-9, f"Rim test failed at {degrees} degrees")


def legacy_cleanup_checks() -> None:
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute(
        """
        cleanup = { override = 0, localBindings = 0, keyboard = nil, propagation = nil,
                    keyDownCleared = false, keyUpCleared = false, focusCleared = 0 }
        function ClearOverrideBindings(owner) cleanup.override = cleanup.override + 1 end
        RXPObjectiveHiderForeverBindingOwner = {
            ClearBindings = function() cleanup.localBindings = cleanup.localBindings + 1 end,
        }
        RXPObjectiveHiderForeverSettingsPanel = {
            capturingKey = true,
            EnableKeyboard = function(_, value) cleanup.keyboard = value end,
            SetPropagateKeyboardInput = function(_, value) cleanup.propagation = value end,
            SetScript = function(_, script, value)
                if script == "OnKeyDown" and value == nil then cleanup.keyDownCleared = true end
                if script == "OnKeyUp" and value == nil then cleanup.keyUpCleared = true end
            end,
        }
        legacyFocus = {
            GetName = function() return "RXPObjectiveHiderForeverLegacyEditBox" end,
            ClearFocus = function() cleanup.focusCleared = cleanup.focusCleared + 1 end,
        }
        function GetCurrentKeyBoardFocus() return legacyFocus end
        """
    )
    addon = lua.table()
    loader = lua.eval("function(code, name, addon) local f = assert(load(code, name)); return f(name, addon) end")
    loader((ADDON / "LegacyCleanup.lua").read_text(encoding="utf-8"), "RXPObjectiveHiderForever", addon)
    result = lua.globals().cleanup
    panel = lua.globals().RXPObjectiveHiderForeverSettingsPanel
    check(result.override == 1 and result.localBindings == 1, "Legacy-owned bindings were not released")
    check(result.keyboard is False and result.propagation is True, "Legacy keyboard propagation was not restored")
    check(result.keyDownCleared is True and result.keyUpCleared is True, "Legacy key scripts were not cleared")
    check(result.focusCleared == 1 and panel.capturingKey is None, "Legacy focus/capture state was not cleared")


def load_core():
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute(
        """
        SlashCmdList = {}
        DEFAULT_CHAT_FRAME = { AddMessage = function() end }
        UIParent = {}
        loadedRXPGuides = true
        loadedQuestie = true
        inCombat = false
        now = 100
        C_AddOns = { IsAddOnLoaded = function(name) return (name == "RXPGuides" and loadedRXPGuides) or (name == "Questie" and loadedQuestie) end }
        C_Timer = { After = function(_, callback) callback() end }
        function InCombatLockdown() return inCombat end
        function GetBuildInfo() return "1.60.1", "", "", 16001 end
        function GetTime() return now end
        function GetBindingAction() return "" end
        function CreateFrame(_, name)
            return {
                name = name,
                events = {},
                RegisterEvent = function(self, event) self.events[event] = true end,
                SetScript = function(self, script, callback) self[script] = callback end,
                GetName = function(self) return self.name end,
                ClearBindings = function(self) self.binding = nil end,
                SetBindingClick = function(self, _, key, button, mouse) self.binding = { key, button, mouse } end,
            }
        end
        ObjectiveTrackerFrame = {
            shown = true,
            hooks = {},
            IsShown = function(self) return self.shown end,
            Hide = function(self) self.shown = false end,
            Show = function(self) self.shown = true; if self.hooks.OnShow then self.hooks.OnShow(self) end end,
            HookScript = function(self, script, callback) self.hooks[script] = callback end,
        }
        RXPFrame = {
            shown = true,
            hooks = {},
            IsShown = function(self) return self.shown end,
            IsFeatureEnabled = function() return true end,
            HookScript = function(self, script, callback) self.hooks[script] = callback end,
        }
        """
    )
    addon = lua.table()
    loader = lua.eval("function(code, name, addon) local f = assert(load(code, name)); return f(name, addon) end")
    loader((ADDON / "Locale" / "enUS.lua").read_text(encoding="utf-8"), "RXPObjectiveHiderForever", addon)
    loader((ADDON / "Core.lua").read_text(encoding="utf-8"), "RXPObjectiveHiderForever", addon)
    addon.db = addon.SanitizeDB(lua.table())
    return lua, addon


def behavioral_checks() -> None:
    lua, addon = load_core()
    tracker = lua.globals().ObjectiveTrackerFrame
    ok = addon.ApplyNow("initial")
    check(ok is True and tracker.shown is False and addon.hiddenByUs is True, "Initial hide failed")
    addon.SetEnabled(False, "test")
    check(tracker.shown is True and addon.hiddenByUs is False, "Disable did not restore the prior shown state")
    for _ in range(20):
        addon.ToggleEnabled("repeat test")
    check(addon.db.enabled is False and tracker.shown is True, "Repeated on/off toggling did not end restored")
    lua.globals().inCombat = True
    addon.SetEnabled(True, "combat test")
    check(addon.pendingCombat is True and tracker.shown is True, "Combat change was not deferred")
    addon.SetEnabled(False, "combat final state")
    check(tracker.shown is True, "Combat toggle changed the tracker")
    lua.globals().inCombat = False
    addon.ApplyNow("combat ended")
    check(addon.pendingCombat is False and tracker.shown is True, "Latest post-combat state was not applied")
    db = lua.table()
    db.minimap = lua.table_from({"x": 0, "y": 20, "shown": True})
    migrated = addon.SanitizeDB(db)
    check(abs(migrated.minimap.angle - 90) < 0.001, f"Legacy minimap position migration failed: {migrated.minimap.angle}")


def documentation_checks() -> None:
    combined = "\n".join((ROOT / name).read_text(encoding="utf-8") for name in
                         ("README.md", "RESEARCH.md", "CURSEFORGE-DESCRIPTION-BLOCK.md", "RELEASE-CHECKLIST.md"))
    disclaimer = "not affiliated with, endorsed by, or supported by RestedXP"
    check(combined.lower().count(disclaimer.lower()) >= 2, "Independence disclaimer is not prominent enough")
    for term in ("RestedXP", "Forever", "Questie", "combat", "source-visible", "Owner accepted"):
        check(term.lower() in combined.lower() or term in (ADDON / "TESTING.md").read_text(encoding="utf-8"),
              f"Required documentation term missing: {term}")
    testing = (ADDON / "TESTING.md").read_text(encoding="utf-8")
    for phrase in ("transparent corners", "minimap rim", "20 times", "resolution/UI scale", "minimap-button collector"):
        check(phrase.lower() in testing.lower(), f"Targeted owner test missing: {phrase}")


def main() -> None:
    checks = [syntax_checks, toc_and_package_checks, boundary_checks, artwork_checks,
              minimap_geometry_checks, legacy_cleanup_checks, behavioral_checks, documentation_checks]
    for function in checks:
        function()
        print(f"PASS {function.__name__}")
    print(f"PASS all {len(checks)} validation groups")


if __name__ == "__main__":
    main()
