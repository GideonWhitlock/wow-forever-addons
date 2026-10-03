## Combo Points: Forever

**Current release:** 1.0.6  
**Game flavour:** World of Warcraft: Forever  
**Supported game version:** 1.60.1  
**Interface version:** 16001

Combo Points: Forever displays crisp, circular gold-and-black **CP** badges above the current hostile target's visible nameplate. It supports both the legacy target-bound combo-point API and newer player-resource implementations, and adapts to the character's available maximum up to 10 points.

### Installation

1. Download the release ZIP and close World of Warcraft.
2. Extract the `ComboPointsForever` folder into the Forever client's `Interface/AddOns` directory.
3. Confirm that `ComboPointsForever.toc` and `ComboPointsForever.lua` are directly inside the `ComboPointsForever` folder rather than inside an extra nested directory.
4. Start the Forever client and enable **Combo Points: Forever** in the AddOns list if it is not already enabled.
5. Enable enemy nameplates in the game settings.

### Controls and settings

The minimap button uses the same circular red **CP** artwork as the nameplate display.

- **Left-click:** toggle empty combo-point slots.
- **Right-click:** preview a full combo-point row for eight seconds.
- **Drag:** reposition the button around the minimap.

Slash commands:

- `/cpf test` — preview a full row on the current target's nameplate for eight seconds.
- `/cpf scale 1.2` — set badge scale from `0.6` to `2`.
- `/cpf offset 12` — set vertical offset from `-20` to `80`.
- `/cpf spacing 2` — set spacing from `0` to `8`.
- `/cpf empty` — toggle empty combo-point slots.
- `/cpf minimap` — hide or restore the minimap button.
- `/cpf reset` — restore all defaults.

Settings are saved per character.

### Known limitations

- The normal display appears only for the current hostile target, only while that target has a visible nameplate, and only after at least one combo point has been generated.
- Enemy nameplates must be enabled.
- The add-on depends on the Forever client exposing combo points through either the legacy target-bound API or the player-resource API.
- The display is capped at 10 points.
- Static compatibility checks passed for WoW: Forever 1.60.1 build 70205, but live Rogue and Feral Druid behaviour and placement on that build remain unverified.

When reporting a problem, use the shared repository's **Combo Points: Forever bug report** form and remove account names, character names, local paths, tokens, and other private information from error text.
