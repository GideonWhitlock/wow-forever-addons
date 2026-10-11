# Feasibility and compatibility assessment

Research date: 11 October 2026. Installed target: WoW: Forever `1.60.1.70338`, Interface `16001`.

## Decision

The add-on is feasible as a small, independent compatibility utility. Forever exposes the modern `ObjectiveTrackerFrame`; Questie's installed Forever compatibility layer independently confirms that direct hide/show plus an `OnShow` re-hide hook works on build 1.60.1 when protected work is deferred. RestedXP 4.11.23 explicitly supports Interface 16001 and creates the stable named root `RXPFrame` for its guide window.

The important limit is that neither Blizzard nor RestedXP promises these frame internals as a permanent public contract. The build therefore fails closed: if `ObjectiveTrackerFrame` is absent, it reports degraded compatibility and touches nothing else. RestedXP visibility mode uses `RXPFrame:IsShown()` and its public frame-level `IsFeatureEnabled()` helper; always-hide mode has no RestedXP dependency.

## Product boundary

- In scope: visibility of Blizzard's whole objective tracker, combat deferral, tracker re-hide, previous-state restoration, settings, minimap toggle, diagnostics and reset/recovery. Keybinding support is deferred until Forever exposes a verified safe interface.
- Out of scope: changing tracked quests, collapsing individual modules, moving/scaling Blizzard frames, replacing environmental quest popups, altering Questie's tracker, reading RestedXP steps, or modifying RestedXP settings.
- Removal behavior: no Blizzard CVar or persistent layout is changed. Disabling restores the captured pre-hide visibility state. If the folder is removed, Blizzard regains control on the next UI load; an add-on cannot execute cleanup after removal.

## RestedXP and Questie

- Installed RestedXP `v4.11.23` declares Interface 16001 and detects Forever as its own game family. Its guide root is `RXPFrame`; its arrow, targeting controls and active-item windows are separate, so hiding `ObjectiveTrackerFrame` does not target them.
- RestedXP's V2 window can replace the visible legacy root. `RXPFrame:IsFeatureEnabled()` is used as a compatibility hint when the legacy root itself is hidden. This requires live acceptance because it is not a formal cross-add-on API.
- Installed Questie already hides the same Blizzard frame when its own tracker is enabled. This utility does not call Questie modules or SavedVariables. Concurrent hiding is redundant but non-destructive; each add-on releases only its own suppression intent.

## Blizzard tracker and combat

Blizzard may call `Show()` during quest acceptance, watch-list changes, world entry and zone changes. A post-hook on `OnShow` re-evaluates the desired state. All actual `Hide()` and `Show()` calls are deferred during `InCombatLockdown()`, and only the latest setting is applied on `PLAYER_REGEN_ENABLED`. No parent, anchor, attributes or secure scripts on Blizzard's frame are replaced.

## Competitors

- **FrameTweak** supports Forever and can hide/move/scale arbitrary frames; this project is narrower, RestedXP-aware and state-restoring.
- **Hide Objectives**, **Hide Objective Tracker**, **Objective Tracker Begone**, **Objectiveless**, and **ObjectiveBarManager** cover similar Retail use cases but do not currently present a Forever-specific RestedXP compatibility boundary.
- The distinguishing value is not “hide a frame” alone; it is the two explicit modes, conservative RestedXP detection, combat-safe release, diagnostics and Forever-focused acceptance matrix.

## Name assessment

The working title **RestedXP Objective Hider: Forever** leads with a third-party mark and can read like an official RestedXP product. The closest clearer alternative containing both required terms is **Objective Hider for RestedXP: Forever**. “For RestedXP” is descriptive compatibility wording, the original emblem contains no RestedXP artwork, and every public description carries an independence disclaimer. CurseForge moderation still has final say, and this assessment is not legal advice.

## Sources checked

- Installed WoW: Forever client executable and add-ons: build 1.60.1.70338, RestedXP 4.11.23, Questie Forever compatibility code.
- [Warcraft Wiki: Patch 1.60.1 API changes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)
- [RestedXP public source](https://github.com/RestedXP/RXPGuides)
- [CurseForge moderation policies](https://support.curseforge.com/support/solutions/articles/9000197279-moderation-policies)
- [CurseForge project submission guidance](https://support.curseforge.com/support/solutions/articles/9000199552-project-submission-guide-and-tips)
- [FrameTweak on CurseForge](https://www.curseforge.com/wow/addons/frametweak)
- [Objective Tracker Begone on CurseForge](https://www.curseforge.com/wow/addons/objective-tracker-begone)

Web pages and installed source were used to establish behavior and boundaries, not copied into this add-on.
