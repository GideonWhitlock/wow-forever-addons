# Choose a Main: Forever

**Choose a Main: Forever** is a private, in-game decision aid for choosing a class and talent specialisation in World of Warcraft: Forever. It asks 24 questions, applies optional experience and hard restrictions, evaluates all 27 talent paths across the nine available classes, and explains two independently weighted outcomes:

- **Best Gameplay Match** prioritises combat rhythm, role, range, movement, control, upkeep and practical play habits.
- **Best Long-Term Main** gives more weight to class fantasy, attachment, levelling comfort, flexibility and prior experience.

It is not a damage tier list, an AI service or a probability model. Scores are transparent model scores, not percentages of future enjoyment.

## Installation

1. Close WoW.
2. Copy the `ChooseAMainForever` folder into `_classic_beta_\Interface\AddOns\` for the current Forever beta.
3. Start WoW and enable **Choose a Main: Forever** on the AddOns screen.
4. Type `/chooseamain` (`/classcompass` remains available as a legacy alias).

Prepared compatibility: WoW: Forever `1.60.1.70338`, interface `16001`. In-game acceptance is still required before release.

## Commands

- `/classcompass` or `/chooseamain` — open or close the assessment
- `/classcompass result` — open the previous result
- `/classcompass show` / `/classcompass hide` — show or hide the minimap button
- `/classcompass reset` — request confirmation before clearing assessment data

## What is saved

Answers, structured preferences, optional personal notes, the previous result, UI position/scale, minimap position, scoring version and class-profile version are stored locally in `ChooseAMainForeverDB`. There is no telemetry, analytics, network access, advertising or external AI call.

## Honest limits

Forever is in beta. Capability ratings are a documented expert model based on official class deep dives and Classic-rooted class identities, not performance measurements. Balance changes may alter a rating. The add-on deliberately avoids damage rankings and does not claim statistical accuracy. See [RESEARCH.md](RESEARCH.md), [METHODOLOGY.md](METHODOLOGY.md) and [KNOWN-LIMITATIONS.md](KNOWN-LIMITATIONS.md).

## Development status

Version `1.0.2` passed the automated engine, syntax and mocked-interface checks. The owner reviewed the interface in the Forever client; this revision compacts the lower restrictions layout to keep the final class row clear of Personal Notes at supported window scales. Any remaining live edge cases are listed in `KNOWN-LIMITATIONS.md`.

Code is MIT licensed. The generated compass artwork is original project artwork; World of Warcraft and its game assets remain the property of Blizzard Entertainment.

All maintenance and release work is subject to the mandatory persisted-state and CurseForge thumbnail checks in [WORKFLOW-GATES.md](WORKFLOW-GATES.md).
