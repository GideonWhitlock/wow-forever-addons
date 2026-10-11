# CurseForge release copy

## Metadata

- **Title:** Addon Health Manager: Forever
- **Slug:** `addon-health-manager-forever`
- **Release version:** `1.0.0`
- **Release type:** Release
- **Game:** World of Warcraft
- **Flavour:** Forever
- **Game version:** `1.60.1`
- **Interface:** `16001`
- **Primary category:** Development Tools
- **Secondary category:** Miscellaneous
- **Licence:** MIT
- **Source:** <https://github.com/GideonWhitlock/wow-forever-addons/tree/main/addons/addon-health-manager-forever>
- **Changelog:** <https://github.com/GideonWhitlock/wow-forever-addons/blob/main/addons/addon-health-manager-forever/CHANGELOG.md>
- **Report an issue:** <https://github.com/GideonWhitlock/wow-forever-addons/issues/new?template=addon-health-manager-forever.yml>

## Short description

Friendly Forever add-on diagnostics, recovery guidance and privacy-clean support reports.

## Description

**Addon Health Manager: Forever** turns the evidence WoW exposes into a calm, readable health check for ordinary players.

When your UI starts behaving strangely, it helps you find definite load and dependency problems first, explains version and status warnings in plain language, gives careful performance context, and creates a clean report you can paste into CurseForge, GitHub or Discord.

### What it checks

- Installed, enabled, disabled, loaded, unavailable and load-on-demand status.
- Missing or disabled required dependencies.
- Forever interface-version differences and client-reported load errors.
- Blizzard's recent, session-average and peak add-on execution-time measurements.
- Memory as context—not as a false claim that memory use equals lag.
- Changes since Addon Health Manager's own previous scan.
- Repeated current-session errors when Blizzard's error store safely exposes a matching add-on path.
- Possible shared UI ownership, clearly labelled as a troubleshooting lead rather than a proven conflict.

### Safe recovery

Enable or disable one add-on for the next reload, undo staged changes before reload, and retest the same symptom. Addon Health Manager never edits another add-on's settings, never reloads automatically and never claims that an unverified change repaired the problem.

### Privacy-clean reports

The copyable report intentionally omits character, realm, account, guild, chat, coordinates, local variables, stack contents and SavedVariables. There is no telemetry, advertising, network service or paid feature.

### Honest limits

WoW cannot reliably prove that two add-ons conflict or which add-on is the original root cause of a propagated Lua error. Installation times before the first local scan are not exposed. Addon Health Manager says when evidence is incomplete instead of inventing a diagnosis.

### Commands

- `/ahm` — open or close
- `/ahm scan` — rescan
- `/ahm report` — open the support report
- `/ahm show` / `/ahm hide` — show or hide the minimap icon
- `/ahm undo` — reverse staged state changes
- `/ahm reset` — reset Addon Health Manager settings and scan history

Free, readable and MIT licensed. Every user receives the same features and support.

## Required presentation assets

- Project logo: circular gold-and-green shield/pulse/lens artwork derived from the shipped icon.
- Screenshot 1: summary with at least one definite dependency problem.
- Screenshot 2: add-on detail with evidence and controlled-retest guidance.
- Screenshot 3: privacy-clean report selection.

Screenshots must come from the genuine accepted Forever build; do not substitute mock gameplay.
