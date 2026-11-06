# Utility Helper: Forever changelog

## 0.1.32

- Successful Battle Shout and Commanding Shout casts now clear their combat
  reminder even when Forever makes the resulting aura secret.
- The reminder stays hidden for the normal two-minute shout duration before
  returning if no readable active aura is available.
- Missing-shout visibility and the fixed protected combat action are unchanged.

## 0.1.31

- Added every learned rank ID to mutually exclusive maintenance-buff families.
- Fixed active higher-rank Battle Shout and Commanding Shout auras being missed
  when restricted combat blocks enumeration and name lookup.
- Kept the missing-shout prompt and protected combat action behavior unchanged.

## 0.1.30

- Active Battle Shout and Commanding Shout prompts now clear through Forever's
  direct NeverSecret player-aura lookup when broad combat aura enumeration is
  restricted.
- A genuinely missing shout remains visible, including while Rage is low.
- The protected action remains fixed until combat ends; only its presentation
  is hidden after the buff is confirmed.

## 0.1.29

- Battle Shout and Commanding Shout clear their visible combat prompt as soon
  as either shout is confirmed active.
- The protected combat action remains fixed while the icon, border and tooltip
  are visually cleared.

## 0.1.28

- Missing warrior shouts now fail visible when Forever restricts broad combat
  aura information.

## 0.1.27

- Missing Battle Shout and Commanding Shout remain prompted during combat even
  while Rage is temporarily insufficient.

## 0.1.26

- Missing maintenance-buff prompts remain visible when only the global
  cooldown temporarily suppresses their cast.

## 0.1.25

- The client's explicit dead-pet error now overrides an incorrect Revive Pet
  usability result.

## 0.1.24

- A failed Call Pet that reports a dead pet switches the helper to Revive Pet
  and preserves the correction across reloads.

## 0.1.23

- Preserved a known dead-pet state across spirit-healer resurrection so Revive
  Pet wins when Forever temporarily reports both pet actions as usable.

## 0.1.22

- Fixed a living hunter pet that despawns after being left on Stay incorrectly
  showing Revive Pet.
- Call Pet now takes priority when the client reports both Call Pet and Revive
  Pet as usable.
- Call Pet is now shown as a clickable out-of-combat utility when the living
  pet is absent.
- Tokenless and distant dead pets continue to offer Revive Pet.

## 0.1.21

- Revive Pet now remains visible and clickable outside combat while the pet is
  dead instead of disappearing with the combat-only display.
- Its configured keybind follows the dead-pet state outside combat and remains
  preconfigured in combat.
- Living, absent and dismissed pets hide the outside-combat button and release
  its keybind.
- Preserves the distant-corpse and tokenless dead-pet fixes from 0.1.20.

## 0.1.20

- Fixed Revive Pet failing to appear for a distant pet corpse.
- Revive Pet now acts on the hunter's stored pet without a corpse range check
  or explicit dead-unit target.
- Added guarded handling for a revivable pet whose unit token disappears,
  while absent or dismissed pets remain suppressed.
- Re-audited bandage input: readable low health enables the outside-combat
  secure click and keybind; private health remains reminder-only to prevent an
  invisible click area above the threshold.

## 0.1.19

- Battle Shout and every supported learned maintenance buff can now appear and
  remain clickable during combat when its buff family is missing.
- Applying a maintenance buff clears its alert while preserving mutually
  exclusive families and spell-specific conditions.
- Bandages, profession tracking and Warlock stone creation remain restricted
  to outside combat.
- Fixed the return from arrange mode when combat interrupts editing.

## 0.1.18

- Added learned-only Life Tap for Warlocks. It appears when mana is at or below
  the configured mana threshold and health is above the configured health
  threshold.
- Added **Low mana + safe health** to the custom utility activation rules.
- Added **Find Spell ID**. Arm the picker, then click a recognized learned spell
  in the spellbook to fill the Extra spell ID field automatically.
- The picker uses temporary non-casting overlays and turns itself off after a
  spell is selected.

## 0.1.17

- Create Healthstone and Create Soulstone now appear outside combat only while
  the corresponding stone is missing from the Warlock's bags.
- Added a separate outside-combat Soulstone self-protection action. WoW presents
  the resurrection choice after death.
- Stone creation, self protection, selected-ally Soulstone use and low-health
  Healthstone use are individually configurable.
- Healthstone recovery continues to work for every class carrying a supported
  stone and uses the configured health threshold.
- Another Paladin's blessing suppresses its duplicate while leaving the
  character's other learned blessing choices available.

## 0.1.16

- Added clickable outside-combat reminders for learned self-buffs, including
  level 1 Warlock Demon Skin.
- Added maintenance families for Hunter aspects, Mage armors, Paladin auras,
  Shaman shields, Warlock armors and Warrior shouts.
- Mutually exclusive buffs appear together when none is active, then clear as a
  group after one is applied.

## 0.1.15

- Added Find Herbs, Find Minerals, Find Fish and Dwarf Find Treasure reminders.
- Characters with multiple learned resource trackers see all choices until one
  becomes active. Hunter creature tracking remains excluded.

## 0.1.14

- Current prepared release for WoW: Forever 1.60.1.
- Preserves the accepted contextual utility, recovery, dispel, interrupt, pet-care, layout and keybinding behaviour recorded by the project.
- Keeps the established private-value and secure-action limitations explicit.

Earlier version details remain in the project's verified build and release records and should be added here only when those records are reconciled for public publication.
