# Forever research record

Research date: 11 October 2026 (Europe/London)

## Verified environment

- Installed product: `wow_classic_beta`
- Client: `1.60.1.70338`
- Interface: `16001`
- Lua target: 5.1-compatible syntax on Forever's current UI engine
- Build-matched UI source: Gethe `forever`, commit `943764493e6b16d63ded3ab304150d1f05e58b57`, labelled `1.60.1 (70338)`
- Add-on conventions reviewed: Gideon Whitlock's installed Forever add-ons and prepared `wow-forever-addons` repository

## Verified stable facts used by the database

Blizzard's current Forever material confirms nine classes, their named talent paths, the Classic-rooted combat philosophy, dual specialisation at level 40, and the current race/class combinations. The data model uses those names and restrictions.

Primary references:

- [World of Warcraft: Forever](https://worldofwarcraft.blizzard.com/en-us/forever/)
- [Create the Hero You Want to Be in World of Warcraft: Forever](https://worldofwarcraft.blizzard.com/en-us/news/24304075)
- [Forever Deep Dive panel recap](https://worldofwarcraft.blizzard.com/en-us/news/24303313)
- [Hunter and Druid class deep dive](https://worldofwarcraft.blizzard.com/en-us/news/24301515)
- [Priest and Warrior class deep dive](https://worldofwarcraft.blizzard.com/en-gb/news/24301514)
- [Rogue and Warlock class deep dive](https://worldofwarcraft.blizzard.com/en-gb/news/24310968)
- [Mage and Shaman class deep dive](https://worldofwarcraft.blizzard.com/en-gb/news/24302097)
- Build-matched [Forever UI source](https://github.com/Gethe/wow-ui-source/tree/forever)

## Evidence boundary

Class profile ratings are qualitative compatibility judgments, not official balance values. Each profile records the official article family behind it and is marked provisional. The database does not name unverified spells in recommendations, claim a damage ranking or infer undocumented talent interactions.

Paladin's current profile is based on the official panel recap because a dedicated Paladin deep-dive article was not available in the research set on 11 October 2026. This is the highest-priority profile to revisit when Blizzard publishes more detailed current notes.

The beta notice in Blizzard's class material explicitly says abilities and talents may continue to change. `profileVersion` therefore includes the build and research date.

## API decisions

The add-on uses ordinary unprotected UI frames, `BackdropTemplate`, `StaticPopupDialogs`, `UISpecialFrames`, slash commands and account-wide SavedVariables. It does not perform protected actions or register recurring gameplay events. The only runtime event is `ADDON_LOADED`.
