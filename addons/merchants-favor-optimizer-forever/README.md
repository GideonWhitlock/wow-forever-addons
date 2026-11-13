# Merchant's Favor Optimizer: Forever

An Auction House companion for World of Warcraft: Forever that ranks Waylaid Crates by the Auctionator market cost required for each point of Merchant's Favor.

## What it does

- Compares every verified Apprentice, Journeyman and Expert crate.
- Finds the cheapest valid alternative material bundle for each crate.
- Subtracts the crate turn-in coin reward and ranks the choices by net replacement cost per Favor.
- Offers three views: crate plus materials, missing materials for an owned crate, or crate only when its materials are already owned.
- Counts items in bags and the bank, and warns when banked materials must be withdrawn.
- Sits to the right of Waylaid Crates when its panel is open, otherwise to the right of the Auction House.
- Uses Auctionator's database and scan settings without changing them or starting a duplicate scan.
- Gives a clear, timed confirmation when Recalculate keeps the same best option or selects a new one.
- Uses Auctionator for prices, then presents one sequential guidance button that opens the exact item and quantity in WoW's native Buy page.
- You complete each purchase with WoW's own Buy button; after WoW confirms success, the optimiser advances from the crate to its matching material bundle.
- Advances from the crate to its required materials only after the preceding purchase succeeds.
- Never invokes WoW's protected purchase functions or attempts to press the native Buy button for you.

Artisan crates are displayed as unsupported data in the first build and are excluded from ranking until their precise Merchant's Favor rewards are verified.

## Requirements

- World of Warcraft: Forever
- Auctionator

[Waylaid Crates](https://www.curseforge.com/wow/addons/waylaid-crates) is optional. When installed, this panel positions itself beside it and uses the same underlying Forever crate catalogue independently.

## Commands

- `/mfo`
- `/merchantsfavor`

## Safety

The add-on never performs a purchase. Its single guidance button opens the displayed item and quantity in WoW's normal Buy page, where you review the live listing and press WoW's own Buy button. A genuine purchase-success event advances the sequence to the matching materials. The chosen bundle remains locked until that sequence is complete. The add-on does not alter Auctionator settings or start duplicate scans.

## Author

Gideon Whitlock

## Licence

MIT
