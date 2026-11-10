# Changelog

## 1.0.6 — 2026-11-10

- Added an automatic whisper after a direct invite that identifies the activity
  and, when selected, the role being recruited.
- Added a distinct automatic whisper after a party-member invite suggestion,
  asking the player to wait for the party leader's invite.
- Activity and role wording follows the inviter's active Group Finder filters,
  so players queued for several dungeons or roles know which specific place is
  being offered.
- Added duplicate protection so a single invite cannot produce repeated
  activity whispers.

## 1.0.5 — 2026-11-09

- Changed **Suggest invite to party leader** to use WoW's native invite action.
  Party members now trigger the leader's built-in approval prompt instead of
  posting an instruction in party chat; leaders invite directly.
- Added an All/Tank/Healer/DPS filter above the search results. Multi-role
  players and groups match every role they advertise.
- Preserved complete Forever player names when submitting invite requests.
- Removed the obsolete editable party-chat suggestion template.

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
