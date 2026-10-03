## Campfire Stories: Forever

Campfire Stories: Forever is a World of Warcraft: Forever roleplay addon by Gideon. It provides 20 human-written public-domain ghost stories and dark folk tales, presented one message at a time so the player controls the pace. It also includes a personal story library, a compact telling window, pacing controls, import/export and local text backups.

**Current source version:** 3.0.2  
**Game flavour:** WoW: Forever 1.60.1  
**Interface:** 16001  
**CurseForge:** [Campfire Stories: Forever](https://www.curseforge.com/wow/addons/campfire-stories)

The installed client was assessed locally against build 70205 on 3 October 2026. The files and interface metadata remain compatible by static inspection, but this is not a claim of a full in-game build-70205 test.

### Installation

The normal installation route is the CurseForge app or the project download page. For a manual installation:

1. Exit World of Warcraft.
2. Extract the release so the addon folder is `Interface/AddOns/CampfireStory` in the WoW: Forever client directory.
3. Confirm that `CampfireStory.toc` is directly inside that folder rather than inside a second nested folder.
4. Start the game and enable **Campfire Stories: Forever** on the AddOns screen.

Back up `CampfireStory` and the relevant WoW `SavedVariables` files before manually replacing an older copy. Updates preserve the account-wide personal library and per-character settings through WoW's normal SavedVariables system.

### Using the addon

Left-click the round minimap button or enter `/campfire ui`. Choose a story, press **Start story** for its opening emote, and use **Next line** for each story message. **Reset story** returns to the beginning without sending. **Small window** provides a compact, movable telling panel. Story progression is always manual.

The default audience is nearby players through `/say`, with an optional normal invited-party mode. Less common controls such as pause, back, line preview, audience selection and export are under **More options**. **Settings** contains pacing, minimap visibility, source replies and full personal-library backup/restore.

Useful commands:

| Command | Result |
|---|---|
| `/campfire` | Open the telling view, or use the current Start/Next action when its preview is already visible |
| `/campfire ui` | Open the main window |
| `/campfire reset` | Reset the selected story without sending |
| `/campfire pause` / `/campfire resume` | Pause or resume the telling |
| `/campfire channel say` | Tell nearby players |
| `/campfire channel party` | Tell the current invited party |
| `/campfire settings` | Open addon settings |
| `/campfire editor` | Open the personal-story editor |
| `/campfire backup` | Open settings for a complete text backup |
| `/campfire debug` | Show copyable client and addon diagnostics for a report |
| `/campfire help` | Show the in-game guide and command reference |

Optional **Source replies** can privately answer a member of the selected audience who mentions AI-related terms during an active included story. The reply identifies the human source and links to the addon. It is rate-limited, applies only after a manually attempted story line, stores no audience chat text, and can be disabled in Settings.

### Known limitations

- Version 3.0.2 changes branding only. Its underlying 3.0.1 behavior has automated Lua 5.1 and source-integrity coverage, plus earlier owner-reported checks of the compact window, Next line, Reset story, a complete telling and a personal story surviving `/reload`. Native build-70205 behavior has only been assessed statically.
- Chat delivery is subject to Blizzard's current chat restrictions. An accepted send request does not prove that the server displayed the message.
- Full game-restart persistence, cross-character behavior, the restored opening emotes, the replacement story collection and automatic source replies do not have complete current-client live coverage.
- A previously reported WoW Error 109 freeze remains undiagnosed. The addon has not been established as its cause, and version 3.0.2 does not claim to fix it.
- The historical tales retain older language. They are folklore and fiction for roleplay, not official Warcraft lore or claims of real events.

### Content, privacy and licences

The 20 story narratives are human-written public-domain texts credited in `STORY_SOURCES.txt`; documented real-world place names were changed only where a suitable in-game geography was required. The underlying artwork is Winslow Homer's public-domain painting *Camp Fire* (1880), credited in `ARTWORK.txt`. The separate opening actions retain their CC BY 4.0 grant. Addon code and documentation use the MIT License. Preserve `LICENCE.txt`, `CC-BY-4.0.txt`, `STORY_SOURCES.txt` and `ARTWORK.txt` when redistributing the project.

The addon has no telemetry, adverts, companion service or remote AI connection. Personal stories remain in the player's local WoW SavedVariables unless the player chooses to copy or export them. Do not include account details, character identifiers, SavedVariables or private story text in a public issue unless the specific content is required to reproduce the problem and has been redacted.
