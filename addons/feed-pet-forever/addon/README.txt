FEED PET: FOREVER - 1.0.2
For WoW: Forever 1.60.1 (interface 16001), hunter characters.

GET STARTED
Extract the ZIP into your Forever client's Interface\AddOns folder.
The resulting file must be Interface\AddOns\FeedPetForever\FeedPetForever.toc.
Restart WoW fully if it was running when this new addon was installed.
Enable "Feed Pet: Forever" in the character selection AddOns list.

WHAT IT DOES
A 64-pixel Feed Pet spell icon starts in the centre of the screen.
It gently flashes when your pet is unhappy OR content (not fully happy).
Left-click once to feed an item selected from your carried bags.
The tooltip names the chosen food. A small count shows suitable available food.

The addon asks Forever's own CanPetEatItem API which foods the current pet
accepts. It chooses the highest item-level accepted food, then the smaller
stack on a tie. It can use cooked, raw or buff food if the client accepts it;
there is no personal-food reserve. It does not use bank or warband-bank items.
It rechecks the bag slots at click time so sorting or moving food is handled.

When no suitable food is available, the feeding button becomes a red,
crossed-out food icon labelled NO FOOD. It cannot cast or consume anything.
Hover it to see your pet's diet. You can disable this warning in settings.
It waits for uncached or temporarily locked items instead of declaring no food.

Both alerts are hidden when:
- The pet is happy, absent, dead, or not a hunter pet.
- You or the pet are in combat.
- You are dead or a ghost, on a flight path (griffin/wyvern), mounted or in a vehicle.
- Feed Pet has not been learned, or it is on cooldown.
- The Feed Pet Effect is already active on the pet.
- Required pet information is unavailable.

The addon only feeds in response to a real left-click. The secure spell button
casts Feed Pet and targets its selected bag slot. It does not run a background
feeding macro or repeatedly use items. Normal game range and spell rules apply.

MOVE AND RESIZE
Minimap left-click   Open settings, even when the feeding alert is hidden.
Minimap right-click  Toggle the nonfeeding layout preview.
Minimap drag         Reposition its button around the edge of the minimap.
/fpf              Open the small settings window.
Right-click icon  Open settings when the icon is visible.
Shift-drag        Move the icon while an alert is visible.
Shift-mousewheel  Resize while an alert is visible.
/fpf unlock       Show a nonfeeding preview; drag to move, wheel to resize.
/fpf lock         Finish the preview and restore normal alert conditions.
/fpf size 80      Set size in UI units (24 to 160; default 64).
/fpf reset        Return to the centre and reset size to 64.
/fpf test nofood  Preview the no-food appearance; /fpf lock to finish.
/fpf nofood off   Hide the no-food warning ("on" enables it).
/fpf flash off    Use a steady icon ("on" enables flashing).
/fpf minimap off  Hide the minimap button ("on" restores it).
/fpf status       Print addon/client versions and current alert/food information.

Layout preview deliberately shows the icon even when feeding is not needed.
Feeding is disabled during preview or Shift-dragging. Close the settings window,
click Done, or type /fpf lock to finish. Combat also exits preview mode.
Position, size, no-food preference and flashing preference save per character.
The minimap button position and visibility also save per character.
Settings cannot be changed in combat. Preview never persists through reloads.

VALIDATION
This version received a static compatibility review for 1.60.1 build 70170.
Automated Lua 5.1 behavior tests passed. Feeding behavior is unchanged from
the owner-accepted 1.0.0 release; this update corrects the displayed title only.
See TEST_NOTES.txt for a short checklist. No third-party addon is required.
