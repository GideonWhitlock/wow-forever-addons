# Addon Health Manager: Forever

Friendly, evidence-led add-on diagnostics for **World of Warcraft: Forever**.

The public release is version **1.0.0** for WoW: Forever **1.60.1** (build **70338**, interface **16001**). It includes the session Lua/XML warning visibility correction accepted during the final live gate. Install `AddonHealthManagerForever` in `_classic_beta_/Interface/AddOns/`, enable it, and type `/ahm` or use its custom minimap button.

## What it does

- Explains installed, enabled, loaded, disabled, unavailable, load-on-demand, and module state.
- Finds missing or disabled required dependencies.
- Separates client-reported load failures from later runtime clues.
- Shows modern Blizzard profiler values and memory context without equating memory with lag.
- Uses Blizzard’s current-session error store when available, with cautious path-based attribution.
- Remembers changes from its own previous scans.
- Shows possible overlapping UI ownership as a lead—never as a proven conflict.
- Stages reversible enable/disable changes for the next reload.
- Builds a privacy-clean report for CurseForge, GitHub, or Discord.
- Uses its own gold-and-green health-diagnostics emblem in the minimap, AddOn List, and main window.

## What it cannot know

WoW does not expose a reliable “these two add-ons conflict” answer. An error path can implicate code without proving the original cause. The client does not expose historical install/update time. A disable/enable action is not a verified repair until the player repeats the symptom in a controlled test.

## Install for testing

1. Exit WoW.
2. Copy `AddonHealthManagerForever` into `_classic_beta_/Interface/AddOns/`.
3. Launch Forever and enable **Addon Health Manager: Forever**.
4. Type `/ahm` or click the minimap gear.

## Commands

- `/ahm` — open or close
- `/ahm scan` — rescan
- `/ahm report` — open the copyable report
- `/ahm show` / `/ahm hide` — show or hide the minimap icon
- `/ahm undo` — reverse every staged add-on state change before reload
- `/ahm reset` — reset this add-on’s settings, scan history, and staged recovery record
- `/ahm help` — command reminder

## Privacy and safety

There is no network access, telemetry, advertising, arbitrary console execution, chat transmission, or inspection of another add-on’s SavedVariables. Reports omit character, realm, account, guild, chat, coordinates, local variables, and stack text. The add-on never reloads the UI automatically.

## Evidence and support

See [RESEARCH.md](RESEARCH.md), [PRODUCT.md](PRODUCT.md), [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md), and [TESTING.md](TESTING.md). Report problems through the [Addon Health Manager issue form](https://github.com/GideonWhitlock/wow-forever-addons/issues/new?template=addon-health-manager-forever.yml).

## Free and source-visible

MIT licensed, readable source, no paid features, and the same support for every user.
