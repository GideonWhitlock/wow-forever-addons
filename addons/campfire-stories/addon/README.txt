CAMPFIRE STORIES: FOREVER 3.0.2
By Gideon. WoW: Forever 1.60.1 (build 70009), Interface 16001.

QUICK START
1. Left-click the campfire minimap button or type /campfire ui.
2. Choose an Included story, or use Pick for me.
3. Start story shares a short opening action in /emote.
4. Next line begins the original story in /say; keep clicking to continue.
Reset story sits beside the main button and returns to the opening emote.
Story lines never send automatically. Reaching the end stops the telling.

Small window opens a compact, movable telling panel. Library takes you back
without losing your place. More options holds Pause, Back one message, line
previews, copying/export and the audience choice: Nearby players (/say) or
Your party only (normal invited /party). No campfire detection is required.
The preview always shows the exact next message and its destination.
/campfire uses the same send action; if the preview is hidden, the first
press opens it and does not send. All game input remains yours.

THE COLLECTION
20 complete human-written public-domain ghost and witch tales replace all
31 earlier included stories. They are not ChatGPT-written or AI-generated.
Stories contain 261-955 words, split into 8-29 chat messages. The source
wording and endings are retained, including older expressions; only listed
place names and typographic formatting change. Some real places have been
mapped to suitable WoW areas. Maritime events remain beside water.
These are folklore and fiction for roleplay, not official Warcraft lore or
claims of real events. Sources and all substitutions: STORY_SOURCES.txt.
Credits are visible beneath the selected title. At the owner's request, the
earlier short roleplay emotes are restored separately from the sourced tales.
No spoken introduction or fictional premise is added to the original text.
Logo and minimap art use Winslow Homer's human painting; see ARTWORK.txt.

UPGRADING
Back up the old CampfireStory folder and its SavedVariables outside AddOns.
Replace only this addon's folder. If already logged in, activate installed
changes yourself with /reload. No settings file is rewritten by the installer.
Removed bundled tales are cleared from active/recovery snapshots on load;
Reset cannot bring them back. A new sourced tale is selected without sending.
Personal library entries, custom text, settings and outstanding waits remain.
Player-made copies are your own library and are not deleted automatically.
Older personal stories using shared openings now start with their own first
line. Player-written custom emotes and introductions remain supported.

PERSONAL STORIES AND BACKUP
Write a story accepts a title, optional premise and 1-30 lines, one chat
message per line (up to 255 UTF-8 bytes). You can duplicate included stories,
edit, rename, delete, import/export, and back up your personal library.
Story text only is the default for new personal stories. The editor also
offers Opening emote or your own Custom openings.
Personal custom openings use group:text rows for emotes and introductions.
Matching groups pair together; * matches any. Use plain text, no slash command.
{title} and {premise} placeholders are allowed only in your custom openings.
An active personal telling keeps its snapshot until explicitly reset.

Example import (replace the placeholders with your own text):
CAMPFIRE-STORY:1
title:Your story title
premise:
mode:none
L:Your first story line.
L:Your second story line.
END

Settings > Export all / backup copies personal stories, progress and settings
as CAMPFIRE-BACKUP:1 text. Save it outside the game. Restore merges stories as
new copies, keeps existing work and pauses sending. It never executes Lua.
SavedVariables: CampfireStoryLibraryDB account-wide; legacy CampfireStoryDB
is retained. Basic personal-save/reload was confirmed on an earlier version;
full restart and other-character persistence remain unverified on this client.

PACING AND RESTRICTIONS
Default dynamic wait is min(20, max(2, ceil(1 + characters / 12))) seconds.
The next message determines eligibility from the last outgoing attempt.
Settings also offers fixed pacing. Changing story, window, channel or settings
cannot shorten an outstanding wait. No story-send timers or automatic story progression exist. Sending is blocked during combat or chat restrictions.
A successful API call does not prove delivery; inspect chat and manually
preview/retry a line if the client reports an error.

SUPPORT AND LICENCES
Use the CurseForge comments with addon version, client build (Help > Client
diagnostics), steps and the exact error. Keep account details and personal
libraries private. Public distribution uses the normal Release channel.
No extra addon, companion app, adverts, telemetry or remote AI service.
Code: MIT. Historical texts and artwork: public domain. See LICENCE.txt.
Development and editorial/formatting work used AI assistance; the story prose
and underlying artwork were made by humans. See TEST_NOTES.txt for evidence.
An earlier Error 109 client freeze remains undiagnosed; no crash fix is claimed.

PRIVATE SOURCE REPLIES
Settings > Source replies is on by default. During a visible active telling
of an unchanged included story, after a story line is manually sent, an
AI/ChatGPT mention in the selected /say
or party audience can trigger one private whisper to that speaker, with the
human source credit and addon link. No General/Trade or incoming-whisper scan.
No replies while paused, finished, closed or idle for 90 seconds; none for
personal stories. One per person per login, at most three people per telling,
at least 30 seconds apart. A single pending reply is rechecked before sending
and cancelled when no longer applicable. It cannot advance the story. Reply
attempts respect the shared wait and client restrictions; no retries/fallback.
Chat errors disable replies for the login. No audience chat text is stored.
This feature uses keyword matching, not an understanding of the speaker's intent.
