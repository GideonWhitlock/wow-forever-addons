# Changelog

## 0.1.8 — 2026-11-13

- Added visible Recalculate feedback with the recalculation time.
- Recalculate now states whether the current recommendation remains best or has changed.
- Reverified Favor rewards used by cost-per-Favor ranking: raw Apprentice/Journeyman/Expert crates award 5/10/15, while crafted crates award 10/20/30.
- Added regression checks that prevent those reward mappings from changing silently and keep unverified Artisan crates excluded.
- Added new crop-safe Waylaid Crate project artwork for public listings.

## 0.1.7 — 2026-11-12

- Removed every protected programmatic purchase call that WoW Forever blocked with `Interface action failed because of an AddOn`.
- The optimiser now opens the exact item and quantity in WoW's native Buy page; the player completes the purchase with WoW's own Buy button.
- Advances from the crate to its matching materials only after WoW reports a genuine successful purchase.
- Locks the selected crate and material bundle for the whole sequence so price/database refreshes cannot switch to another recommendation midway.
- Keeps routine purchase preparation silent while preserving useful error messages.

## 0.1.6 — 2026-11-12

- Fixed WoW's `Interface action failed because of an AddOn` error during commodity purchases.
- Kept the single purchase button, but split each protected purchase into two deliberate presses: prepare/check the live price, then confirm the displayed total.
- Moved both protected Auction House calls directly onto player button clicks instead of delayed callbacks.
- Added reliable crate search names and a safe retry state when WoW has not loaded an item's name yet.
- Prevented purchase preparation while Auctionator is still scanning.

## 0.1.5 — 2026-11-12

- Replaced the separate crate, material and next-item controls with one alternating Buy next button.
- One press now searches the native Auction House, checks the live total against the recommendation and confirms one commodity purchase.
- The button advances from crate to the complete material quantity only after the preceding purchase succeeds.
- Purchases with a live-price increase beyond the configured tolerance are cancelled and require a fresh press.

## 0.1.4 — 2026-11-12

- Kept Auctionator as the price source while moving purchasing searches to WoW's normal Buy/Browse Auctions interface.
- Opens the exact native result and supplies the requested quantity, such as one crate or twenty Silverleaf.
- Removed routine successful-search messages from chat; only errors and material price-change warnings remain.

## 0.1.3 — 2026-11-12

- Replaced the multi-row ranking table with one clear best-bundle recommendation card.
- Added separate exact Auctionator searches for the recommended crate and its required material quantity.
- Added a stateful next-item button that cycles crate, materials, crate without relying on auction winnings already being collected from the mailbox.
- Kept every auction purchase subject to the player's confirmation inside Auctionator.

## 0.1.2 — 2026-11-12

- Matched the mode controls more closely to Auctionator: grey and gold when inactive, gold-highlighted with white text when selected.
- Added a dark header band, gold column dividers and a header rule so Total and Per Favor read as separate fields.
- Widened and realigned the results table while preserving the crate/bundle column.
- Raised the optimiser above guide arrows and other world-overlay widgets so they cannot show through its panel.

## 0.1.1 — 2026-11-12

- Restyled the active purchase mode as a gold-highlighted Auctionator-style tab instead of disabling and greying it out.
- Split the results heading into aligned name, total-cost and cost-per-Favor columns.
- Preloaded crate and material item data so item names replace numeric fallbacks as soon as the client supplies them.

## 0.1.0 — 2026-11-12

- Added verified Apprentice, Journeyman and Expert Waylaid Crate rankings.
- Added full replacement-cost and cost-per-Favor calculations.
- Added verified coin-return deductions so rankings use net cost.
- Added crate-plus-materials, missing-materials and crate-only modes.
- Added bags and bank ownership checks.
- Added Auctionator price freshness, autoscan awareness and exact-search handoff.
- Added per-purchase re-pricing and material-change pause.
- Added dynamic placement beside Waylaid Crates or the Auction House.
- Excluded Artisan crates until exact Favor rewards can be verified.

