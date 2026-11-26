# 1.0.5 — 26 November 2026

- Restored the torch prompt while stationary on a ground mount and while
  casting or channeling, matching Blizzard's 25 November Forever hotfix.
- Flying, taxi, vehicle, movement, combat, death, cooldown and active-buff
  safeguards remain in place.

# 1.0.4 — 16 November 2026

- Added saved reminder toggles for always-dark zones, night-time and bad weather.
- Manual dim/fog remains available independently.
- Item use still requires a click or keypress; safety checks cannot be disabled.

# 1.0.3 — 10 November 2026

- Added built-in daytime torch prompting in Duskwood and Deadwind Pass, where
  the environment remains dark even when the game reports daytime.
- The button still stays hidden while either known torch buff is active and all
  existing bag, movement, combat, travel and cooldown safeguards remain intact.

# 1.0.2 — 27 September 2026

- Fixed the reminder reappearing while the Night Watchman's Torch illumination
  buff is already active. Both known torch aura IDs and active buff names are checked.
- Buff detection also recognizes localized item/spell names and light supplied
  by another player. Unavailable buff data suppresses the prompt.
- Changed the tooltip label to "Night-time" for readability.

# 1.0.1 — 27 September 2026

- Added a draggable minimap torch icon with saved positioning.
- Left-click opens settings for reminders, dim areas, button size and arrangement.
- Right-click toggles the torch button's positioning preview.
- Added `/nwt options` and `/nwt minimap show|hide`.
- Existing settings and torch eligibility rules are preserved.

# 1.0.0 — 27 September 2026

- Initial WoW Forever release package.
- One-click torch use when stationary, out of combat and missing the torch buff.
- Carried-bag-only item check, cooldown checks and click-time revalidation.
- Game-reported nighttime and bad weather detection.
- Temporary manual dim-area setting for unreported visual fog or darkness.
- Movable, resizable button and optional keybinding.
- Secure combat hiding and disarming; no automatic item use.

Automated Lua 5.1 simulation passed. Live in-game verification remains pending.
