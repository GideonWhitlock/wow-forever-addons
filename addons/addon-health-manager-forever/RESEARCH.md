# Evidence and competitor boundary

Research date: 2026-10-11 (Europe/London)
Installed client: WoW Forever `1.60.1.70338`
Interface: `16001`
Build-matched UI source: Gethe mirror, `forever` commit `943764493e6b16d63ded3ab304150d1f05e58b57`

## API feasibility

| Capability | Evidence | MVP decision |
|---|---|---|
| Installed, enabled, loaded, loadable and load-on-demand state | `C_AddOns` generated documentation | Included |
| Required and optional dependencies | `C_AddOns.GetAddOnDependencies` and `GetAddOnOptionalDependencies` | Included; only required dependencies affect health |
| Interface mismatch | `C_AddOns.GetAddOnInterfaceVersion`; Blizzard AddOn List uses `INTERFACE_VERSION` | Included |
| Client-recorded load error | `C_AddOns.DoesAddOnHaveLoadError` | Included; distinguished from later runtime errors |
| CPU/time demand | `C_AddOnProfiler` is available and documented as enabled for all users | Included as raw recent/session/peak milliseconds; no invented universal threshold |
| Memory | Blizzard AddOn List still calls `GetAddOnMemoryUsage` | Included as context only; never called an FPS diagnosis |
| Session Lua errors and Lua/XML warnings | `ScriptErrorsFrame:GetErrorData` exposes current-session message type, count, message and stack when Blizzard’s frame exists; generated API documents `LUA_WARNING` | Included as best-effort path attribution. Both message types are counted; the official warning event provides a privacy-safe, post-load fallback when the full list is unavailable. No error-handler replacement |
| Protected-action evidence | `ADDON_ACTION_FORBIDDEN` supplies an add-on name | Session counter is captured for future UI use; not yet promoted into a diagnosis |
| Enable/disable recovery | `C_AddOns.EnableAddOn`, `DisableAddOn`, and `SaveAddOns` | Included as staged next-reload actions with undo; never disable self |
| Exact conflict detection | No authoritative API | Impossible. Only possible shared ownership is shown, explicitly not a conflict finding |
| Exact root-cause attribution | An error stack can name multiple add-ons and taint propagates | Impossible. Directory-path matches are clues only |
| Installation/update timestamps | Not exposed to in-game add-ons | Impossible before this add-on’s first snapshot |
| Repair verification | Requires reproducing the user’s symptom after a controlled change | Impossible to automate honestly |

## Competitor boundary

| Product | Strength | Boundary for Addon Health Manager |
|---|---|---|
| Blizzard AddOn List | Authoritative enable state, dependency display, memory and modern performance values | We explain the same evidence in task-oriented language and add support reporting; we do not replace its loadout role |
| Addon Control Panel | In-game management, sets, module grouping, dependencies, memory | We avoid sets and profile management; recovery is deliberately narrow and reversible |
| BetterAddonList | Search, sets, dependency colour, memory, load-on-demand controls | We focus on diagnosis narrative, evidence provenance, recent local changes, and privacy-clean reports |
| BugGrabber + BugSack | Mature runtime error capture and inspection | We do not compete as an error collector; we consume Blizzard’s available current-session store conservatively and recommend specialist tools when deeper logs are needed |
| Addon Usage / AddOns CPU Usage | Performance-focused rankings and profiling workflows | We surface Blizzard’s profiler as one part of health and avoid claiming that memory use equals poor performance |
| Bisector | Controlled add-on bisection and detailed environment report | A future guided isolation workflow may complement it; the MVP provides an accessible first triage and narrower report |

## Primary evidence

- Build-matched UI source mirror: <https://github.com/Gethe/wow-ui-source/tree/forever>
- Generated `C_AddOns` documentation in the build-matched source: `Interface/AddOns/Blizzard_APIDocumentationGenerated/AddOnsDocumentation.lua`
- Generated `C_AddOnProfiler` documentation and metrics: `AddOnProfilerDocumentation.lua` and `AddOnProfilerConstantsDocumentation.lua`
- Blizzard AddOn List implementation showing profiler and memory usage: `Interface/AddOns/Blizzard_AddOnList/AddonList.lua`
- Blizzard Script Errors Frame error-store implementation: `Interface/AddOns/Blizzard_ScriptErrorsFrame/Blizzard_ScriptErrorsFrame.lua`
- Warcraft Wiki Forever API change notes: <https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes>

## Competitor references

- Addon Control Panel: <https://www.curseforge.com/wow/addons/acp>
- BetterAddonList: <https://www.curseforge.com/wow/addons/betteraddonlist>
- BugSack: <https://www.curseforge.com/wow/addons/bugsack>
- BugGrabber: <https://www.curseforge.com/wow/addons/bug-grabber>
- Addon Usage: <https://www.curseforge.com/wow/addons/addon-usage>
- Bisector: <https://www.curseforge.com/wow/addons/bisector>

## Honest limitations

Metadata can be absent or inaccurate. A folder named in an error stack is not necessarily the original cause. Performance values change with scene, activity, hardware, and session length. Two add-ons mentioning the same UI area may coexist perfectly. Disabled and load-on-demand add-ons are often healthy. The add-on therefore separates definite client/dependency failures from warnings and informational clues.
