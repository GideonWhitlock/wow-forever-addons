# Checks and remaining gaps

Live baseline: 27 September 2026, addon 1.0.0; WoW: Forever 1.60.1.70009, Interface 16001, enUS; level 15. Installed in the verified running `_classic_beta_` client. These results distinguish actual game observations from simulations.

## 1.0.1 local maintenance check — 28 September 2026

The installed client metadata still identifies build 70009. Before editing, all 11 installed addon files and workspace source files matched the archived submitted 1.0.0 ZIP. Version 1.0.1 changes only campfire acquisition wording and version/documentation metadata. The nine stat-benefit groups and three campfire tiers now describe sitting, chair use, sleep, lying down and kneeling, with casting/crafting allowed during the wait, following the change summary supplied by the central maintenance audit. See SOURCES.md for provenance and its limits.

The existing Lua 5.1 syntax and 234 simulated behavior checks passed again. A focused comparison verified that only the intended acquisition strings changed in benefit data: all 39 mappings, name fallbacks, amounts, aura IDs, durations, exclusions and extra utilities remain identical to 1.0.0. All 31 affected placement paths rendered the updated wording in simulation. Tent acquisition and other service instructions stayed unchanged.

No desktop/browser control or live game input was used for this check. Version 1.0.1 and the additional resting poses have not been live-tested. The previous live checks below remain evidence for 1.0.0, not a new live compatibility claim. Installation and publication of 1.0.1 require the coordinated handoff.

## Observed in the game

- **Camp Tent:** real world hover appended its rested-experience benefit, 5% threshold, 30-second sit requirement and one-hour repeat cooldown. The exact current lockout displayed 34 and then 33 minutes on later hovers. This test preceded the wording simplification; the final shared layout was checked with Fish Bowl.
- **Fish Bowl:** real world hover displayed +8% all attributes, one-minute sit/craft requirement, one-hour persistence after leaving, and exclusion with Blessing of Kings. The final compact layout was inspected after reloading: each detail fitted on a short line with a gap before acquisition details. Its active-buff status was unavailable/absent and was omitted rather than called inactive.
- Repeated tent/Fish Bowl hovers and switching to the pet preserved the object name and normal bottom-right placement. There was one added section per tooltip; no camp text lingered on the pet or the Dismiss Pet action tooltip. The final Fish Bowl → pet → action → Fish Bowl sequence passed after reload.
- **Mana Well:** a real hover was observed with descriptions disabled. It disappeared before the enabled test could be completed. Its current client description confirmed 10 mana per five seconds at level 15, but this is **not** an enabled Mana Well hover pass.
- **Lodestone — accepted pass:** after adding its confirmed exact English world name to the Object-only allowlist and reloading, the real hover displayed **+20 melee attack power**, one-minute sit/craft acquisition, one-hour persistence after leaving, and exclusion with Blessing of Might. The user accepted this as a pass. They reported that this Lodestone had no associated campfire, so gaining its buff could not be tested; no current-buff timer was shown. Buff acquisition remains unobserved and is not blocking acceptance. Items, units, similar names and a readable unrelated GUID still cannot match through this fallback.
- **Chair and Basic Campfire:** diagnostics received the real Object callbacks, but neither tooltip exposed a GUID or entry ID. “Chair” is ambiguous and remained unchanged. Basic Campfire remained unchanged because an older cooking fire shares that name. No camp buff/capacity was guessed from either name.
- Native Options → AddOns → Campfire Tooltips page, both checkboxes, local hover recording, report refresh, reload button and slash shortcut worked. Both preferences were set false and remained false after a real reload; saved preferences and previous session were reported as loaded. Both options were restored to true and saved. Hover recording was stopped.
- Feed Pet Forever and Campfire Stories were loaded throughout. Their 22 addon files matched their original SHA-256 hashes after testing. Their settings were not edited.
- A saved live report before the final wording reload recorded 34 object callbacks, 16 added sections and **0 callback errors**. No addon error dialog or chat spam was observed. This is not a guarantee covering untested situations.

## Verified data and simulated tests

The mapping covers 36 world-object placements and three service creatures, grouped into 16 benefits/functions. Every mapped entry ID independently matched the checked placement spell's summon effect. Literal level brackets, durations and inherited upgrade benefits were reviewed against the exact-build records and cached in-game descriptions. Mapping coverage does not establish hover recognition for every placement.

The final description audit covered all 39 entries against the checked placement descriptions. Each entry has a benefit or function description. Profession upgrades include their inherited camp benefit and additional utility; campfires include capacity, and service creatures describe their services. Descriptions stay short and separated. The audit found no missing effect descriptions or upgrade utilities.

Lua 5.1 syntax checks passed for all four Lua files. **234 simulated assertions** passed for recognised IDs and 27 exact-name fallbacks; ambiguous/unrelated objects; locales; repeated callbacks and rebuilding; preservation of original text/anchor; disabling/re-enabling; all 39 mappings; level boundaries; build mismatch; current aura identity and timers; omitted inaccessible/restricted values; combat suppression; absent APIs; and bounded diagnostics. Nondefault SavedVariables reload also passed in simulation.

Restricted-value tests use throwing sentinel values. They are not native secret-value or combat tests. Settings controls and actual rendering were verified in-game, not by those mocks.

## Known coverage limits

The tested Object tooltips supplied names but no GUID/entry ID. Exact English names provide the working fallback. ID-only entries cannot work when the client omits that ID. Camp Chair's observed name was “Chair”, so even its allowed “Camp Chair” spelling did not match. SUPPORTED.md explicitly marks recognition requirements for every entry. Most upgrade fallback spellings come from checked placement names and have not yet been confirmed as actual world tooltip names.

No broad match, nearby-object inference, campsite scan, memory access or gameplay automation is used to fill that gap. An unrecognisable object stays unchanged. If the client later supplies a readable supported GUID, ID matching is already implemented.

## Optional future field checks

The user accepted the Lodestone result and will report differences during normal play. The checks below record unobserved cases for future maintenance; no further test session is requested for this handoff.

1. At a Mana Well, hover while enabled, then manually rest to gain its buff and hover again. Check the amount against the client description and the exact aura timer. Do not treat an existing class buff as the camp aura.
2. Hover available profession upgrades and camp service creatures. Confirm each exact displayed name/ID and inherited benefit plus extra utility. Confirm unrelated objects with the same generic names remain unchanged.
3. Check a normal inventory item and player tooltip directly after a camp tooltip; these cases currently have simulated coverage. Check native restricted/combat conditions and a separately installed tooltip styling/positioning addon if one is used.
4. Confirm both preferences after a full logout/login. Actual interface-reload persistence passed; a full login cycle was not performed.

## Reproduce the developer checks

The source bundle needs Python 3 and the developer-only `lupa` package (`python -m pip install lupa`). From the bundle root:

```text
python tools/document_data.py
python verification/syntax.py
python verification/test_addon.py
python tools/package.py
```

The generator regenerates Data.lua, Names.lua and the coverage table. Lua, Python packages, test fixtures and research files are not needed in the installed addon. `tools/package.py` builds and checks both ZIPs without publishing anything.
