# Utility Helper: Forever

Utility Helper presents fixed, configurable buttons for learned class utility, emergency recovery, dispels, interrupts, pet care and selected shared utilities in WoW: Forever.

The prepared public release is version **0.1.22** for WoW: Forever **1.60.1** (interface **16001**). Install the `UtilityHelper` folder in `_classic_beta_/Interface/AddOns/`, enable the add-on, and use `/uh` to open settings.

Version 0.1.22 fixes a living hunter pet that despawns after being left on Stay incorrectly showing Revive Pet. Call Pet now takes priority when both pet spells look usable and appears as a clickable out-of-combat utility. Tokenless and distant dead pets continue to offer Revive Pet.

The add-on preserves fixed secure actions during combat. Private combat values and protected-action rules limit what it can prove or change dynamically. A `?` indicator means the client withheld enough information to prevent a confirmed-ready result. Use `/uh why` for the most recent decision details.

See the source in [addon](addon/) and released changes in [CHANGELOG.md](CHANGELOG.md).
