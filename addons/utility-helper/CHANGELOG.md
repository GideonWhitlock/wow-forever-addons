# Utility Helper: Forever changelog

## 0.1.26

- Fixed missing maintenance-buff prompts, including Battle Shout, sometimes
  failing to activate during the global cooldown.
- Genuine resource shortages are still respected, so Battle Shout waits until
  the warrior has enough Rage.
- Added focused coverage for GCD-only and insufficient-Rage states.

## 0.1.25

- The client’s explicit dead-pet error now overrides an incorrect Revive Pet
  usability result.
- Revive Pet remains available after that correction even if Forever continues
  reporting it as unavailable.

## 0.1.24

- A failed Call Pet that reports a dead pet now switches to Revive Pet and
  preserves the correction across reloads.

## 0.1.23

- Preserved a known dead-pet state across spirit-healer resurrection so Revive
  Pet wins when Forever temporarily reports both pet actions as usable.

## 0.1.22

- A living pet that despawns after being left on Stay now offers Call Pet
  instead of Revive Pet.

## 0.1.21

- Revive Pet now remains visible, clickable and bindable outside combat while
  the pet is dead, while retaining its fixed combat action.

## 0.1.20

- Revive Pet no longer applies an inappropriate range check or dead-pet target
  token, allowing it to work for a distant corpse.

## 0.1.19

- Battle Shout and other learned maintenance buffs now retain fixed secure
  buttons and can prompt when missing during combat.

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
