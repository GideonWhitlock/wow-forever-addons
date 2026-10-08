# Changelog

All notable changes to Thanks for Buffing: Forever are recorded here.

## 1.0.13 — 2026-10-08

- Fixes Forever rejecting a multi-word recipient after a successful grouped external-player detection.
- Prefers the complete visible unit name matched by caster GUID before falling back to `GetPlayerInfoByGUID`, which returned `Brother` for the visible player `Brother Marlin`.
- Scans target, focus, mouseover, soft-interaction, party, raid and nameplate units for the matching non-secret caster GUID.
- Adds an exact regression proving a grouped external caster named `Brother Marlin` receives the full whisper target even when the GUID-only lookup returns `Brother`.

Focused live testing on WoW Forever 1.60.1.70245 confirmed the corrected external-player whisper path after the earlier truncated-recipient failure. Published on CurseForge project 1725022 as Release file 9092290 for WoW Forever 1.60.1; CurseForge now lists the file as approved and public.

A separate clean in-game confirmation of the default diagnostic-silence change introduced in 1.0.11 remains pending. That limited verification gap is tracked independently and does not change the 1.0.13 publication record.

## 1.0.12 — Failed live verification

- Keeps party and raid members excluded from automatic thank-you whispers.
- Allows a nearby external player to receive a thank-you even while the recipient is in a party, dungeon group or raid.
- Applies the same membership-aware rule before scheduling, during cast-correlation fallback and immediately before delivery.
- Adds Forever and Classic regression coverage for grouped external casters while retaining grouped-member suppression.

Live testing on WoW Forever 1.60.1.70245 confirmed that the external grouped caster was detected and the whisper was submitted, but the server rejected recipient `Brother`; the visible character was `Brother Marlin`. Superseded by 1.0.13.

## 1.0.11 — 2026-10-04

- Turns all diagnostic chat output off by default, including upgrades from builds that saved `debug = true`.
- Makes `/tftbf debug` session-only; diagnostics automatically turn off again after login or `/reload`.
- Keeps deliberate troubleshooting available without allowing test settings to spam ordinary gameplay.
- Adds coverage proving Mage, Paladin, Priest, Druid, Shaman and Warlock external buff paths still send one correct whisper while producing zero debug lines under default settings.
- Retains the 1.0.10 clean-login baseline, bare-name recipient handling, same-caster coalescing and ten-minute cooldown.

Published on CurseForge project 1725022 as Release file 9059908 for WoW Forever 1.60.1. The published ZIP is byte-for-byte aligned with the repository's `addon/ThanksForTheBuffForever/` source. A clean in-game confirmation of the default diagnostic-silence change remains pending; this does not change the publication record.

## 1.0.10 — 2026-10-04

- Forces bare display-name whisper targets on WoW Forever instead of trusting inconsistent realm labels.
- Prevents rejected recipients such as `Adorianna Temple-ClassicBetaPvE2`; the target is now `Adorianna Temple`.
- Uses the normalized recipient name as the stable coalescing and cooldown identity, covering alternate transient GUID routes for multiple buffs from one caster.
- Emits the direct detection/match line only when a new response was actually scheduled.
- Adds exact realm-label-mismatch, alternate-GUID coalescing and single-detection-line regressions.
- Retains the successful 1.0.9 clean-login settling baseline.

Live verified on WoW Forever 1.60.1.70205: a clean login produced no stale response, then a fresh external buff from Srel Seif produced exactly one detection, one submission and one accepted bare-name whisper. No duplicate appeared during the follow-up window and no recipient error occurred.

Published on CurseForge project 1725022 as Release file 9058712 for WoW Forever 1.60.1. Public signed-out verification shows the file listed as the current WoW Forever release with Download and Install actions. The legacy author dashboard still displayed `Processing` during the same check, so that moderation label is recorded as lagging behind the public listing.

Known release defect: a previously enabled diagnostic flag can persist and spam ordinary gameplay with detection and submission lines. Superseded by the prepared 1.0.11 fix.

## 1.0.9 — Failed live verification

- Adds a two-second settling baseline after world entry so long-lived auras restored after login or `/reload` are never treated as fresh buffs.
- Invalidates superseded baseline callbacks across repeated world transitions.
- Uses bare same-realm player names for Forever whispers, avoiding rejected recipients such as `Name-ClassicBetaPvE2`.
- Retains realm suffixes for genuinely cross-realm targets.
- Adds exact late-restored-aura, superseded-baseline, same-realm and cross-realm regressions.
- Includes the corrected external player-origin classification from 1.0.8.

Version 1.0.9 must pass a clean login/reload test and a fresh external buff-to-accepted-whisper test before upload.

Version 1.0.9 passed its clean-login baseline but still produced a realm-qualified Forever recipient that chat rejected. Multiple aura records also produced repeated detection output.

## 1.0.8 — Failed live verification

- Corrected the meaning of Blizzard's `isFromPlayerOrPlayerPet` aura field: it identifies a buff from any player or player pet, not only the local character.
- External player buffs carrying that flag now continue through exact caster resolution and can produce the intended whisper.
- Self-cast and non-player effects remain excluded using their actual source unit or caster GUID, plus the verified internal-aura exclusion set.
- Added general Mage, Paladin, Priest, Druid, Shaman and Warlock regressions with the player-origin flag set, plus explicit self-cast identity regressions.
- Includes every login/reload, stale attribution, travel aura and quiet-scan safeguard from 1.0.7.

Version 1.0.8 must pass a real external buff-to-whisper test before upload.

Version 1.0.8 sent a stale thank-you for a long-lived aura restored during login and supplied a redundant same-realm suffix that the Forever whisper service rejected.

## 1.0.7 — Failed live verification

- Silently excludes the Honorless Target system/zone aura 2479 before caster resolution.
- Includes the Stealth, login/reload replay, stale attribution, tracking aura and totem repairs.
- Added an exact regression ensuring 2479 produces no caster-resolution debug or whisper.
- Retains 2183391 as a passing ignored-owner regression and quiets unchanged full-scan login diagnostics.

Version 1.0.7 rejected a genuine external player buff because it incorrectly treated the general player/player-pet origin flag as meaning self-cast.

Version 1.0.6 was superseded before live verification by the system-aura exclusion.

## 1.0.6 — Superseded before live verification

- Ignores auras marked as originating from the player or player pet before caster resolution.
- Added an exact Stealth 1784 regression ensuring no anonymous-caster wait or failure output.
- Includes the 1.0.5 login/reload replay, stale attribution, tracking aura and totem fixes.

Version 1.0.5 was superseded before live verification by the Stealth regression fix.

## 1.0.5 — Superseded before live verification

- Prevented pre-existing buffs from being replayed as new applications during login, reload or world entry.
- Clears transient caster attribution and pending-send state before establishing each new world baseline.
- Ignores known self-cast and non-player-owned auras before anonymous caster correlation.
- Added repeated relog coverage and exact regression cases for IDs 2383, 1229741 and 8072.
- Retains the live-confirmed external Mark of the Wild whisper path.

Version 1.0.4 was only partially successful in live testing and had a stale-caster/login-replay blocker.

## 1.0.4 — Failed live verification

- Fixed the remaining Forever caster-attribution gap by querying the caster GUID of the exact new aura instance.
- Resolves the whisper recipient from the caster's player GUID even when `sourceUnit` and nearby spell-cast events are unavailable.
- Retains all conservative fallback paths and ambiguity safeguards.
- Added no-spellcast-event regression coverage for Mage, Paladin, Priest, Druid, Shaman and Warlock buffs.

Version 1.0.3 failed a live multi-buff test in Stormwind and must not be promoted as working.

## 1.0.3 — Failed live verification

- Fixed the generic Forever path when `UNIT_AURA` supplies no incremental update payload.
- Registered global `UNIT_AURA` and explicitly filtered for player changes.
- Added complete helpful-aura snapshot baselining and diff detection.
- Retained direct aura refresh and unambiguous visible-cast attribution fallbacks.
- Added a spell-agnostic targeted-cast fallback for cast/aura ID mismatches, including the observed Blessing aura ID 1283391.
- Added representative Mage, Paladin, Priest, Druid, Shaman and Warlock regression coverage.

Version 1.0.2 failed a live Blessing of Might retest and was not published.

## 1.0.2 — Pending live verification

- Fixed a WoW Forever event-order gap where an anonymous `UNIT_AURA` could arrive before the nearby caster's `UNIT_SPELLCAST_SUCCEEDED` event.
- Added a brief re-query of the exact aura instance before cast correlation.
- Kept the full response inside the original randomized 3–10 second window.
- Continued to reject ambiguous or protected caster data instead of guessing.
- Added Arcane Intellect and refreshed-aura regression tests for build 1.60.1.70205.

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
