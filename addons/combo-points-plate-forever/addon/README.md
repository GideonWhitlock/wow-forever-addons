# Combo Points: Forever

Bold, unmistakable combo points displayed above the current enemy target's visible nameplate, built for WoW: Forever (`Interface 16001`).

## Visuals

- Every supported class/spec uses the high-resolution circular gold-and-black badge marked **CP** in vivid red.
- Empty slots are dimmed; each newly gained point gives a short flare.

## Minimap icon

- Uses the same circular red **CP** artwork in a standard 32-pixel minimap button.
- Left-click toggles empty combo-point slots.
- Right-click previews a full combo-point row for 8 seconds.
- Drag the icon around the minimap to reposition it.
- `/cpf minimap` hides or restores the icon.

## Commands

- `/cpf test` — preview a full row on the current target nameplate for 8 seconds.
- `/cpf scale 1.2` — change point size (`0.6` to `2`).
- `/cpf offset 12` — change vertical position (`-20` to `80`).
- `/cpf spacing 2` — change the gap between points (`0` to `8`).
- `/cpf empty` — toggle empty point slots.
- `/cpf reset` — restore the defaults.

Enemy nameplates must be enabled in WoW. The display appears only while the current hostile target has a visible nameplate and has at least one combo point.
