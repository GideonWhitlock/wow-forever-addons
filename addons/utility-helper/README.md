# Utility Helper: Forever

Utility Helper presents fixed, configurable buttons for learned class utility, emergency recovery, dispels, interrupts, pet care and selected shared utilities in WoW: Forever.

The current release is version **0.1.29** for WoW: Forever **1.60.1** (interface **16001**). Install the `UtilityHelper` folder in `_forever_/Interface/AddOns/`, enable the add-on, and use `/uh` to open settings.

Version 0.1.29 keeps Battle Shout and Commanding Shout visible in combat while their shared buff is missing, then clears the visible prompt immediately once either shout is active. Restricted aura information still fails visible. Recent releases also improve Call Pet and Revive Pet routing for dead, distant and despawned pets.

The add-on preserves fixed secure actions during combat. Private combat values and protected-action rules limit what it can prove or change dynamically. A `?` indicator means the client withheld enough information to prevent a confirmed-ready result. Use `/uh why` for the most recent decision details.

See the source in [addon](addon/) and released changes in [CHANGELOG.md](CHANGELOG.md).
