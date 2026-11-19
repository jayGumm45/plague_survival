# Plague Survival

A first-person 3D survival-mystery built in Godot 4.7. You wake up infected
with the plague in your own village. You have **3 days** before the
infection kills you. Somewhere in the village a physician is secretly
treating the sick — find out who they are, confront them, and get the
antidote before time runs out.

## Controls

| Action | Key |
|---|---|
| Move | `W A S D` |
| Sprint | `Shift` |
| Jump | `Space` |
| Look | Mouse |
| Interact / talk | `E` |
| Journal | `J` |
| Close menu | `Esc` |

## Running it

Open the project in Godot 4.7+ and press Play — `Village.tscn` is the main
scene. There's nothing to build; it's pure GDScript + built-in nodes.

## How the mystery works

Five villagers live in the plaza: **Father Aldric** (priest), **Mira**
(herbalist), **Old Tomas** (gravedigger), **Beatrice** (baker), and
**Edgar** (apothecary). Exactly one of them is the undercover plague
doctor — talk to everyone, pick up the hidden documents scattered around
their homes and the well, and build up suspicion. Any conversation lets
you "accuse" that villager; accusing the real doctor hands you the
antidote and ends the game. Accusing the wrong person just gets a denial
— there's no penalty, so experiment freely. The village is built so the
clues point toward Edgar, but nothing stops you from changing who the
doctor is (see below).

The countdown is also the infection meter: a 3-day clock (24 real minutes
by default) that tints the screen red as it climbs. Hit 100% before
you're cured and you lose.

## Architecture

```
scripts/
  autoload/
    game_manager.gd      # the 3-day clock, infection %, win/lose state
    journal_manager.gd   # clue database + per-suspect suspicion score
  data/
    dialogue_database.gd # every NPC's branching dialogue tree (static data)
  player/player.gd       # FPS movement, mouse look, interact raycast
  npc/npc.gd              # talks to the player, opens its dialogue tree
  interactables/clue_item.gd # a hidden document you can pick up once
  ui/                     # HUD, journal panel, dialogue panel, end screen

scenes/
  levels/Village.tscn     # the main scene: blockout village + NPCs + clues
  player/Player.tscn
  npc/NPC.tscn
  interactables/ClueItem.tscn
  ui/UIManager.tscn       # autoloaded; owns the whole persistent UI layer
```

Three autoloads drive everything:
- **GameManager** — the clock and win/lose state. Nothing else owns time.
- **JournalManager** — the single source of truth for which clues have
  been found and how suspicious each villager looks. It's pure data; it
  doesn't know who the "real" doctor is.
- **UIManager** — a scene-based autoload that owns the HUD, journal,
  dialogue box, and end screen, and is the one object any NPC or item
  talks to (`UIManager.start_dialogue(...)`, `UIManager.set_interact_prompt(...)`).

The "who is the doctor" answer lives nowhere but the level itself: every
NPC has an `is_doctor` export, and exactly one instance in `Village.tscn`
(Edgar) has it checked. Accusing an NPC always succeeds if and only if
that flag is true — clues only ever *guide* the player, they never gate
the actual win condition, so the mystery can't be soft-locked.

Dialogue is plain nested `Dictionary` data in `DialogueDatabase`, not a
custom `Resource`/`.tres` pipeline — easy to hand-edit, no editor setup
required, and choices can be gated behind `requires_clue` or
`requires_min_suspicion` for simple multi-step reveals (see Tomas's or
Edgar's trees).

## Extending it

- **Add a clue**: add an entry to `CLUE_DB` in `journal_manager.gd`
  (title, flavour text, and which suspects it should make more/less
  suspicious), then either drop a `ClueItem.tscn` instance in the level
  with that `clue_id`, or add a `give_clue` choice to a dialogue node in
  `dialogue_database.gd`.
- **Add an NPC**: instance `NPC.tscn` in `Village.tscn`, set `npc_id`,
  `display_name`, and (optionally) `is_doctor`, then add a matching tree
  to `DialogueDatabase._TREES`.
- **Change who the doctor is**: flip `is_doctor` on a different NPC
  instance in `Village.tscn`. The suspicion weights in `journal_manager.gd`
  are just narrative hinting and don't need to match for the game to work,
  though you'll want to rewrite the clue text so it still makes sense.
- **Tune pacing**: `GameManager.SECONDS_PER_DAY` is the one constant that
  controls how long a full playthrough takes.

## Current state / good next steps

This is a working vertical slice — a full loop from spawn to investigation
to accusation to win/lose, verified to load and run error-free in Godot
4.7.2 headless. It's deliberately a blockout: buildings are plain colored
boxes, NPCs are capsules, and the UI is laid out functionally rather than
styled. Natural next steps, roughly in order of impact:

1. Replace the CSG blockout with real building/NPC models (or at least
   textures) and dress up the UI theme.
2. Give NPCs idle animations/wandering so the village feels alive.
3. Add ambient audio (wind, distant coughing, a bell) and simple SFX for
   picking up a clue / opening the journal.
4. A short intro beat (title card, or a scripted "you collapse, three days
   left" moment) before control hands over.
5. Optional: a hint system in the journal once suspicion crosses a
   threshold, for players who get stuck.
