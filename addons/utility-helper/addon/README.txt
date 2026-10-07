# Utility Helper: Forever

Version **0.1.20** for **WoW: Forever beta 1.60.1**, interface **16001**.

**Revive Pet now works for a distant pet corpse.** The helper no longer treats
Revive Pet as a ranged cast against the corpse or explicitly targets a dead pet
unit. If Forever temporarily removes the pet unit token, public Revive Pet
usability can still identify a revivable pet without confusing a dismissed or
absent pet with a dead one.

Bandages remain clickable outside combat when the client exposes readable
health and confirms the character is at or below the health threshold. On the
current private-health path, the low-health icon remains a display-only reminder:
the API can draw it but cannot safely enable its secure click without also
creating an invisible click area above the threshold.

**Maintenance buffs now remain available during combat when missing.** This
includes Battle Shout and every supported learned self-buff. The fixed secure
button is prepared before combat, so a missing buff can light up and be clicked
without a reload. Applying the buff clears its alert. Bandages, profession
tracking and Warlock stone creation remain outside-combat utilities.

**Life Tap** is now a built-in Warlock utility. It highlights when mana is at
or below the configured mana threshold and health is above the configured
health threshold—50% for both by default. Its own cooldown, usability and
current cast checks still apply.

Custom utilities no longer require manually researching a spell ID. Select
**Find Spell ID**, open the spellbook, then hover and click a learned spell;
the picker fills the spell ID and turns itself off. If a spellbook layout cannot
be covered directly, hovering the spell and selecting the finder button again
uses the last hovered spell. The new **Low mana + safe health** custom rule uses
the same health and mana sliders, which makes the Life Tap condition available
for other learned abilities as well.

Warlocks now receive clickable outside-combat reminders to create a Healthstone
or Soulstone only when that stone is missing from their bags. A separate
**Soulstone (self)** button appears outside combat when a Soulstone is available
and the Warlock does not already have Soulstone resurrection protection. After
death, WoW itself presents the resurrection choice. Creation, self-protection,
targeted Soulstone use and low-health Healthstone use are separate entries that
can each be enabled or disabled in `/uh`.

Paladin blessing maintenance distinguishes who applied a blessing. A blessing
from another Paladin suppresses the duplicate of that same blessing, while the
Paladin's other learned blessing choices remain available. Once the Paladin
applies one of their own mutually exclusive blessings, the alternative personal
blessing reminders clear.

Learned maintenance buffs appear as clickable self-buff reminders whenever
their buff family is missing, including during combat. This includes level 1
**Demon Skin**, Priest protections, Druid
buffs, Mage intellect and armor families, Paladin blessings and auras, Hunter
aspects, Shaman shields, Warlock armor families and Warrior shouts. Friendly
player/pet buff buttons remain separate. For mutually exclusive families, every
learned choice appears while none is active; applying one clears the alternatives.

Learned resource-tracking abilities now appear outside combat whenever no
supported resource tracker is active: **Find Herbs**, **Find Minerals**, **Find
Fish** and the Dwarf racial **Find Treasure**. Characters with more than one see
all available choices together. Activating any one removes the whole choice
group until resource tracking is turned off again. Hunter creature-tracking
abilities are deliberately excluded.

Rogue abilities that require stealth—Sap, Cheap Shot and Pick Pocket—have been
removed. Their alerts only became available after entering stealth and then
vanished as stealth broke, which made them unsuitable for this helper.

The in-game title is now **Utility Helper: Forever**. The add-on folder and
saved-settings name remain `UtilityHelper`, preserving existing installations
and character settings.

New characters now start with **Inactive visibility at 0%**, so inactive utility
artwork is hidden until an ability becomes relevant. Existing saved visibility
choices remain unchanged after updating.

Power Word: Shield can now alert for a low-health ally with an existing shield
when Weakened Soul is confirmed absent. Unreadable blocking debuffs no longer
produce a confirmed-ready alert; this also applies to Forbearance.

**Bandages appear only
outside combat, at or below your health alert threshold (50% by default).** Above
that threshold, the icon, label and border are invisible at every inactive-visibility
setting. Recently Bandaged, casting/channeling, cooldowns and unusable items still
suppress the alert. Arrangement can reveal a disabled preview.

**Forever limitation:** health is private even outside combat. The low-health
bandage icon is therefore a **reminder**, with no mouse input, hover tooltip or
addon keybind. Use the bandage from your normal action bar. This avoids an invisible
click area. If a client supplies readable health, the icon can instead become
clickable only when low health is confirmed. The fully clickable, automatically
health-gated behavior is not available on the current beta.

New fixed self-heal buttons include priest Lesser Heal/Heal/Greater Heal/Flash
Heal, druid Healing Touch/Regrowth, paladin Holy Light/Flash of Light and shaman
Healing Wave/Lesser Healing Wave. Only learned spells appear. They use the same
health threshold and remain available during combat under the existing input rule.
Existing instant heals, healing potions and healthstones remain separate.

Friendly buff coverage also expands, with selected living player/pet checks,
equivalent-buff suppression, greater blessings and a warlock Soulstone item slot.
Hunter Revive Pet can alert in combat for your own dead pet. Ordinary resurrection
still needs your normal action bar outside combat. Bandage reminders also use
that action bar; the addon shows when they are relevant.

The client's **animated proc border** gives a gold activation flare
followed by a moving, sparkling outline. Open `/uh` and **Arrange buttons** to
preview it. Turn off **Animated proc border** for the static gold outline.
The effect scales with button size and stops when the alert or bar closes.
Clients missing the native proc template retain the earlier pulsing border.

**Global cooldowns no longer make relevant utility buttons disappear.** The
native cooldown swipe can still show the brief wait; an ability's own cooldown
and an existing cast/channel of that ability still suppress its alert.
The prior fix for ready Scare Beast at 0% inactive visibility was confirmed
working by the user. This version preserves that fix.
`/uh why` prints each button's most recent combat check if an alert is missing.

**Combat utilities, with maintenance buffs also available when missing:** the ordinary bar is hidden outside combat, its buttons
are disabled and its keybinds are released. Entering combat enables the fixed
buttons and their assigned keys through the game's secure state driver. Leaving
combat disables them again. Arrange mode reveals a preview that cannot cast.
The separate outside-combat group provides resource trackers, stone creation
and the low-health bandage reminder. The minimap button and settings remain available outside combat.

An ability's own cooldown and an existing cast/channel suppress
activation alerts. Mend Pet and Health Funnel cannot restart their own channel
through these buttons. Scare Beast is not suggested while its debuff is already
on the target. Restricted readiness produces `?`, never a confirmed ready alert.

**Inactive visibility %** ranges from **0% invisible** to **100%
fully visible**, and a **Compact grid** layout. Active abilities still appear
at full brightness with a gold border. The grid keeps every ability in its own
clickable position. Recovery icons now match the selected item, and the empty
mana slot uses a blue mana potion icon.

Invisible inactive buttons no longer display hover tooltips. Visible inactive
icons and active alerts still have tooltips, which update if an alert activates
or ends while the pointer stays in place. Restricted health/mana/cast results
control tooltip opacity directly, just as they control the icon's display.

It includes the previous event-compatibility and recursive-startup fixes.
`/uh status` lists skipped events and rebuild/refresh counts.

Utility Helper puts class utilities within reach: separate clickable buttons,
separate keybinds, simultaneous activation borders, movable icons and adjustable
sizes. Healing starts at **50% health**, mana recovery at **50% mana**, and pet
care at **50% pet health**, all adjustable.

**Validation:** Lua syntax and mocked scenarios are tested. This build has not
been exercised inside WoW. Spell IDs are resolved against the character's actual
spellbook; beta changes, secure clicks, pet abilities and visual curves require
in-game verification. This is an initial test build, not a promise of every
possible utility spell or encounter mechanic.

## Install and use

1. Extract `UtilityHelper` into your Forever installation's
   `_classic_beta_/Interface/AddOns/` folder. `UtilityHelper.toc` must be directly
   inside `AddOns/UtilityHelper/`.
2. Enable **Utility Helper: Forever** in the character-selection AddOns list, then log in.
3. Type **`/uh`** or left-click its gear minimap icon for settings. Right-click the
   gear to arrange the utility buttons. Drag the gear to move it around the
   minimap; its position is saved for this character. It appears independently
   of the main bar's startup and defaults away from Feed Pet's minimap position.
4. Use **Arrange buttons**, drag the bar or individual icons, and use the wheel
   or size slider. In **Compact grid**, dragging any icon moves the whole grid.
   Click the layout button to select **Free layout** for individual placement
   and adjustable columns. Prior free-layout positions are preserved.
   Select Arrange again, close settings, or use `/uh lock` to finish. Mouse
   spell clicks and utility keybinds are disabled while arranging.
5. Click **Bind key** next to an ability and press a key, with optional Ctrl,
   Shift or Alt. Escape cancels; Delete clears. A conflicting game binding
   requires pressing **Replace**. Clearing the utility binding restores the
   underlying game binding.
6. Set **Inactive visibility %** to your preference. **0** completely hides
   inactive artwork during combat, including labels and cooldowns; **100** leaves
   it fully visible during combat. Active abilities appear with the gold border.
   Arrange mode temporarily reveals all icons. New characters default to 0%; an
   existing saved visibility choice is preserved. Compact grid is selected by default.

After updating an already running game, use **`/reload`** to load the new files.
Settings and bindings are saved per character. There are no default keybinds.
You choose whether to use an ability; nothing is cast automatically.

## How the display works in Forever

WoW restricts changes to protected clickable buttons during combat. Utility
Helper creates one fixed button for each enabled learned utility. The button's
spell, recipient rule, keybind and position remain stable through a fight.
The secure combat state driver enables input and installs utility keybinds on
combat entry, and disables input and releases those keys on combat exit. The bar
is hidden outside combat at every opacity setting. The separate outside-combat group
shows missing learned self-buffs and resource trackers when none is active, while the bandage reminder
appears only below the health threshold outside combat. On private health its
clicks, hover input and addon keybind are disabled at all times.
Other normal game keybinds are available again outside combat. Use your normal action bar for utilities needed
outside combat, such as calling or reviving a pet and ordinary resurrection.
Several buttons can brighten with animated proc outlines at the same time. Buttons return to a
chosen inactive visibility when their trigger is absent. They do not pack into
"first suggestion/second suggestion" slots or change what a key does.

This differs from Feed Pet's out-of-combat-only button: it cannot safely use
arbitrary health/cast/debuff checks to show, hide, retarget or reassign secure
actions during combat. At 0% inactive visibility DURING combat, the fixed click
areas and keybinds remain usable even though the artwork is invisible. Outside
combat, ordinary utility buttons and their input are disabled, regardless of opacity.
Self-buffs, resource trackers and the bandage reminder disappear during combat. On a client with readable
health, its button can accept input only when low health is confirmed outside combat.

- **Bright gold border:** a relevant scenario, subject to range, resources,
  forms, reagents and cooldown data the game exposes.
- **Inactive combat button:** manual access at the chosen visibility, including 0%.
- **`?`:** the client withheld enough information to prevent a reliable
  contextual decision. The button remains available for manual use.
- **Health/mana threshold display:** where values are secret, native display
  curves feed the icon and border opacity directly. Lua does not read or compare
  these values. Interruptibility can similarly feed a native visual boolean.
- **Ability cooldown or ongoing cast/channel:** the activation alert is suppressed.
  A global cooldown alone keeps a relevant utility highlighted.
  The native cooldown swipe remains available on visible combat buttons. If
  readiness is restricted, `?` replaces the ready alert. A fixed combat button
  still exists; the game enforces cooldowns. Mend Pet/Health Funnel also have a
  native macro guard against restarting their own ongoing channel.

The ordinary bar hides and input is disabled via Blizzard's secure state driver when outside
combat, dead, mounted, flying or
using vehicle UI. Layout changes, new ranks, changed pets and bag selection are
applied outside combat. Reloading in combat defers construction until combat ends.

## Recipients and multiple buttons

Enemy utility acts on your **current target**. General friendly healing and dispels
use your **selected living ally**, or **you** when the current target is not a living
ally. New buttons labelled **(self)** and bandages always target **you**. Targeted
buffs require a **selected living friendly player or pet**, without a self fallback.
The condition and the click use the same recipient rule. Pet healing and Revive
Pet target your **own pet**. Resurrection targets a **selected dead friendly player**,
excluding ghosts. A Soulstone protects a living player before death; it is not a
corpse or pet resurrection button.
No click automatically searches a raid and chooses a recipient.

Enable **Extra party dispel buttons** for separate fixed `party1` through
`party4` recipients. They are labelled P1–P4, with their own keybinds. Select a
raid member for the ordinary friendly button, or add fixed raid-recipient rules
with the advanced command below. Group changes can change the person occupying
a party/raid slot, as with standard unit frames.

For example, a hunter targeting a beast can have **Scare Beast**, **Mend Pet**,
**Healing potion** and **Healthstone** highlighted together if the corresponding
conditions are present. Druid forms are checked using the game's reported
creature type, not by assuming every druid is always a beast.

## Included utility families

| Class | Examples |
|---|---|
| Druid | Rejuvenation, Swiftmend, Innervate, curse/poison removal, Hibernate, Roots, Bash/Feral Charge, Barkskin, Rebirth |
| Hunter | Scare Beast, Mend/Revive/Call Pet, Tranquilizing Shot, traps, Scatter/Wyvern/Concussive Shot, Feign Death, Deterrence |
| Mage | Counterspell, curse removal, Polymorph, Evocation, Ice Barrier/Block, Blink, Slow Fall, maintenance buffs |
| Paladin | Purify/Cleanse, Lay on Hands, friendly-only Holy Shock, Hammer of Justice, Repentance, protection/freedom, Redemption |
| Priest | Magic/disease removal, enemy Dispel Magic, Renew, Shield, Desperate Prayer, Silence, Shackle, Fear Ward, Levitate, Resurrection |
| Rogue | Kick, Blind, Gouge, Kidney Shot, Evasion, Vanish, Sprint |
| Shaman | Available interrupt, Purge, poison/disease removal, recovery and utility totems, water utility, Ancestral Spirit |
| Warlock | Health Funnel, Fear/Banish/Enslave, active pet's Spell Lock/Devour Magic/Seduction/Sacrifice, Unending Breath |
| Warrior | Pummel/Shield Bash, Disarm, Intimidating Shout, Shield Wall, Last Stand, Berserker Rage |
| Shared | Learned racial utilities, classic healing/mana potions, healthstones and out-of-combat self-bandaging |

Only learned player or current pet spells appear. Highest learned ranks are
resolved by localized spell-family name. Talents/racials that are absent are
not shown. Upgraded cleanses replace the narrower spell where configured.

Damage rotations, damage cooldowns, damaging curses and ordinary direct damage
spells are excluded. **Utility with incidental damage** defaults on so spells
such as Kick, Pummel, Earth Shock and Roots can fulfil their utility role; turn
it off for a stricter catalogue. Holy Shock is locked to friendly healing.
Preparation abilities such as Nature's Swiftness do not heal by themselves.
Mana Tide/Evocation restore mana; Inner Focus reduces the cost of a later action.

Broad tools such as traps and area fears are offered as combat options. The
add-on cannot know whether using them is tactically wise. Freedom, escape tools,
some buffs and other hard-to-detect situations have explicit manual buttons.
Creature type is not proof of vulnerability: boss immunity, diminishing returns,
line of sight, facing and encounter mechanics can still prevent an action.
Health Funnel consumes your health; Sacrifice consumes the Voidwalker.

## Recovery items

Each recovery family chooses the strongest eligible classic item present in
bags while outside combat. The selected item remains bound during combat. If
it runs out, the button returns to inactive visibility; the next eligible item is selected after combat.
Healing potion and healthstone have separate buttons. Shared cooldowns are
respected when readable. Empty item slots keep their position at inactive visibility.
Both the action button and settings list use the selected item's icon.
Bandages have a separate self-use alert, from Linen through Heavy Runecloth.
Selection skips a stronger tier if the game says you cannot use it. Combat,
Recently Bandaged and an active cast/channel hide and disable the button and
release its assigned key. Both the icon and border follow the health threshold,
even if inactive visibility is 100%. When health is private, the icon is labelled
Reminder and accepts no clicks, hover or addon keybind; use your normal action bar.
With readable health it is clickable only at or below the threshold. Unknown
usability, aura/cast information or failed display evaluation never enables a
bandage button. No bandage is used automatically.

The included list covers the standard classic potion/healthstone/bandage tiers; newly
introduced Forever consumables need a catalogue update.

## Extra utilities and commands

The settings panel can add a learned spell by ID, a rule and a fixed recipient.
Custom dispel/purge rules default to Magic. Advanced examples:

```text
/uh add 527 dispel raid1 Magic
/uh add 2782 dispel focus Curse
/uh add 2139 interrupt focus
/uh remove 2139
```

`remove` removes only custom entries with that base ID. Disabling an ability's
checkbox preserves its position/keybind for later re-enabling. The list contains
all currently applicable enabled and disabled entries. Category toggles can
hide manual tools or incidental-damage utilities; their settings are preserved.

```text
/uh                     Settings
/uh unlock              Arrange buttons
/uh lock                Finish arranging
/uh size 52             Button size, 28–100
/uh idle 0              Inactive visibility, 0–100 percent
/uh health 50           Health threshold, 5–95
/uh mana 50             Mana threshold, 5–95
/uh pethealth 50        Pet threshold, 5–95
/uh list                Current button numbers and bindings
/uh bind 1 CTRL-F       Bind the currently listed button 1
/uh bind 1 F replace    Explicitly override a conflicting game key
/uh unbind 1            Clear that utility binding
/uh hide 1              Disable that button
/uh restore             Restore disabled abilities
/uh enable              Enable the bar and its bindings
/uh disable             Disable the bar and its bindings
/uh status              Build and native display capability information
/uh why [number]        Most recent combat check and reason for each/one button
```

Button numbers are for configuration only and can change when learning spells.
Saved keybinds and positions are attached to the spell's stable identity.

See `TEST_REPORT.txt` for automated checks and the remaining in-game checklist,
and `API_REFERENCES.txt` for the exact client/API sources used.
