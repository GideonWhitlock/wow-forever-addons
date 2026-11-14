# Changelog

## 1.0.8 — 2026-11-14

- Added an **Invite** button directly to each eligible individual-player result,
  so the player no longer has to select the listing first.
- Changed the role control from a filter to a priority order. Tanks, healers or
  DPS can be placed first while every other result remains visible underneath.

## 1.0.7 — 2026-11-11

- The default Quick Whisper now includes the player's current level below the
  level cap, for example: `Lvl 35 Hunter DPS here`.
- Max-level players keep the shorter message, for example: `Hunter DPS here`.

## 1.0.6 — 2026-11-10

- Added activity-and-role whispers for direct invites and party-member invite
  suggestions.
- Suggested players are told to wait for the party leader's invite.
- Added duplicate protection for invite whispers.

## 1.0.4 — 2026-11-07

- Renamed the public add-on to **Looking for Group: Forever**.
- Kept the existing add-on folder, saved variables and slash commands so current installations and settings continue to work.

## 1.0.3 — 2026-11-07

- Renamed the add-on to **LFG Messenger: Forever** before public release.
- Renamed the settings commands to `/lfgmsg` and `/lfgmessenger`.
- Preserved settings created by the local pre-release build during the rename.

## 1.0.2 — 2026-11-07

- Reduced and aligned the centre Quick Whisper button so it has clear spacing from Blizzard's **Send Message** and **Group Invite** buttons.

## 1.0.1 — 2026-11-07

- Fixed the right-click **Suggest invite to party leader** option not appearing because the menu extension was attached to the Group Finder mixin rather than the live Browse frame.

## 1.0.0 — 2026-11-07

- Added a one-click class-and-role whisper for the selected Group Finder listing.
- Added an editable message template and clear preview.
- Added duplicate-click protection and safe fallback when direct chat is restricted.
- Added a right-click Suggest Invite action for individual player listings,
  sending the suggestion to party chat and the party leader.
- Added a draggable minimap button and slash commands.
