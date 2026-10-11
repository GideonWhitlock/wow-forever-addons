# Objective Hider for RestedXP — Forever

Reclaim the space beside your WoW: Forever character: this focused utility keeps Blizzard's **All Objectives** tracker hidden while you use the RestedXP guide window.

**Independent compatibility utility. Not affiliated with, endorsed by, or supported by RestedXP.** RestedXP is a trademark of its respective owner. This project includes no RestedXP code, guides, paid content, artwork or branding assets.

## Focused controls

- Hide Blizzard's objective tracker only while RestedXP is active, or hide it all the time.
- Left-click the original gold-and-green minimap emblem to turn objective hiding **ON** or **OFF** immediately.
- Drag the circular button around the minimap rim; right-click it for settings.
- Use `/rxpoh` or the minimap button. A keybinding will return only if Forever exposes a verified safe interface.
- Quest accepts, progress, completions, reloads and zone changes cannot silently undo the chosen state.
- Combat-safe deferral avoids protected-frame changes until combat ends.
- Turning the feature off restores the tracker state captured before this utility took control.

RestedXP's guide window, arrow, target buttons and normal guide operation are left alone. Questie is detected for diagnostics but never modified.

## Honest Forever compatibility

WoW: Forever is evolving. If Blizzard changes the named objective-tracker frame, the add-on reports a compatibility warning through `/rxpoh status` and stops touching the tracker. Please report the exact Forever build, RestedXP/Questie versions, steps and a redacted Lua error.

Free, source-visible and MIT licensed.

- [Source](https://github.com/GideonWhitlock/wow-forever-addons/tree/main/addons/objective-hider-for-restedxp-forever)
- [Changelog](https://github.com/GideonWhitlock/wow-forever-addons/blob/main/addons/objective-hider-for-restedxp-forever/CHANGELOG.md)
- [Report an issue](https://github.com/GideonWhitlock/wow-forever-addons/issues/new?template=objective-hider-for-restedxp-forever.yml)

Publish the source folder and issue form before submitting this description, then verify all three links from a logged-out browser.
