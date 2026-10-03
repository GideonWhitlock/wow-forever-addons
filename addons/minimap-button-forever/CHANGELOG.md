# Changelog — Minimap Button: Forever

This changelog records released add-on versions. Changes that were later replaced
or reverted remain listed under the version in which they shipped.

## 1.0.14 — 2026-10-03

- Restored eligible collected buttons when the bar is opened during combat, fixing
  empty slots left by add-ons that hide their own minimap button on combat entry.
- Kept non-protected collected buttons visible when their owning add-on hides them
  again while the combat bar is expanded.

## 1.0.13 — 2026-10-03

- Allowed left-clicking the controller to show or hide the prepared bar in combat.
- Prepositioned collected buttons outside combat so the combat action only changes
  existing-frame visibility.
- Excluded protected buttons from collection.

## 1.0.12 — 2026-10-02

- Removed the artificial brightness overlays introduced in versions 1.0.9–1.0.11.
- Moved the bar backdrop onto a dedicated lower frame so original button artwork
  renders in front of it.
- Temporarily unlocked LibDBIcon fixed frame levels while collected and restored
  them when released.

## 1.0.11 — 2026-10-02

- Added a circular full-spectrum light layer to Questie and Leatrix Plus icons.
  This approach was removed in 1.0.12.

## 1.0.10 — 2026-10-02

- Strengthened the temporary Questie and Leatrix Plus artwork boost and matched
  Leatrix-created wrapper names. This approach was removed in 1.0.12.

## 1.0.9 — 2026-10-02

- Added a targeted additive artwork boost for Questie and Leatrix Plus icons.
  This approach was removed in 1.0.12.

## 1.0.8 — 2026-10-02

- Stopped retained LibDBIcon mouseover fading while buttons are collected.
- Kept collected button frames and icon textures at full opacity and colour.
- Restored the original fade and texture state when a button is released.

## 1.0.7 — 2026-10-02

- Recognised newer `Minimap.ZoomIn` and `Minimap.ZoomOut` Blizzard frame objects
  and returned them to the minimap if previously collected.
- Forced collected add-on icon textures to full colour and opacity.

## 1.0.6 — 2026-10-02

- Limited collection to buttons created by installed add-ons, leaving Blizzard
  minimap controls in their original positions.
- Prevented mouseover-only LibDBIcon fading from dimming collected buttons.
- Reclaimed collected buttons when another organiser tried to move them outside
  the bar.

## 1.0.5 — 2026-10-02

- Excluded Questie objective markers and respected the standard `MBB_Ignore` list.
- Added recursive minimap-wrapper discovery and direct UI-root candidates for
  genuine add-on launcher buttons.
- Added handling for day/night clock, tracking, world-map and zoom controls; the
  collection policy was subsequently tightened in versions 1.0.6 and 1.0.7 so
  Blizzard controls remain on the minimap.

## 1.0.4 — 2026-10-02

- Kept the gold controller fixed when the bar opens or changes orientation.
- Made horizontal and vertical bars expand inward based on screen position.

## 1.0.3 — 2026-10-02

- Replaced whole-bar frame movement with UI-scale-aware cursor tracking.
- Removed whole-bar screen clamping so a wide bar does not offset the controller
  from the cursor near a screen edge.

## 1.0.2 — 2026-10-02

- Prevented automatic scans and layout refreshes from resetting the bar during an
  Alt-drag.

## 1.0.1 — 2026-10-02

- Corrected the display name to **Minimap Button: Forever**.

## 1.0.0 — 2026-10-02

- Initial full release for WoW: Forever 1.60.1.
- Added horizontal and vertical collection layouts, show/hide controller actions,
  settings, Alt-drag movement, rescan/reset commands and restoration of recorded
  button placement when collection is disabled.

