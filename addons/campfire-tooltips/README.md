# Campfire Tooltips: Forever

**Campfire Tooltips: Forever** adds short, separated explanations to the normal world tooltip when you hover over a recognised camping object in **World of Warcraft: Forever**. It preserves the original object name, game text and tooltip position. No click or target is needed to read the explanation.

Current public release: **1.0.1**  
Game flavour: **WoW: Forever**  
Game version: **1.60.1**  
Interface: **16001**

The add-on is standalone and has no required add-on dependencies.

## What it shows

- The object's camp benefit or function.
- The character-level amount when the current client build has verified data.
- How to gain the benefit and how long it lasts.
- The class buff it does not stack with, where applicable.
- Extra uses of profession upgrades and camp services.
- The remaining time of the character's exact corresponding camp buff, when that information is readable.

The mapping covers **39 researched camping placements and services**, including campfires, tents, stat objects, profession upgrades and three camp service creatures.

## Installation

1. Download the Campfire Tooltips ZIP.
2. Extract the `CampfireTooltips` folder into the active WoW: Forever client's `Interface/AddOns` folder.
3. Confirm the file layout ends with `Interface/AddOns/CampfireTooltips/CampfireTooltips.toc`.
4. Restart the game after a first installation. After an update, an interface reload is sufficient.

To remove it, exit the game and remove the `CampfireTooltips` folder. Preferences are stored separately in WoW SavedVariables and are not removed automatically.

## Use and settings

Hover over a supported camp object in the world.

Open **Options → AddOns → Campfire Tooltips**, or enter:

```text
/camptooltips
```

Settings:

- **Explain camping object benefits** — enables or disables the added descriptions.
- **Show the corresponding active buff and time remaining when readable** — adds the character's matching active-buff timer when the game permits access.

Optional diagnostic controls:

- **Start hover checks / Stop hover checks**
- **Refresh report**
- **Reload interface**

Diagnostics stay local. They retain at most 25 readable camp-object/service observations and do not upload data.

## Known limitations

- Benefit data and character-level amounts were verified against **1.60.1 build 70009**. On another build, the add-on deliberately shows the general benefit without an unverified numeric prediction.
- Recognition uses a supported object/service ID first. When the game does not expose an object ID, only explicitly allowed exact English object names can be used.
- Ambiguous generic names such as `Chair` and `Anvil` remain unchanged without a readable supported ID. Some placements are therefore ID-only.
- Exact-name fallback support is English-only. Unrecognised objects and unrelated items, spells, players and creatures remain unchanged.
- An object description does not confirm that its required campfire is still present or that the character is eligible to receive the benefit.
- Active-buff status is omitted when absent, restricted, unavailable or unsafe to inspect. It is never reported as “inactive”. Timers refresh on the next tooltip refresh or hover.
- An active-buff timer describes the character's matching buff; it does not identify which object granted it.

## Licence and attribution

Campfire Tooltips: Forever is licensed under **GPL-3.0-or-later**. The object mapping and tooltip approach were informed by [Tweaks Forever](https://github.com/cjber/tweaks-forever/tree/71148471e7aea4752ee3ee9a2897c8957b42a331), also licensed GPL-3.0-or-later. Preserve the add-on's `LICENSE`, `NOTICE.md`, source notices and corresponding source when redistributing it.

World of Warcraft names and game data belong to their respective rights holders. Campfire Tooltips: Forever is not an official Blizzard product.
