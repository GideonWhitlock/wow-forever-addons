# Test record and live checklist

## Completed automated checks

- TOC interface, SavedVariables, file order, title, author, version, licence metadata, and referenced-file existence.
- Lua syntax parsing for every shipped Lua file.
- Static guardrails against legacy global add-on APIs, automatic `ReloadUI`, arbitrary console execution, chat transmission, and character/realm collection.
- Deterministic model tests for missing dependencies, disabled dependencies, interface mismatch, load-on-demand handling, severity ordering, report redaction, and report limitations.
- Package structure check: a single top-level `AddonHealthManagerForever/` directory.

## Owner acceptance

On 2026-10-11 the owner accepted the installed visual and interaction behaviour, then found a release-blocking diagnostic miss: Blizzard displayed `RXPObjectiveHiderForever/Bindings.xml:2 Unrecognized XML: Binding`, but the manager discarded it because it was a warning rather than an error. Candidate `1.0.0-rc2` corrected that filter, and the owner subsequently approved the corrected behavior for public release as `1.0.0`. Existing SavedVariables remain compatible.

## Practical regression checklist

Use Forever `1.60.1.70338` or record the newer exact build.

1. Back up `WTF/Account/<account>/SavedVariables/AddonHealthManagerForever.lua` if it exists.
2. Install the add-on and enable Lua errors.
3. Confirm login produces no error and `/ahm` opens the window.
4. Confirm left-click, right-click, `/ahm show`, and `/ahm hide` on the minimap control.
5. Confirm the custom gold-and-green medallion renders—not a black disc—both on the minimap and, when Minimap Button: Forever collects it, in that add-on's launcher bar.
6. Temporarily show it directly on the minimap if necessary, then drag it around the full circle. Check the four cardinal and four diagonal positions against a known-correct neighbouring add-on button: the medallion's visible centre—not the 54px border texture's bounds—must remain centred on the visible circular rim, with no above-left drift.
7. Leave the button at a diagonal, reload, and confirm the saved angle is preserved. Then change UI scale and any enabled minimap-size setting and confirm the button reflows onto the resized ring.
8. Confirm window drag and position persistence across `/reload`.
9. Compare at least five entries with Blizzard’s AddOn List.
10. Disable a required dependency for a test module, reload, and verify the wording.
11. Use a known load-on-demand module and confirm it is informational, not marked broken.
12. Use a deliberately outdated test TOC and verify interface wording without asserting incompatibility when it still loads.
13. Trigger a harmless test Lua error from a disposable test add-on. Verify count/path attribution and confirm no character, realm, locals, or stack content appears in the exported report.
14. Stage a disable, use `/ahm undo`, reload, and verify the original state. Then repeat and apply the staged state.
15. Corrupt or delete the SavedVariables file only after backing it up; verify recovery to defaults.
16. Test at UI scales 0.64, 0.8, and 1.0 and at 1920×1080 and one ultrawide resolution if available.
17. Spend ten minutes in combat and compare profiler values with Blizzard’s own AddOn List; verify the UI describes them as observations, not causation.

## Session-warning regression test

1. Keep the test `RXPObjectiveHiderForever` warning active or reproduce an equivalent disposable `Bindings.xml` warning.
2. Confirm Blizzard's Lua warning window shows the add-on path and count.
3. Open `/ahm` and click **Scan now**.
4. Confirm **Review** is at least 1 and the summary does not say the error scan is clean.
5. Select `RXPObjectiveHiderForever`; confirm its detail says Blizzard's list contains a Lua/XML warning occurrence whose path points to it.
6. Open **Report**; confirm it says session error visibility is available and reports the warning count without including the raw message, stack, locals, character, realm or SavedVariables.
7. Close/reload in a state where `ScriptErrorsFrame` is unavailable if reproducible; confirm the summary explicitly says error visibility is unavailable or limited rather than reporting a clean scan.

## Unverified scenarios

- Secure/secret error values in a tainted context.
- More than 100 installed add-ons.
- Non-English clients (strings are isolated but only enUS is supplied).
- Gamepad interface transitions.
- Glue-screen use; this add-on is intended for logged-in play.
- A Forever build newer than `70338`.

The owner approved the corrected current installed behaviour for launch. Items listed under **Unverified scenarios** remain honest limitations rather than silently claimed coverage.
