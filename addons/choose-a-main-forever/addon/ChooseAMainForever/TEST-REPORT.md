# Automated test report — 1.0.2

Run date: 11 October 2026

Environment: Fengari Lua runtime under Node.js; pure data and recommendation modules only.

Result: **14 passed, 0 failed**.

Additional validation: **14/14 Lua files parsed successfully** and the mocked UI construction/navigation smoke test passed.

Passed checks:

- all 24 questions and answer definitions validate
- all nine classes and 27 talent paths are assessed
- identical input is deterministic
- hard stationary-casting exclusion is respected
- class and primary-role exclusions are respected
- faction and race restrictions use the verified matrix
- impossible restrictions produce an explicit conflict
- missing answers cannot claim high confidence
- tank versus healer preference materially changes the winner
- explanations name the actual winner and include trade-offs
- every individual answer choice runs without error
- headline alternatives use different classes
- structured history affects long-term scoring more than gameplay scoring
- 720 seeded complete-answer profiles produce winners from all nine classes, with no class exceeding 45% of the sample

Seeded gameplay-winner distribution: Druid 272, Hunter 105, Mage 4, Paladin 143, Priest 17, Rogue 10, Shaman 97, Warlock 31, Warrior 41. This is a diagnostic sample of uniformly random answer choices, not a forecast of real player selections. Druid's broad representation is explainable by the uniformly sampled flexibility and role answers, but remains a profile-review watch item rather than proof of population fairness.

Personal calibration output: **Survival Hunter** for Best Gameplay Match and **Survival Hunter** for Best Long-Term Main. This was observed, not asserted. The fixture contains no expected class and the engine has no calibration-specific branch.

The UI smoke test constructs every screen, selects the ten-choice question, navigates both optional panels, calculates and switches both result views, opens a reasoning section, creates the minimap button and creates the reset confirmation using a deliberately small WoW API mock.

Not covered by this run: rendering inside the Forever client, taint/protected-action observation, live Escape behaviour, drag/scale behaviour, minimap artwork placement, SavedVariables reload persistence and genuine gameplay screenshots.

- Live client check, 11 October 2026: the recommendation model was verified after /reload; increasing the window scale keeps the complete head and Naxxramas armour visible.
- Version 1.0.2 anchors the Personal Notes field above the footer and compacts the role and class rows so the final class choice cannot enter the notes area at supported window scales.

