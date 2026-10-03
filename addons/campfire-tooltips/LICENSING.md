# Licensing and privacy notes

## Licence and source

Campfire Tooltips: Forever is licensed **GPL-3.0-or-later**. A public repository that distributes or presents itself as the add-on's source should include:

- the complete corresponding Lua source and metadata for the distributed version;
- the existing full GPL `LICENSE` file;
- the existing `NOTICE.md` attribution;
- existing SPDX/source notices; and
- the build/research provenance needed to understand generated `Data.lua` and `Names.lua`.

The object mapping and tooltip approach were informed by [cjber/Tweaks Forever at commit 71148471e7aea4752ee3ee9a2897c8957b42a331](https://github.com/cjber/tweaks-forever/tree/71148471e7aea4752ee3ee9a2897c8957b42a331), which is also GPL-3.0-or-later. Preserve that attribution. Do not label a documentation-only location as **Source**.

World of Warcraft names and game data belong to their respective rights holders. The repository should state that Campfire Tooltips: Forever is not an official Blizzard product.

## Privacy

The add-on has no telemetry or upload feature. Its optional hover diagnostics are stored locally and intentionally avoid player names and unrelated creature details.

Public issue reports should not include full SavedVariables/WTF folders, account identifiers, character or realm names, access tokens, private filesystem paths or unrelated chat. Ask for the smallest relevant redacted error and diagnostic excerpt.
