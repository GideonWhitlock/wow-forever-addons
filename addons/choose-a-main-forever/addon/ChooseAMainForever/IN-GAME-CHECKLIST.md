# Owner in-game acceptance checklist

Status: **not yet run**.

Use WoW: Forever build `1.60.1.70338` or record the newer build before testing.

- Add-on appears as **Choose a Main: Forever** and loads without Lua errors.
- `/classcompass` and `/chooseamain` open and close the window.
- Escape closes the window without affecting other panels.
- Window drag and `+`/`-` scaling persist after `/reload`.
- Minimap button opens the assessment, opens the previous result on right-click, drags correctly and respects show/hide commands.
- All 24 questions display every answer without clipping; previous/next/review preserve choices.
- Class experience uses clear Played before, Max level, Enjoyed/Disliked and Would play again labels.
- Selecting an answer advances immediately; going back, changing it and selecting again saves the replacement and advances.
- Max level, Enjoyed, Disliked and Would play again remain disabled until Played before is selected; clearing Played before clears all four.
- Enjoyed and Disliked cannot remain selected together.
- Faction, allowed race, stationary casting, unwanted role and unwilling class controls filter results.
- An impossible restriction set shows a conflict instead of a recommendation.
- Notes persist but never appear in recommendation reasoning.
- Gameplay and long-term tabs can produce different winners and explain why.
- Three headline recommendations use different classes and satisfy restrictions.
- Reasoning tabs agree with the displayed winner and do not claim probabilities.
- Retake, result recall and confirmed reset work after `/reload` and relog.
- No protected-action, taint or combat disruption is observed.
- Capture genuine screenshots only after this checklist passes.

Record tester, build, date, errors and any screenshots in a separate acceptance report. Do not edit this checklist to say “passed” without running it in the client.

When finishing the acceptance session, save or submit the final test record, reopen it to verify persistence, then close temporary dialogs, editor tabs and auxiliary applications. No unfinished form or ambiguous UI state should remain.
