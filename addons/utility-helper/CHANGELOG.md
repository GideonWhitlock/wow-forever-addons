# Utility Helper: Forever changelog

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
