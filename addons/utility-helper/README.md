# Utility Helper: Forever

Utility Helper presents fixed, configurable buttons for learned class utility, emergency recovery, dispels, interrupts, pet care and selected shared utilities in WoW: Forever.

The current release is version **0.1.30** for WoW: Forever **1.60.1** (interface **16001**). Install the `UtilityHelper` folder in `_forever_/Interface/AddOns/`, enable the add-on, and use `/uh` to open settings.

Version 0.1.30 uses Forever's direct NeverSecret player-aura lookup for Battle Shout and Commanding Shout during restricted combat. An active shout now clears its icon, border and tooltip even when broad aura enumeration is blocked; a genuinely missing shout remains prompted. Recent releases also improve Call Pet and Revive Pet routing for dead, distant and despawned pets.

The add-on preserves fixed secure actions during combat. Private combat values and protected-action rules limit what it can prove or change dynamically. A `?` indicator means the client withheld enough information to prevent a confirmed-ready result. Use `/uh why` for the most recent decision details.

See the source in [addon](addon/) and released changes in [CHANGELOG.md](CHANGELOG.md).
