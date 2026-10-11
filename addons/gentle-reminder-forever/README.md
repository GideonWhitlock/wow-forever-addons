# Gentle Reminder: Forever

Warm, private reminders for **World of Warcraft: Forever**. Remember a break, a glass of water, a stretch, bedtime, an appointment, food, medication, or a household task—without being told what to do.

> **Release status:** version `1.0.1`, owner-accepted on WoW: Forever `1.60.1.70338` / interface `16001`. Automated validation passes. Public GitHub and CurseForge publication are handled separately from this prepared source package.

## What makes it different

Gentle Reminder is a personal memory aid rather than a playtime limit. It never locks controls, forces logout, grades a session, moralises, or announces anything to chat. Session and daily totals are neutral context. Every reminder stays on the local computer in SavedVariables.

It brings a break reminder, playtime reminder, session timer, hydration reminder, stretch reminder, bedtime reminder and flexible gaming timer into one focused Forever add-on without turning “healthy gaming” into a lecture.

## MVP features

- Recurring reminders with separate weekday and weekend profiles.
- Private one-off timers: `/grf remind 25m Put the washing out`.
- Custom recurring and bedtime text, with an explicit Local time or Server time bedtime basis.
- Neutral session and today totals.
- One to five configurable snooze choices.
- Combat- and cinematic-aware delivery; visible reminders are hidden and re-queued if either starts.
- Optional sound and opt-in spoken reminders, with a dependable visual fallback.
- Movable minimap icon, quick-add dialog, status command, reset, and backup recovery.
- Original pocket-watch-and-leaf branding in the AddOns list, settings, reminder card and minimap button.
- No libraries, networking, telemetry, advertising, group messages, or protected gameplay actions.

## Install for testing

1. Exit WoW completely.
2. Copy the `GentleReminderForever` folder into `_classic_beta_/Interface/AddOns/`.
3. Launch Forever and enable **Gentle Reminder: Forever**.
4. Click the pocket-watch minimap icon or type `/grf`.

## Commands

- `/grf` — open settings
- `/grf remind 20m Take the laundry out` — one-off reminder
- `/grf on` / `/grf off` — resume or pause recurring reminders; one-offs stay active
- `/grf status` — show profile, session, today and next reminder
- `/grf interval 60` — set the active weekday/weekend profile interval
- `/grf bedtime 22:30` or `/grf bedtime off`
- `/grf bedtimebasis local` or `/grf bedtimebasis server`
- `/grf snoozes 5,10,20`
- `/grf test` — preview delivery
- `/grf hide` / `/grf show` — hide or restore the minimap icon
- `/grf reset` — restore defaults and retain a recovery copy
- `/grf recover` — swap back to the saved backup

## Privacy and safety

The add-on never uses party, raid, guild, whisper, public chat, add-on communications, HTTP, telemetry, or analytics. Personal reminder text and playtime totals remain in `GentleReminderForeverDB`. Do not paste SavedVariables or personal reminder text into a public issue.

“Today” is logged-in time observed by this add-on, not Blizzard account-wide playtime. Spoken reminders use the local client text-to-speech API when enabled and available; they may be audible to people nearby.

## Testing status

See [TESTING.md](addon/TESTING.md). Automated syntax, package, metadata, privacy-surface, icon and behavioural-model checks are required before every package. The owner accepted the installed `0.1.3-alpha` behaviour as the `1.0.1` release baseline; scenarios not directly observed remain recorded honestly in the test notes.

## Source and support

- Source: <https://github.com/GideonWhitlock/wow-forever-addons/tree/main/addons/gentle-reminder-forever/addon>
- Changelog: <https://github.com/GideonWhitlock/wow-forever-addons/blob/main/addons/gentle-reminder-forever/CHANGELOG.md>
- Report an issue: <https://github.com/GideonWhitlock/wow-forever-addons/issues/new?template=gentle-reminder-forever.yml>

Free, source-visible and equally supported. MIT licensed. World of Warcraft names and client-supplied UI artwork remain the property of their owners.

