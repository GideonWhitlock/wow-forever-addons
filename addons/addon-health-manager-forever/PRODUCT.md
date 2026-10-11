# Product definition

**Addon Health Manager: Forever** is a diagnosis and support-reporting tool for ordinary World of Warcraft: Forever players. It explains what the client can observe, offers a conservative recovery path, and produces a privacy-clean report suitable for CurseForge, GitHub, or Discord.

It is deliberately **not** a loadout/profile manager. It does not sell one-click “optimisation,” claim to auto-repair other add-ons, or label coexisting add-ons as conflicting without a controlled test.

## MVP promise

1. Inventory every installed add-on and show enabled, loaded, loadable, load-on-demand, module, security, version, and interface status.
2. Explain missing or disabled required dependencies and client-reported load failures in plain language.
3. Display the modern Blizzard profiler’s recent, session-average, and peak execution time plus a memory snapshot, without equating memory with frame-rate cost.
4. Read repeated errors from Blizzard’s current-session error store when it is present and attribute only when an add-on directory is named in the error path. Label that attribution as a clue, not root-cause proof.
5. Compare later scans with the manager’s own earlier snapshot to give limited recent-change context.
6. Flag possible shared UI ownership only from title, notes, or category keywords, always as an unverified troubleshooting lead.
7. Stage one enable/disable change at a time, persist it through Blizzard’s API, and offer an undo path before reload.
8. Generate a selectable plain-text report that omits character, realm, account, guild, chat, coordinates, and SavedVariables.

## Success criteria

- A non-technical player can identify the first red item to investigate and understand why it is red.
- Every statement in the UI is traceable to client metadata, a Blizzard profiler value, an error path, or an explicitly identified heuristic.
- No action silently reloads the UI or edits another add-on’s settings.
- The report remains useful to an add-on author while excluding personally identifying game data.

## Deferred until after live acceptance

- Publication, compatibility claims, and maintenance registration.
- Screenshots captured from genuine Forever gameplay.
- CurseForge artwork and final description derived from accepted live UI.
- YouTube main demonstration and Short. These require a publicly downloadable build and genuine footage.
- Rich BugGrabber/BugSack integration. The MVP can use Blizzard’s error store without replacing the error handler.
