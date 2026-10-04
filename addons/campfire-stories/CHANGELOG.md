# Campfire Stories: Forever changelog

This changelog records the numbered releases of the current human-written story collection. Retired prerelease files containing the replaced generated collection are intentionally omitted.

## 3.0.3 — 4 October 2026

- Replaced the small, text-heavy project artwork with a clear campfire-and-book icon that remains readable in compact CurseForge views.
- Updated the addon-list and minimap textures to use the matching circular campfire-and-book icon.
- Made no changes to stories, pacing, chat routing, the personal library or SavedVariables behavior.

## 3.0.2 — 3 October 2026

- Changed the public and in-game display name to **Campfire Stories: Forever**.
- Updated the addon list, windows, settings category, minimap tooltip, diagnostics, notices, source replies, artwork title and public documentation to use the same name.
- Kept the `CampfireStory` folder, `/campfire` commands, saved-data identifiers, CurseForge slug and project ID unchanged for upgrade compatibility.
- Made no changes to stories, pacing, chat routing, the personal library or SavedVariables behavior.

## 3.0.1 — 27 September 2026

- Restored a short opening emote before each included story. **Start story** sends the action; **Next line** begins the original human-written narrative.
- Made **Reset story** and **Back one message** return correctly to the opening action.
- Preserved tellings already in progress during upgrade and retained personal stories with their chosen opening mode.
- Fixed private draft previews for stories with no spoken introduction.
- Limited optional source replies to begin only after a manual story-line attempt rather than after the opening emote alone.
- Kept all 20 sourced narratives and the human-painted artwork unchanged from 3.0.0.

Validation recorded for this release: 2,899 simulated Lua 5.1 assertions, all 20 source audits and five deliberate corruption cases passed. The restored emotes did not receive a specific live-client check. The earlier Error 109 report remains undiagnosed; this release makes no crash-fix claim.

## 3.0.0 — 27 September 2026

- Replaced the earlier included collection with 20 complete human-written public-domain ghost stories and dark folk tales.
- Preserved the original wording and endings, with source credits and documented geography substitutions.
- Removed generated spoken introductions and premises from the included narratives.
- Removed retired included tales from active and recovery snapshots while preserving personal-library entries.
- Replaced generated project and minimap artwork with crops of Winslow Homer's public-domain painting *Camp Fire* (1880).
- Added optional, rate-limited private source replies for relevant audience comments during an active included-story telling.
- Retained the simple **Start story**, **Next line**, **Reset story** and compact-window workflow.

Validation recorded for this release: 2,622 simulated Lua 5.1 assertions and the source-integrity audit passed. The new story collection and automatic source replies did not receive complete live-client coverage. The earlier Error 109 report remained undiagnosed.
