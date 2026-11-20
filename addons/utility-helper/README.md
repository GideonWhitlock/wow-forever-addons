# Utility Helper: Forever

Utility Helper presents fixed, configurable buttons for learned class utility, emergency recovery, dispels, interrupts, pet care and selected shared utilities in WoW: Forever.

The current release is version **0.1.36** for WoW: Forever **1.60.1** (interface **16001**). Install the `UtilityHelper` folder in `_forever_/Interface/AddOns/`, enable the add-on, and use `/uh` to open settings.

Version 0.1.36 fixes Druid control-break reminders when the client reports an active loss-of-control effect but hides its detailed category during combat. Learned Cat, Bear/Dire Bear and Travel forms are offered when the form is actually usable, excluding the form already active.

The add-on preserves fixed secure actions during combat. Private combat values and protected-action rules limit what it can prove or change dynamically. A `?` indicator means the client withheld enough information to prevent a confirmed-ready result. Use `/uh why` for the most recent decision details.

See the source in [addon](addon/) and released changes in [CHANGELOG.md](CHANGELOG.md).
