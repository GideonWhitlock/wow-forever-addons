# Changelog

All notable changes to Thanks for Buffing: Forever are recorded here.

## 1.0.1 — 2026-10-03

- Improved WoW Forever caster detection when a newly added aura omits `sourceUnit`.
- Added a conservative 2.5-second correlation fallback for an otherwise anonymous aura and one visible nearby player casting the same spell.
- Replaced longer replies with 15 shorter, more natural in-game responses.
- Added `/tftbf debug` to show local detection information.
- Preserved protected-action safeguards for combat, secret values, and chat lockdown.

## 1.0.0 — 2026-10-03

- Initial release.
- Added random 3–10 second thank-you whispers for helpful player buffs.
- Added one response per caster every 10 minutes and duplicate pending-message suppression.
- Suppressed all replies in parties, dungeon groups, and raids.
- Added WoW Forever, Retail, Mists Classic, Burning Crusade Classic, and Classic Era packaging.
