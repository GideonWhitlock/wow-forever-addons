# Data and API verification

Checked: 27 September 2026. Client: **1.60.1.70009**, Interface **16001**, locale **enUS**. The running executable, installation build metadata and in-game GetBuildInfo report agreed.

## Sources

1. **Installed client supported APIs.** GetBuildInfo, TooltipDataProcessor with Enum.TooltipDataType.Object, GetPrimaryTooltipData, C_Spell.GetSpellDescription, C_UnitAuras.GetPlayerAuraBySpellID and C_Secrets.ShouldAurasBeSecret. The live report confirmed readable level-15 Mana Well text: 10 mana per five seconds. Cached descriptions for profession upgrades were also retrieved. Camp Tent's corresponding repeat-lockout aura was readable in a real hover.
2. **Extracted client records for this exact build**, served by wago.tools. Tables: Spell, SpellName, SpellEffect, SpellMisc and SpellDuration. Example: https://wago.tools/db2/Spell/csv?build=1.60.1.70009 . These are client data records, not proof that every placement has been tested on the server. Reduced records used by the generator are included in the source bundle.
3. **Tweaks Forever reference:** https://github.com/cjber/tweaks-forever/tree/71148471e7aea4752ee3ee9a2897c8957b42a331 . Campsites.lua, Data/CampBenefits.lua and tools/gen_camp.py supplied a cross-check for GUID entries, benefits and the object callback approach. See NOTICE.md.
4. **Blizzard UI source mirror, exact Forever build:** https://github.com/Gethe/wow-ui-source/tree/bd2470aed543f72697a044e989285b6c83e63f73 . TooltipDataHandler.lua and generated TooltipInfo, UnitAura and TooltipConstants API documentation were inspected. The client clears/rebuilds the primary tooltip and calls its post-callbacks before Show. The addon appends there, resets its duplicate guard on OnTooltipCleared, and does not change ownership, anchors or global scripts.
5. **Blizzard's Forever camping overview:** https://worldofwarcraft.blizzard.com/en-us/news/24303313 . Used for general camping context and cross-checking persistence and profession features, not to infer character-specific numbers. Its Sharpening Wheel overview differs from this build's Strength description; the addon follows the exact build's spell description.

## Evidence rules

- Placement SpellEffect **50** links to world-object entries; effect **28** links to the three summoned service creatures. All 39 mapped placement IDs were checked against these records. A placement record is not a guarantee that every hover exposes that same ID.
- Lodestone's exact English name was confirmed on the actual camp object in the follow-up live check on 27 September. The corresponding current-client placement description gave 20 melee attack power at level 15. This justified its exact Object-name fallback; no substring or creature/item matching was added. The initial ID-only mapping was insufficient for the tested tooltip.
- Spell descriptions explicitly identify inherited base benefits for profession upgrades. The addon does not assume upgrades grant stronger stats. Separate utility text follows their individual descriptions.
- Stat amounts follow the literal player-level branches in checked spell descriptions. They are not extrapolated formulas and are never copied from a maximum-level aura for all players. Brackets are stored explicitly in Data.lua.
- SpellMisc → SpellDuration confirms the **60-second** camp-rest/crafting acquisition spells 1229739 and 1289723; stat auras have **3600-second** durations. Tent acquisition aura 1229487 is **30 seconds** and repeat-lockout aura 1229451 is **3600 seconds**. These are distinct from placement cooldowns.
- Tent rested-experience threshold is 5% in the checked effect data. Its reserve is topped up only below that threshold. The one-hour value is eligibility cooldown, not an expiration of the granted rested reserve.
- Fishing Hut/Rack additionally reference rare/uncommon fishing effects 1280341/1280342 with 3600-second duration. Neither is presented as a stronger Fish Bowl attribute buff.
- Equivalent class-buff restrictions are taken from placement descriptions, not inferred by comparing stat amounts.
- Live status uses only the exact camp aura ID and a readable future expiration. The addon does not claim which object supplied an existing buff, read restricted aura points, or report an unavailable aura as inactive.

## Updating

### September 28 maintenance baseline

The central maintenance audit supplied Blizzard's [September 24 Forever development notes](https://eu.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-%E2%80%93-updated-24-september/631316) and the specific change summary: campfire buff eligibility includes chairs, sleep, lie and kneel, and casting/crafting during the wait is permitted. This local-only worker used that supplied summary; it did not independently fetch the page or reproduce the new eligibility in-game. The generator's old sit/craft wording omitted those alternatives. Version 1.0.1 corrects that instructional text without changing benefit values, IDs or timers.

Installed `.build.info` still reports **1.60.1.70009 / wow_classic_beta** on 28 September. This is an audit of an omission in the existing release, not evidence of a newer client build. The [September 25 stability restart notice](https://eu.forums.blizzard.com/en/wow/t/beta-realm-restarts-incoming-25-september/631613) was also supplied as context; no API change was inferred from a restart.

The separate tent acquisition effect remains unchanged. The supplied campfire summary does not establish new pose eligibility for the tent's rested-experience top-up. Source-page verification is owned by the central coordinator; local simulations are not proof of live buff eligibility.

### Future updates

Recheck client/API support and all changed placements, durations and literal level branches. Update `ns.checkedBuild` only after verifying the new build. Update the generator and regenerate Data.lua together; keep Names.lua fallback additions exact and conservative. Live-test at least a base object and an upgrade, and rerun the simulated tests. Keep the permanent display name **Campfire Tooltips**.
