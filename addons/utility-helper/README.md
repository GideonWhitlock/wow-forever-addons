# Utility Helper: Forever

Utility Helper presents fixed, configurable buttons for learned class utility, emergency recovery, dispels, interrupts, pet care and selected shared utilities in WoW: Forever.

The prepared public release is version **0.1.17** for WoW: Forever **1.60.1** (interface **16001**). Install the `UtilityHelper` folder in `_classic_beta_/Interface/AddOns/`, enable the add-on, and use `/uh` to open settings.

Version 0.1.17 adds inventory-aware Warlock reminders for creating missing Healthstones and Soulstones, plus a separate outside-combat Soulstone self-protection action. Healthstone recovery remains available to every class that carries a supported Healthstone and activates at the configured health threshold. Paladin blessing reminders distinguish blessings supplied by another Paladin from blessings the character applied themselves.

The add-on preserves fixed secure actions during combat. Private combat values and protected-action rules limit what it can prove or change dynamically. A `?` indicator means the client withheld enough information to prevent a confirmed-ready result. Use `/uh why` for the most recent decision details.

See the source in [addon](addon/) and released changes in [CHANGELOG.md](CHANGELOG.md).
