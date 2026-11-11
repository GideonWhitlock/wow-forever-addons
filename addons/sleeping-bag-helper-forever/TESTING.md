# Testing checklist

## Static checks

- TOC interface is 16001 and version is 0.1.5.
- The Cozy Sleeping Bag item is 211527 and the known `Unroll Bag` spell is 429961.
- The solo and party messages are shorter than WoW's 255-character limit.
- Only ordinary player spellcast events are observed.
- The add-on does not call protected chat, item-use or raid-marker functions.
- The database accepts only boolean values for saved toggles.

## Accepted in-game evidence

- `/sbf test` showed the ordinary **Prepare Sleeping Bag Message** button while grouped.
- Clicking the button opened chat with the party instruction prepared.
- Pressing Enter sent: `Sleeping bag is down: stand on it and stay still. The XP buff gains 1% each minute, stacking up to 3%.`
- No automatic chat or protected-action call is used by that tested path.

## Remaining live edge cases

- Confirm that an actual Cozy Sleeping Bag cast shows the preparation button on the current Forever build.
- Confirm the 30-second duplicate guard prevents start, sent and success events from showing more than one button.
- Confirm a solo cast prepares `/say` rather than `/party`.
- The optional marker and sound settings are retained for compatibility, but automatic raid-marker behaviour remains disabled because Forever treats it as protected.
