# Changelog

All notable changes to Thanks for Buffing: Forever are recorded here.

## 1.0.16 — 2026-11-06

- Detects readable, exactly attributed buffs received during combat.
- Queues the thank-you safely while combat or addon chat lockdown is active, then sends it when messaging becomes available.
- Runs a post-combat aura comparison to recover lasting buffs whose incremental details were protected during combat.
- Keeps the existing full-name validation, group-member suppression, ten-minute cooldown, and conservative no-guess attribution rules.

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
