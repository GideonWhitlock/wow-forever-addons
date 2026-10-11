# Live test record

Status: **Owner accepted for public release on 11 October 2026.**

Recorded release evidence: the owner completed the required full-client-restart isolation test and confirmed normal keyboard control with the corrected build, then explicitly approved public CurseForge release. No unresolved live blocker was reported. The checklist below remains the regression matrix for future Forever builds.

Target: WoW: Forever 1.60.1.70338 or newer, Interface 16001.

## Required owner acceptance

- [ ] Start with only Objective Hider enabled. Confirm W, A, S, D, Escape, Enter/chat, mouse clicks and normal action keys all work before testing tracker behavior.
- [ ] Open and close the add-on settings, then repeat the complete input check; no key is swallowed.
- [ ] Disable Objective Hider, reload, enable only Objective Hider, and reload again; input remains normal across the transition.
- [ ] Unmodified Blizzard UI: accept/progress/complete quests; tracker stays hidden when ON and restores when OFF.
- [ ] RestedXP loaded: guide window, arrow, active item/target buttons and guide advancement continue normally.
- [ ] RestedXP hidden: `restedxp` mode releases Blizzard's tracker; `always` mode does not.
- [ ] Questie tracker enabled and disabled: Questie continues operating; no visibility tug-of-war or errors.
- [ ] Reload, relog and zone change preserve the selected mode and minimap angle.
- [ ] Enter combat, toggle twice, accept/progress a quest, then leave combat: only the final requested state applies.
- [ ] Left-click the minimap button ON/OFF at least 20 times; RestedXP must remain visible and responsive.
- [ ] Drag through 0°, 90°, 180°, 270° and diagonals: button centre remains on the minimap rim.
- [ ] Reload at each cardinal position and after changing resolution/UI scale: position remains angle-correct.
- [ ] Test with a minimap-button collector: circular icon remains centred, unclipped and legible at collector size.
- [ ] Inspect actual 24–34 px render: transparent corners, clean circular frame, no black square or missing texture.
- [ ] Confirm the former green/black rectangular artifact is absent on the minimap and in a button collector.
- [ ] Fully exit WoW, relaunch, then confirm no `Bindings.xml`, `KeyBinding.lua` or other startup warning appears.
- [ ] Run `/reload` once more and confirm the error display remains empty.
- [ ] Disable from settings and `/rxpoh off`: the pre-hide Blizzard tracker state is restored.
- [ ] Remove the add-on, reload, and confirm Blizzard regains normal tracker control.
- [ ] `/rxpoh reset` and `/rxpoh recover` work without Lua errors.
- [ ] No taint/protected-action warning appears during combat or immediately after it.

Record exact build, UI scale, resolution, RestedXP version, Questie version, observed failures and owner verdict here.
