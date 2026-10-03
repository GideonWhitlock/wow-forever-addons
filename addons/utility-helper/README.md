# Utility Helper: Forever

Utility Helper presents fixed, configurable buttons for learned class utility, emergency recovery, dispels, interrupts, pet care and selected shared utilities in WoW: Forever.

The prepared public release is version **0.1.18** for WoW: Forever **1.60.1** (interface **16001**). Install the `UtilityHelper` folder in `_classic_beta_/Interface/AddOns/`, enable the add-on, and use `/uh` to open settings.

Version 0.1.18 adds Life Tap for Warlocks when mana is at or below the configured mana threshold and health remains above the configured health threshold. The custom utility editor now includes the same **Low mana + safe health** rule and a **Find Spell ID** picker: arm it, then click a recognized spellbook icon to fill the spell ID automatically.

The add-on preserves fixed secure actions during combat. Private combat values and protected-action rules limit what it can prove or change dynamically. A `?` indicator means the client withheld enough information to prevent a confirmed-ready result. Use `/uh why` for the most recent decision details.

See the source in [addon](addon/) and released changes in [CHANGELOG.md](CHANGELOG.md).
