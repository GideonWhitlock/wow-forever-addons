# Supported camping placements

Checked against client build 1.60.1.70009. This table describes verified data coverage, not 39 completed live tests. Recognition requires a readable supported ID or an explicitly allowed exact name; see TESTING.md.

On the tested client, real object tooltips exposed names but no GUID/entry ID. Thus ID-only entries remain unavailable in those tooltips. The 27 exact-name fallbacks are English only; most profession names still need live confirmation. A Camp Chair was actually labelled "Chair", which is deliberately left unchanged because the name alone is ambiguous.

| Object or service | Entry ID | Placement spell | Recognition | Benefit | Additional utility |
|---|---:|---:|---|---|---|
| Mana Well | 651948 | 1307259 | ID or exact name | Restores mana every 5 seconds. | — |
| Alchemy Laboratory | 612139 | 1307172 | ID or exact name | Restores mana every 5 seconds. | Required by some crafting recipes. |
| Fermenter | 612120 | 1307242 | ID or exact name | Restores mana every 5 seconds. | Craft certain reagents. |
| Sharpening Wheel | 651950 | 1307392 | ID or exact name | Increases Strength. | — |
| Anvil | 612125 | 1307175 | ID only | Increases Strength. | An anvil for crafting. |
| Master Forge | 612136 | 1307261 | ID or exact name | Increases Strength. | Required by some crafting recipes. |
| Enchanted Lute | 651952 | 1307234 | ID or exact name | Increases armor; higher levels also gain attributes and resistances. | — |
| Arcane Forge | 612143 | 1307176 | ID or exact name | Increases armor; higher levels also gain attributes and resistances. | Required by some crafting recipes. |
| Arcane Salvager | 612130 | 1307223 | ID or exact name | Increases armor; higher levels also gain attributes and resistances. | More efficient disenchanting. |
| First Aid Kit | 651953 | 1307244 | ID or exact name | Increases Stamina. | — |
| Plague Doctor's Laboratory | 612110 | 1307265 | ID or exact name | Increases Stamina. | Healing potions and poultices. |
| Toxin Study | 612091 | 1307396 | ID or exact name | Increases Stamina. | Healing potions and anti-venom. |
| Fish Bowl | 651954 | 1307245 | ID or exact name | Increases all attributes. | — |
| Fishing Hut | 612092 | 1307246 | ID or exact name | Increases all attributes. | Enables rare fish catches for 1 hour; fishing-skill lures. |
| Fishing Rack | 612090 | 1307247 | ID or exact name | Increases all attributes. | Enables uncommon fish catches for 1 hour; fishing-skill lures. |
| Incense Candle | 651955 | 1307251 | ID or exact name | Increases Intellect. | — |
| Greenhouse | 612087 | 1307248 | ID only | Increases Intellect. | Plant seeds to grow herbs over time. |
| Lodestone | 651956 | 1307254 | ID or exact name | Increases melee attack power. | — |
| Molten Foundry | 612134 | 1307264 | ID or exact name | Increases melee attack power. | Required by some crafting recipes. |
| Rock Garden | 654285 | 1307386 | ID or exact name | Increases melee attack power. | Grows a common mining node over time. |
| Camp Chair | 612275 | 1307229 | ID or exact name | Increases critical strike chance with spells and attacks. | — |
| Field Guide | 612088 | 1307243 | ID only | Increases critical strike chance with spells and attacks. | Read it to gain Track Beasts. |
| Trapper's Workbench | 612082 | 1307397 | ID or exact name | Increases critical strike chance with spells and attacks. | Contains one trap. |
| Faction Banner | 612351 | 1307239 | ID only | Increases Spirit for members of the banner's faction. | This banner benefits Alliance players. |
| Faction Banner | 612350 | 1307240 | ID only | Increases Spirit for members of the banner's faction. | This banner benefits Horde players. |
| Loom | 612142 | 1307255 | ID only | Increases Spirit for members of the banner's faction. | Required by some crafting recipes. |
| Spinning Wheel | 612123 | 1307393 | ID only | Increases Spirit for members of the banner's faction. | Craft certain reagents. |
| Camp Tent | 528996 | 1307230 | ID or exact name | Adds rested experience. | — |
| Sewing Machine | 612140 | 1307391 | ID or exact name | Adds rested experience. | Required by some crafting recipes. |
| Tanning Rack | 612122 | 1307395 | ID only | Adds rested experience. | Craft certain reagents. |
| Basic Campfire | 529161 | 1307227 | ID only | Cooking and a place to rest. | Supports up to 3 additional camp features. |
| Journeyman Campfire | 630660 | 1307252 | ID or exact name | Cooking and a place to rest. | Supports up to 5 additional camp features. |
| Expert Campfire | 650137 | 1307237 | ID or exact name | Cooking and a place to rest. | Supports up to 10 additional camp features. |
| Anarchist's Workbench | 612145 | 1307174 | ID or exact name | A station for special crafting recipes. | — |
| Iron Oven | 612132 | 1307226 | ID or exact name | A station for advanced cooking recipes. | — |
| Cookie's Feast | 612073 | 1307257 | ID or exact name | Food that increases Stamina. | — |
| Seed Hybridizer | 260105 | 1307387 | ID only | Increases Intellect. | Multiply seeds or combine them into rarer tiers. |
| Reagent Bot | 242498 | 1307266 | ID only | Reagent vendor. | — |
| Repair Bot | 254695 | 1307385 | ID only | Repairs and reagent vendor. | — |

The three service entries (Reagent Bot, Repair Bot and Seed Hybridizer) use exact Creature GUID IDs. Everything else uses the world-object callback. No broad name match is used for creatures.

The base campfire variants have capacities of 3, 5 and 10 additional features respectively. Feature placement cooldowns are not shown as buff durations.
