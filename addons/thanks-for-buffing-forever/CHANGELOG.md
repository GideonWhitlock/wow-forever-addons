# Changelog

All notable changes to Thanks for Buffing: Forever are recorded here.

## 1.0.26 — 2026-11-23

- Adds a character picker to the phrase editor for quickly loading another
  character's saved thank-you phrases.
- Keeps copying non-destructive: the current character is not changed until the
  existing **Save phrases** button is pressed.
- Adds regression coverage for copying into the editor without prematurely
  overwriting the current character's list.

## 1.0.25 — 2026-11-21

- Safely catches protected helpful-aura reads without inspecting or stringifying WoW's secret error value.
- Defers the first post-combat aura scan and retries briefly while Forever keeps aura data protected after combat formally ends.
- Stops retrying as soon as aura data becomes readable and retains the next normal aura update as a safe fallback.
- Adds regression coverage for the delayed post-combat protection window.
- Passed live testing across repeated combat entry and exit without the previous `GetAuraDataByIndex()` taint error returning.

## 1.0.24 — 2026-11-21

- Prevents full helpful-aura scans when Forever marks the player as fighting before formal combat lockdown begins.
- Avoids the `GetAuraDataByIndex()` protected-aura taint raised at the start of combat.
- Keeps safe incremental aura handling during combat and the existing post-combat rescan.
- Adds regression coverage for the early-combat window where `UnitAffectingCombat("player")` is true while `InCombatLockdown()` is still false.

## 1.0.23 — 2026-11-20

- Keeps an ordinary minimap-button left-click reserved for opening the phrase editor.
- Requires Alt-drag to move the minimap shortcut, preventing a slight pointer movement from swallowing the editor click.
- Rebuilds the phrase editor with Blizzard's multiline input template so clicks place a visible caret exactly where text will be inserted.
- Adds a bright blinking fallback caret driven by the editor's real cursor coordinates for Forever clients that fail to draw Blizzard's native insertion marker.
- Maps left-clicks to the nearest rendered character boundary, restoring click-to-place editing even when Forever's native multiline mouse positioning fails.
- Keeps the fallback caret one pixel wide and capped to a single line, and uses clock-driven blinking that cannot be reset by repeated cursor events.
- Offsets the caret from Forever's next-glyph bearing into the letter gap, shortens it to the text body and prevents repeated cursor events from overriding its hidden blink phase.
- Stops using Forever's incorrect cursor X/Y drawing coordinates; the caret position is now derived from the actual cursor byte offset, measured text width and calculated line number.
- Makes the multiline phrase box explicitly accept mouse and keyboard focus so clicking a phrase always places the editing cursor.

## 1.0.22 — 2026-11-19

- Requires exact aura-caster evidence before sending a thank-you on WoW: Forever.
- Removes recent same-spell cast correlation so an anonymous aura can never be assigned to a nearby player by inference.
- Keeps a silent rolling local audit of the last 25 approved thank-you decisions, available through `/tftbf audit`.
- Adds `/tftbf audit clear` to erase the stored diagnostic history.

## 1.0.21 — 2026-11-17

- Gives every character its own saved thank-you phrase list.
- Preserves an existing customized list for the first character loaded after updating.
- New characters begin with the 15 defaults and can edit them independently.

## 1.0.20 — 2026-11-16

- Fixes the Options phrase editor on WoW: Forever clients where EditBox does not provide `GetStringHeight`.
- Adds a safe line-count fallback so editing phrases no longer raises a Lua error.
- Adds a draggable minimap button: left-click opens phrase settings and right-click enables or disables automatic thanks.
- Adds `/tftbf minimap show`, `hide` and `reset` commands.

## 1.0.19 — 2026-11-15

- Adds an accessible phrase editor under Options → AddOns → Thanks for Buffing: Forever.
- Lets players add, edit, remove and reorder phrases as one phrase per line, without remembering slash commands.
- Adds Save phrases and Restore defaults buttons with clear validation feedback.
- Adds `/tftbf options` as a shortcut to the new settings page.

## 1.0.18 — 2026-11-12

- Adds a persistent, editable thank-you phrase list.
- Adds `/tftbf phrases` to show the complete numbered list.
- Adds `/tftbf phrases add <text>`, `/tftbf phrases remove <number>` and `/tftbf phrases reset`.
- Rejects blank, overlong and duplicate phrases and preserves at least one usable message.

## 1.0.17 — 2026-11-09

- Prevents one continuous buff from being thanked again because WoW emitted an ordinary aura update, a zone transition, or a new aura instance for the same still-active effect.
- Records party and raid member buffs before suppressing them, so leaving a dungeon cannot replay an old grouped buff as a new external application.
- Treats an updated aura as a genuine reapplication only when its readable expiration time moves forward.
- Removes the unsafe generic recent-target fallback. An unidentified aura now requires an exact matching spell cast or exact aura caster; otherwise it is ignored.
- Adds regressions reproducing the reported delayed and repeated Dax thank and the unrelated `Arwen El` recipient risk.

Automated validation passes all thirteen behavior suites against the WoW Forever 1.60.1.70862 API model.

## 1.0.16 — 2026-10-19

- Detects readable, exactly attributed buffs received during combat.
- Queues the thank-you safely while combat or addon chat lockdown is active, then sends it when messaging becomes available.
- Runs a post-combat aura comparison to recover lasting buffs whose incremental details were protected during combat.
- Keeps the existing full-name validation, group-member suppression, ten-minute cooldown and conservative no-guess attribution rules.

## 1.0.15 — 2026-10-17

- Continues using a readable exact aura source even when Forever protects the aura's ownership or spell fields.
- Keeps the protected combat-log API disabled after live testing confirmed that registering it is blocked by the Forever client.
- Adds regression coverage for the reported missed Stamina buff from `Yserael Dawnwhisper` without guessing the caster.

Automated validation passes all twelve behavior suites. The owner accepted the build for release after the blocked combat-log experiment was removed; the reported Stamina scenario still lacks a successful live confirmation.

## 1.0.14 — 2026-10-17

- Fixes rejected thank-you whispers for WoW: Forever characters whose first name and surname are returned separately by the game API.
- Combines both Forever name values for unit, aura-caster GUID, group-member and player-target comparisons instead of discarding the surname as if it were a realm.
- Uses the exact full name from a recent nearby say, yell or emote event when available, matched safely by the caster's GUID.
- Skips individual protected aura records during full scans instead of leaving detection disarmed for the rest of the session.
- Handles reapplied buffs reported through `updatedAuraInstanceIDs`, including the observed Power Word: Fortitude stamina test from `Morwenna Duskmirage`.
- Adds regressions for the observed `Nocturna Sjes` failure, Mark of the Wild after a protected aura, and all existing supported buff paths.

Automated validation passes all eleven behavior suites against the WoW Forever 1.60.1.70450 API model. Live testing on 17 October 2026 confirmed that an external buff from `Burrman Mcgeeheehee` was detected, the complete two-part recipient was retained, and the server accepted the automatic `cheers!` whisper.

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
