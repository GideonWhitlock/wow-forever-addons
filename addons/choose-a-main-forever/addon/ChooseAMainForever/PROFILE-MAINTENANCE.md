# Class-profile maintenance workflow

1. Record the live Forever client build and interface number from `.build.info` and `GetBuildInfo()`.
2. Update the build-matched `forever` UI-source checkout and record its commit.
3. Read new official class deep dives and patch notes. Do not use damage meters or tier lists as the compatibility foundation.
4. Identify only affected dimensions: mobility, casting dependence, control, utility, durability, recovery, solo independence, multi-target capability, burst/sustain, preparation, complexity, upkeep, pets, group responsibility, PvP flexibility, role flexibility, gear dependence, levelling, endgame, identity and short-session suitability.
5. Change the smallest defensible set of `0..5` ratings and update that profile's evidence string.
6. Increment `profileVersion`; increment `scoringVersion` only if interpretation, weights, interactions or ranking logic changed.
7. Run `Tests/run.lua`, inspect every changed profile's contribution trace, and compare at least the 15 contrasting fixtures in `TESTING.md`.
8. Run the in-game checklist on the exact supported build.
9. Record the change and known uncertainty. Never claim live validation that was not performed.
10. Complete the final save or submission, reopen the destination to verify the persisted state, record its identifier or checksum, and close all temporary tabs, dialogs and applications.

Ratings should change because gameplay meaning changed, not because a class is temporarily popular or has high raid damage.
