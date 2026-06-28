# 9-tactical_mission_design.md
# Blacksite Command — Tactical Mission Design
> Author: Development Team
> Status: Submitted for client review at Week 10 Milestone
> Scope: Phase 1 (hand-crafted map) + Phase 2 foundations (procedural system)
> Reference games: XCOM 2 (tile movement), Shadow Tactics (stealth cone), Commandos 2 (objective-based)

---

## 1. OVERVIEW

The tactical layer is a **turn-based tile movement system** in a 3D isometric view. Small squads (2–8 operatives) are deployed on hand-crafted or procedurally assembled maps. Each mission has a primary objective and an extraction point. Success requires completing the objective and extracting at least one operative alive.

The tactical layer is a **separate scene** from the base. Transition is handled by `GameState` + `CameraManager`. Base state is preserved during missions — time does not pass in the base while a mission is active.

---

## 2. CORE MECHANICS

### 2.1 Turn Structure

The game uses **initiative-based turns**, not player-then-enemy alternation:

```
TURN ORDER:
1. Player activates one operative (click to select)
2. Operative has 2 Action Points (AP) per turn
3. Player spends AP on actions (move, attack, ability, interact)
4. When operative has 0 AP remaining, player selects next operative
5. When ALL player operatives have 0 AP → Enemy Phase begins
6. All enemies execute their AI behavior sequentially
7. Enemy Phase ends → new player turn begins, all AP refill
```

**AP costs:**

| Action | AP Cost | Notes |
|--------|---------|-------|
| Move 1 tile | 1 AP | Diagonal = 1 AP (counted as 1 tile) |
| Move 2 tiles | 2 AP | Max movement per turn without abilities |
| Attack (ranged) | 2 AP | Full action — ends turn |
| Attack (melee) | 1 AP | Can follow with 1-tile move |
| Use ability | 1–2 AP | Varies per ability |
| Interact (terminal, door, loot) | 1 AP | Must be adjacent |
| Take cover | 0 AP | Passive — automatic when entering cover tile |
| End turn manually | 0 AP | Wastes remaining AP |

### 2.2 Movement

- Operatives move on a **tile grid** (same 4m × 4m tile size as base)
- Click a highlighted tile to move — valid tiles shown on selection
- Movement range = 2 tiles per AP spent (with default Move stat)
- High Stealth operatives gain +1 movement range when crouching
- Tiles have **movement cost modifiers**:

| Tile Type | Move Cost | Notes |
|-----------|-----------|-------|
| Open floor | 1 | Default |
| Crouch/Cover | 1 | Also grants defense bonus |
| Rubble / Debris | 2 | Slows movement |
| Vent / Crawlspace | 2 | Stealth bonus while inside |
| Door (open) | 1 | Free to pass |
| Door (closed) | 1 AP to open | Uses Interact action |
| Locked door | 1 AP + Tech check | Requires keycard or Tech ≥ 5 |
| Ladder / Stairs | 1 | Changes floor level |

### 2.3 Cover System

Cover is **tile-based**, not directional. Any tile marked as cover grants:
- **Half Cover:** -25% chance to be hit (low barriers, crates, desks)
- **Full Cover:** -50% chance to be hit (walls, pillars, vehicles)
- Cover is destroyed if the object takes enough damage (Phase 2 feature)

```
COVER TILES IN PHASE 1 MAP:
[C] = Half cover (crates, desks)
[F] = Full cover (walls, pillars)
```

### 2.4 Line of Sight (LoS)

- LoS calculated from center of operative tile to center of target tile
- Walls and Full Cover tiles block LoS completely
- Half Cover tiles do not block LoS (you can shoot over/around them)
- LoS is **mutual** — if you can see them, they can see you
- LoS calculated using Godot's `PhysicsRayQueryParameters3D` against collision layer `"los_blockers"`

```gdscript
# LoSSystem.gd
func has_line_of_sight(from_tile: Vector2i, to_tile: Vector2i) -> bool:
    var from_pos = TacticalMap.tile_to_world(from_tile) + Vector3(0, 1.0, 0)
    var to_pos = TacticalMap.tile_to_world(to_tile) + Vector3(0, 1.0, 0)
    var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
    query.collision_mask = 0b0010  # layer 2 = los_blockers
    var result = get_tree().root.get_world_3d().direct_space_state.intersect_ray(query)
    return result.is_empty()
```

---

## 3. STEALTH SYSTEM

### 3.1 Detection Model

Each enemy has a **detection cone** (vision) and a **noise radius** (hearing). Detection is not instant — it builds up via an **Alert Meter**.

```
ENEMY DETECTION:
┌─────────────────────────────────────────┐
│           [Enemy]                        │
│              │                           │
│    ←─────────┼─────────→  Noise Radius  │
│              │            (circle)       │
│           ╱╲  ╲                          │
│          ╱    ╲ Vision Cone             │
│         ╱      ╲  (forward arc)         │
│        ╱────────╲                        │
└─────────────────────────────────────────┘

Vision Cone:
  - Angle: 90° (45° each side of facing direction)
  - Range: 6 tiles (default), 4 at night/low light
  - Blocked by walls and Full Cover tiles

Noise Radius:
  - Walking: 2 tiles
  - Running (sprint, Phase 2): 4 tiles
  - Combat: 8 tiles (gunfire alert — all enemies on map alerted)
  - Takedown (melee): 1 tile (very quiet)
```

### 3.2 Alert Meter

Each enemy has an **Alert Meter** (0–100). It does not trigger detection instantly:

| Meter Range | State | Enemy Behavior |
|-------------|-------|----------------|
| 0–30 | **Unaware** | Follows patrol route |
| 31–60 | **Suspicious** | Stops, looks toward source, meter climbs slowly |
| 61–90 | **Alerted** | Moves toward last known position, calls for backup |
| 91–100 | **Combat** | Full combat AI, calls all nearby enemies |

**Meter fills when:**
- Operative is in vision cone: +15/turn
- Operative moves in noise radius: +8 (walking), +20 (running)
- Body of downed ally found: +40 instantly
- Gunshot heard: +60 instantly (all enemies in 8-tile radius)

**Meter drains when:**
- Source of suspicion removed from cone/radius: -5/turn
- Enemy returns to patrol route: -10/turn
- Operative in vent/crawlspace: halved fill rate

**Phase 1 simplification:** Enemies have no patrol routes in Phase 1. They are **static guards** facing a fixed direction. Alert Meter still functions — if an operative walks into their cone, the meter fills. This is enough to validate the stealth model.

### 3.3 Noise Sources

```gdscript
# NoiseSystem.gd
enum NoiseType { FOOTSTEP, GUNSHOT, TAKEDOWN, EXPLOSION, DOOR }

var noise_radii = {
    NoiseType.FOOTSTEP: 2,
    NoiseType.GUNSHOT: 8,
    NoiseType.TAKEDOWN: 1,
    NoiseType.EXPLOSION: 12,
    NoiseType.DOOR: 3
}

func emit_noise(source_tile: Vector2i, type: NoiseType):
    var radius = noise_radii[type]
    for enemy in EnemyManager.get_all_enemies():
        var dist = source_tile.distance_to(enemy.tile)
        if dist <= radius:
            enemy.alert_meter += _get_alert_value(type, dist)
```

---

## 4. COMBAT SYSTEM

### 4.1 Hit Chance Formula

```
HIT_CHANCE = BASE_ACCURACY + OPERATIVE_COMBAT_BONUS - COVER_PENALTY - RANGE_PENALTY

BASE_ACCURACY = 65%
OPERATIVE_COMBAT_BONUS = (Combat stat - 5) * 5%   # e.g. Combat 8 = +15%
COVER_PENALTY = 25% (half cover) or 50% (full cover)
RANGE_PENALTY = -5% per tile beyond optimal range

OPTIMAL RANGE by weapon:
  Pistol: 3 tiles
  SMG: 4 tiles
  Rifle: 6 tiles
  Sniper: 10 tiles
  Shotgun: 2 tiles (but hits adjacent tiles too)
  Taser: 2 tiles (non-lethal, stuns for 2 turns)
  Knife/Baton: 1 tile (melee, no range penalty)
```

### 4.2 Damage

```
DAMAGE = WEAPON_BASE + RANDOM_VARIANCE - ARMOR_REDUCTION

Weapon base damage (Phase 1 — pistol and rifle only):
  Pistol: 20-30 damage
  Rifle:  35-50 damage

RANDOM_VARIANCE = ±10% of base
ARMOR_REDUCTION = 0 in Phase 1 (armor system Phase 2)
```

### 4.3 Flanking (Phase 2 only)

Not implemented in Phase 1. Flagged here for Phase 2 design:
- Attacking from opposite side of cover removes cover bonus
- Attacking from behind grants +20% hit chance

### 4.4 Death and Wounding

| HP | State | Effect |
|----|-------|--------|
| 100–31 | **Active** | Normal operation |
| 30–1 | **Wounded** | -1 AP per turn, movement range -1 |
| 0 | **Downed** | Removed from tactical map |

**Downed operatives:**
- If another operative is adjacent at end of mission: **recovered** (returns to base, needs infirmary)
- If extracted without recovery: **MIA** (lost permanently after 3 in-game days without rescue mission)
- If killed outright (HP reduced to 0 in one hit from full HP): **KIA** (permanent loss)

One-hit kill rule: If damage ≥ current HP + 20, operative dies instantly instead of being downed.

---

## 5. PHASE 1 MAP — HAND-CRAFTED

### 5.1 Map Layout (8×8 grid)

```
     0    1    2    3    4    5    6    7
  ┌────┬────┬────┬────┬────┬────┬────┬────┐
0 │ S  │    │    │    │[G1]│    │    │    │
  ├────┼────┼────┼────┼────┼────┼────┼────┤
1 │    │[WW]│[WW]│    │    │[WW]│[WW]│    │
  ├────┼────┼────┼────┼────┼────┼────┼────┤
2 │    │[WW]│[C] │    │    │[WW]│[C] │    │
  ├────┼────┼────┼────┼────┼────┼────┼────┤
3 │    │    │    │[G2]│    │    │    │    │
  ├────┼────┼────┼────┼────┼────┼────┼────┤
4 │    │[WW]│[C] │    │    │    │[WW]│    │
  ├────┼────┼────┼────┼────┼────┼────┼────┤
5 │    │[WW]│[WW]│    │[G3]│[WW]│[WW]│    │
  ├────┼────┼────┼────┼────┼────┼────┼────┤
6 │    │    │    │    │    │    │    │    │
  ├────┼────┼────┼────┼────┼────┼────┼────┤
7 │    │    │    │    │    │    │[OBJ]│[X] │
  └────┴────┴────┴────┴────┴────┴────┴────┘

LEGEND:
  S    = Squad start zone (operatives spawn in column 0)
  [WW] = Full Cover wall segment (blocks LoS)
  [C]  = Half Cover (crates / furniture)
  [G1] = Guard 1 — facing South (↓), vision covers rows 0-2, col 4
  [G2] = Guard 2 — facing West (←), vision covers col 0-3, row 3
  [G3] = Guard 3 — facing North (↑), vision covers rows 3-5, col 4
  [OBJ]= Objective tile — interact to extract intel (1 AP)
  [X]  = Extraction tile — end mission
```

### 5.2 Map Narrative

**Mission name:** OPERATION COLDBURN
**Briefing:** A GRU safehouse in an industrial district. An asset with access to Project Chimera documentation is being held. Extract the intel from their server terminal and get out.
**Threat level:** Medium
**Recommended squad:** 2–4 operatives

### 5.3 Two Valid Routes

**Route A — Direct (risky):**
Move east along Row 0, neutralize G1, push south to objective. Faster but G1 has broad vision cone covering the eastern corridor.

**Route B — Stealth (slow):**
Move south along Column 0, use wall cover in Rows 1-5, slide east through Row 6 (below all guards), reach objective from south. Avoids all guards if Stealth ≥ 5.

This gives the player a meaningful first choice without overwhelming complexity.

### 5.4 Guard Behavior (Phase 1 — Static)

All guards in Phase 1 are **static with fixed facing**. They do not patrol. Alert Meter functions normally.

```gdscript
# EnemyGuard.gd
extends Node3D

@export var facing: Vector2i = Vector2i(0, 1)  # South by default
@export var vision_range: int = 6
@export var vision_angle_deg: float = 90.0

var alert_meter: float = 0.0
var state: String = "unaware"  # unaware, suspicious, alerted, combat

func _on_alert_meter_changed():
    if alert_meter < 31:
        state = "unaware"
    elif alert_meter < 61:
        state = "suspicious"
        # Phase 1: just changes sprite color to yellow
    elif alert_meter < 91:
        state = "alerted"
        # Phase 1: moves to last known position (basic)
    else:
        state = "combat"
        # Phase 1: shoots at operative if LoS available
```

### 5.5 Objective Interaction

```gdscript
# ObjectiveTile.gd
extends Node3D

var is_secured: bool = false

func interact(operative: Operative):
    if is_secured:
        return
    # Play interaction animation (Phase 2)
    AudioManager.play("ui_confirm")
    is_secured = true
    ResourceManager.add("intel", 5)
    EventBus.emit_signal("objective_secured", "coldburn_server")
    # Show popup: "Server accessed. Intel extracted. Get to extraction."
```

### 5.6 Extraction

Extraction tile at [7, 7]. Rules:
- At least 1 operative must reach extraction tile
- Extraction is **not** blocked — reaching the tile ends the mission immediately
- Operatives left behind are marked MIA
- Mission ends with `GameState.transition_to(GameState.State.DEBRIEF)`

```gdscript
# ExtractionTile.gd
extends Node3D

func _on_operative_entered(operative: Operative):
    if not MissionManager.objective_secured:
        # Show warning: "Objective not secured. Extract anyway?"
        # If yes: mission ends as PARTIAL SUCCESS (no intel reward)
        return
    MissionManager.add_extracted_operative(operative)
    # If all living operatives extracted or player manually ends:
    MissionManager.complete_mission(true)
```

---

## 6. MISSION MANAGER

`MissionManager.gd` — autoload added to load order between `DayCycle` and `GameState`:

```gdscript
# MissionManager.gd
extends Node

var current_mission: Dictionary = {}
var squad: Array = []
var extracted_operatives: Array = []
var objective_secured: bool = false
var turn_count: int = 0

signal mission_started(mission: Dictionary)
signal mission_completed(result: Dictionary)

func start_mission(mission_data: Dictionary, selected_squad: Array):
    current_mission = mission_data
    squad = selected_squad
    extracted_operatives = []
    objective_secured = false
    turn_count = 0
    GameState.transition_to(GameState.State.TACTICAL_MISSION)
    get_tree().change_scene_to_file("res://scenes/tactical/TacticalView.tscn")
    emit_signal("mission_started", mission_data)

func complete_mission(success: bool):
    var result = {
        "success": success,
        "objective_secured": objective_secured,
        "extracted_count": extracted_operatives.size(),
        "squad_size": squad.size(),
        "turns_taken": turn_count,
        "intel_gained": 5 if objective_secured else 0,
        "casualties": _calculate_casualties()
    }
    # Apply results
    for op in extracted_operatives:
        op.xp += _calculate_xp(result)
        op.stress += _calculate_stress(result)
    EventBus.emit_signal("mission_completed", success, result)
    GameState.transition_to(GameState.State.DEBRIEF)
    get_tree().change_scene_to_file("res://scenes/main/Main.tscn")

func _calculate_casualties() -> Array:
    var casualties = []
    for op in squad:
        if not extracted_operatives.has(op):
            casualties.append(op)
    return casualties

func _calculate_xp(result: Dictionary) -> int:
    var xp = 1
    if result.objective_secured: xp += 2
    if result.success: xp += 1
    return xp

func _calculate_stress(result: Dictionary) -> int:
    var stress = 10  # base stress from any mission
    if not result.success: stress += 10
    if result.casualties.size() > 0: stress += 5 * result.casualties.size()
    return stress
```

Updated autoload order (slot 8.5 — between DayCycle and GameState):
```
8.  DayCycle
8.5 MissionManager   ← NEW
9.  GameState
```

---

## 7. DEBRIEF SCREEN

After mission ends, `DebriefScreen.tscn` displays:

```
┌──────────────────────────────────────────────────────────┐
│              OPERATION COLDBURN — DEBRIEF                │
├──────────────────────────────────────────────────────────┤
│  RESULT:       ✅ SUCCESS                                │
│  Objective:    ✅ Intel extracted (+5 Intel)             │
│  Extracted:    3 / 4 operatives                          │
│  MIA:          Vance — recovery mission available        │
├──────────────────────────────────────────────────────────┤
│  OPERATIVE RESULTS:                                      │
│  ┌────────┬─────┬────────┬────────┬──────────────────┐  │
│  │ Name   │ HP  │  XP    │ Stress │ Status           │  │
│  ├────────┼─────┼────────┼────────┼──────────────────┤  │
│  │ Reyes  │ 85  │ +4 XP  │ +10    │ ✅ Extracted     │  │
│  │ Chen   │ 42  │ +4 XP  │ +15    │ 🏥 Wounded       │  │
│  │ Park   │ 100 │ +4 XP  │ +10    │ ✅ Extracted     │  │
│  │ Vance  │  0  │ +1 XP  │  —     │ ⚠️ MIA (3 days) │  │
│  └────────┴─────┴────────┴────────┴──────────────────┘  │
├──────────────────────────────────────────────────────────┤
│  REWARDS:  +$800 Budget   +5 Intel   Control Trust +3   │
├──────────────────────────────────────────────────────────┤
│                          [CONTINUE]                      │
└──────────────────────────────────────────────────────────┘
```

---

## 8. MISSION TYPES (ALL PHASES)

### Phase 1 — 1 Type

| Type | Objective | Win | Lose |
|------|-----------|-----|------|
| **Extraction** | Reach objective tile, then extraction tile | 1+ operative extracted | All operatives downed |

### Phase 2 — 3 Types

| Type | Objective | Win | Lose |
|------|-----------|-----|------|
| **Neutralize** | Eliminate all enemies | 0 enemies remaining | All operatives downed |
| **Stealth** | Reach objective without triggering Combat state on any enemy | Objective secured undetected | Any enemy reaches Combat state |
| **Escort** | Move an NPC asset from start to extraction | Asset reaches extraction alive | Asset killed / all operatives downed |

### Phase 3 — 5 Types (adds)

| Type | Objective |
|------|-----------|
| **Sabotage** | Place charges on 3 target tiles, extract before timer |
| **Rescue** | Find and extract an MIA operative held in a cell |

---

## 9. PROCEDURAL MAP SYSTEM (PHASE 2 DESIGN)

Not built in Phase 1. Documented here so Phase 2 architecture does not conflict with Phase 1 implementation.

### 9.1 Chunk-Based Generation

Maps are assembled from **hand-crafted chunks** (5×5 tile rooms) stitched together:

```
CHUNK TYPES:
  - Entry room (always at start)
  - Corridor (1-wide connector)
  - Guard post (1-2 guards, cover tiles)
  - Open area (low cover, high risk)
  - Server room (objective spawn point)
  - Storage (loot tiles)
  - Exit room (extraction point, always at end)

GENERATION RULES:
  1. Place Entry chunk at (0,0)
  2. Pick mission size (small: 3 chunks, medium: 5, large: 8)
  3. For each chunk slot: pick from pool weighted by mission type
     - Extraction missions: more server/storage chunks
     - Neutralize missions: more guard post / open area chunks
     - Stealth missions: more corridor / storage chunks
  4. Place Exit chunk at end of chain
  5. Connect all chunks with corridors
  6. Spawn guards based on threat level
  7. Bake navigation mesh
```

### 9.2 TacticalMap Data Structure

```gdscript
# TacticalMap.gd (scene-level, not autoload)
extends Node3D

var grid_size: Vector2i = Vector2i(8, 8)
var tiles: Array = []  # 2D array of TileData

class TileData:
    var type: String        # "floor", "wall", "cover_half", "cover_full", "door", "vent"
    var is_occupied: bool   # true if operative or enemy is here
    var occupant: Node      # reference to operative/enemy node
    var nav_weight: float   # pathfinding cost (1.0 default, 2.0 for rubble)
    var blocks_los: bool    # true for walls and full cover
    var noise_modifier: float  # 0.5 for vents (reduces noise emission)

func tile_to_world(tile: Vector2i) -> Vector3:
    return Vector3(tile.x * 4.0, 0.0, tile.y * 4.0)

func world_to_tile(world: Vector3) -> Vector2i:
    return Vector2i(int(world.x / 4.0), int(world.z / 4.0))

func get_tile(pos: Vector2i) -> TileData:
    if pos.x < 0 or pos.y < 0 or pos.x >= grid_size.x or pos.y >= grid_size.y:
        return null
    return tiles[pos.x][pos.y]
```

---

## 10. PHASE 1 IMPLEMENTATION CHECKLIST

Before calling Phase 1 tactical layer complete:

```
SCENE SETUP
[ ] TacticalView.tscn loads from GameState.TACTICAL_MISSION transition
[ ] 8x8 GridMap renders correctly with Kenney Simple Dungeon tiles
[ ] Camera loads via CameraManager.switch_to_tactical()
[ ] Camera: top-down, WASD pan, scroll zoom functional

OPERATIVES
[ ] 2-4 operatives from squad selection spawn at column 0 (S tiles)
[ ] Click operative → highlight valid movement tiles (blue)
[ ] Click highlighted tile → operative moves
[ ] AP counter updates after each action
[ ] End Turn button → Enemy Phase begins

GUARDS (STATIC)
[ ] 3 guards placed at G1, G2, G3 with correct facing
[ ] Vision cones visible (debug overlay, toggle with F1)
[ ] Alert meter visible (debug overlay, toggle with F1)
[ ] Walking into vision cone → alert meter fills
[ ] Alert meter > 90 → guard shoots at operative (basic ranged attack)

COMBAT
[ ] Hit chance calculated correctly (formula from §4.1)
[ ] Damage applied, HP updates
[ ] Operative HP ≤ 0 → downed, removed from map
[ ] Guard HP ≤ 0 → downed, removed from map (guards have 50 HP in Phase 1)

LINE OF SIGHT
[ ] LoS raycast blocks through [WW] tiles
[ ] LoS passes through [C] half-cover tiles
[ ] Guard cannot shoot operative behind full cover

OBJECTIVE
[ ] Reaching [OBJ] tile + Interact (1 AP) → objective_secured = true
[ ] +5 Intel added to ResourceManager
[ ] EventBus emits "objective_secured"

EXTRACTION
[ ] Reaching [X] tile after objective secured → mission complete
[ ] Reaching [X] tile before objective → warning popup
[ ] MissionManager.complete_mission(true) called
[ ] Debrief screen loads with correct results

WIN/LOSE
[ ] All operatives downed → MissionManager.complete_mission(false)
[ ] Debrief screen loads with FAILED state
[ ] Return to base → GameState.BASE_PHASE

AUDIO
[ ] Footstep sound on movement
[ ] Alert sound when guard enters suspicious state
[ ] Gunshot SFX on attack
[ ] Mission success music sting
[ ] Mission fail music sting
```

---

## 11. OPEN QUESTIONS FOR CLIENT

Two items require client decision before Phase 2 procedural system is built:

**OQ-1 — Partial success:** If operative reaches extraction WITHOUT securing objective, is the result:
- (A) Failure — no rewards, operatives still extracted
- (B) Partial success — operatives extracted safely, no intel reward, Control Trust -5

Recommendation: Option B. Failure with no reward feels too punishing for a first run.

**OQ-2 — Alert state persistence:** If a guard reaches Combat state but the player kills them, do remaining guards stay alerted for the rest of the mission or does the alert decay?

Recommendation: Alert decays after 3 turns with no new stimuli. Keeps stealth viable after a single engagement.

---

## 12. DOCUMENT SUMMARY

| Section | Status |
|---------|--------|
| Turn structure and AP | ✅ Fully defined |
| Movement and tile costs | ✅ Fully defined |
| Cover system | ✅ Fully defined |
| Line of sight | ✅ Defined with code |
| Stealth / detection cone | ✅ Defined with code |
| Alert meter | ✅ Defined with states |
| Combat / hit formula | ✅ Defined |
| Death and wounding | ✅ Defined |
| Phase 1 map (8×8) | ✅ Fully designed |
| MissionManager | ✅ Defined with code |
| Debrief screen | ✅ Wireframe provided |
| Phase 2 mission types | ✅ Outlined |
| Procedural system | ✅ Designed (Phase 2) |
| Phase 1 checklist | ✅ Complete |
| Open questions | ⏸ 2 pending client answers |

**This document is ready for client review.**
**Build can begin at Week 13 after client approves OQ-1 and OQ-2.**
