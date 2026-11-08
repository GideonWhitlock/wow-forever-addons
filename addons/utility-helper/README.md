# Utility Helper: Forever

Utility Helper presents fixed, configurable buttons for learned class utility, emergency recovery, dispels, interrupts, pet care and selected shared utilities in WoW: Forever.

The current release is version **0.1.33** for WoW: Forever **1.60.1** (interface **16001**). Install the `UtilityHelper` folder in `_forever_/Interface/AddOns/`, enable the add-on, and use `/uh` to open settings.

Version 0.1.33 adds a separate low-health Recovery item button for WoW: Forever's Student Fodder and known direct health-restoring quest/world consumables. Rejuvenation and Wildvine Potions are also recognised by the Healing potion slot. Potions, recovery items and Healthstones stay independent, while long-duration regeneration elixirs are deliberately excluded.

The add-on preserves fixed secure actions during combat. Private combat values and protected-action rules limit what it can prove or change dynamically. A `?` indicator means the client withheld enough information to prevent a confirmed-ready result. Use `/uh why` for the most recent decision details.

See the source in [addon](addon/) and released changes in [CHANGELOG.md](CHANGELOG.md).
