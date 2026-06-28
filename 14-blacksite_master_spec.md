# 14-blacksite_master_spec.md
# Blacksite Command — Master Reference Document
> Compiled from docs 1–13. Conversations removed. Decisions final. Build-ready.
> Engine: Godot 4.3 GDScript | Phase 1 Target: 20 weeks | Status: BUILD PHASE

---

## TABLE OF CONTENTS
1. Game Overview
2. Resource System
3. Facility Building
4. Detainee & Interrogation System
5. Operative System
6. Moral System
7. Factions
8. Event System
9. Architecture — Singletons & Load Order
10. Autoload Code Reference
11. Tactical Mission System
12. Phase 1 Map — OPERATION COLDBURN
13. Save Schema
14. Build Timeline (20 Weeks)
15. Phase 1 Deliverable Checklist
16. Asset List
17. Tech Stack & Tools
18. Platform & Distribution
19. Known Tech Debt (Phase 2)

---

## 1. GAME OVERVIEW

**Title:** Blacksite Command
**Genre:** 3D Turn-Based Strategy / Base Management
**Engine:** Godot 4.3 stable, GDScript, Forward+ renderer
**Target:** PC (Windows/Linux), Steam Deck
**Price:** $19.99 Early Access → $24.99 full release
**Audience:** Mature 16+

### Premise
Year 2027. You command Site Omega — a covert black ops facility buried beneath the Siberian permafrost. Manage infrastructure, interrogate detainees, deploy operatives on tactical missions. Every decision carries moral weight. 5 endings based on moral alignment + faction standing.

### One Session (60–90 min)
1. Morning briefing — Control pushes 1–3 objectives
2. Base phase (15–30 min) — build rooms, assign operatives, interrogate detainees
3. Tactical mission (20–40 min) — deploy squad, stealth or combat, extract
4. Post-mission debrief — XP, rewards, casualties
5. End of day — events fire, moral alignment shifts
6. Save / repeat

### Win Condition
3 Acts (~12–15 hours). Each Act ends with a major operation. Final ending triggered by moral alignment + faction standing + narrative flags. **5 endings total.** (Phase 3)

### Lose Conditions
| Condition | Trigger |
|-----------|---------|
| Base Exposure | Security = 0 + breach event fires |
| Operative Mutiny | Loyalty drops below threshold across full roster |
| Control Termination | Too many failed objectives → cleanup team sent |
| Detainee Breach | High-value detainee escapes with intel |
| Squad Wipe | All operatives dead on a mission |

---

## 2. RESOURCE SYSTEM

### 8 Resources (all tracked in ResourceManager)

| Resource | Start | Cap | Source | Spent On |
|----------|-------|-----|--------|----------|
| Budget ($) | 5000 | 10000* | Control allocation (+500/day), mission rewards, intel sales | Construction, research, salaries |
| Intel (📄) | 0 | INF | Interrogation, missions, informants, Command Center (+5/day) | Research unlock, trade, faction favors |
| Power (⚡) | 0 | Set by Generators | Generator rooms | All rooms consume power |
| Oxygen (💨) | 100 | Set by Life Support | Life Support rooms | All habitable rooms consume O₂ |
| Security (🔒) | 50 | 100 | Security rooms, Armory adjacency | Degraded by events, escape attempts |
| Moral Alignment | 0 | ±100 | Player choices, interrogation, events | Affects research access, endings |
| Control Trust | 80 | 100 | Mission success, following orders | Questioning orders, mercy, releases |
| Black Market Rep | 0 | 100 | Selling intel/tech, faction trades | Illegal tech, off-book operatives |

*Budget cap increases with Storage Rooms (+5000 each).

### Power Shortfall Rules
- Power deficit: Tier 3 rooms shut first, then Tier 2, then Tier 1
- If Tier 1 rooms exceed capacity: all rooms operate at N% efficiency proportionally
- If deficit > 50% of capacity: emergency shutdown — generator runs at 100%, all non-critical rooms offline
- If Generator itself would shut down: **Game Over — facility blackout**

### O₂ Shortfall
- O₂ deficit: operatives take damage over time. Rate: 5 HP/day per 10-unit deficit.

---

## 3. FACILITY BUILDING

### Grid
- 1 tile = 4m × 4m. Base starts 8×8. Expands to 20×20 (Phase 2).
- Up to 3 floors. Corridors required to connect rooms.
- Rooms track: `power_consumption`, `oxygen_consumption`, `tier`, `security_modifier`, `morale_modifier`

### Room Data Format (.tres)
```gdscript
# RoomData.gd
extends Resource
class_name RoomData

@export var id: String
@export var display_name: String
@export var cost: int
@export var power_production: float
@export var power_consumption: float
@export var oxygen_consumption: float
@export var tier: int          # 1=critical, 2=important, 3=comfort
@export var security_modifier: int
@export var morale_modifier: int
@export var budget_cap_bonus: int
```

### 25 Room Catalogue

| Category | Room | Cost | Power | O₂ | Notes |
|----------|------|------|-------|----|-------|
| **Habitation** | Barracks | 800 | 10 | 10 | Houses 4 operatives, morale +5/day |
| | Officer Quarters | 2000 | 15 | 15 | Morale +15/day, holds 1 |
| | Mess Hall | 1200 | 15 | 20 | Morale +10/day all |
| | Recreation Room | 1500 | 20 | 15 | Stress -20/day |
| **Operations** | Command Center | 3000 | 25 | 10 | Unlocks missions, +5 Intel/day |
| | Intelligence Hub | 2500 | 20 | 15 | +15 Intel/day |
| | Server Farm | 4000 | 40 | 20 | +Intel storage, research +10% |
| **Security** | Armory | 1500 | 10 | 5 | Equips operatives |
| | Security Checkpoint | 800 | 15 | 3 | Security +20, -50% escape chance |
| | Containment Cell | 600 | 5 | 5 | +1 detainee slot |
| | Interrogation Chamber | 2000 | 15 | 10 | Unlocks interrogation |
| | Observation Wing | 1800 | 20 | 10 | -resistance rate on detainees |
| **Infrastructure** | Generator Room | 2000 | 0 | 5 | +50 Power capacity |
| | Life Support | 2000 | 10 | 0 | +50 O₂ capacity |
| | Water Treatment | 1500 | 15 | 0 | +50 O₂ capacity (alternate) |
| | Storage Room | 800 | 5 | 5 | +5000 Budget cap |
| **Research** | Bio Lab | 3000 | 30 | 25 | Unlocks chemical interrogation, bio-weapons |
| | Tech Lab | 3000 | 30 | 20 | Unlocks surveillance, counter-intel |
| | Psychology Wing | 2500 | 20 | 15 | Unlocks psychological interrogation |
| **Medical** | Infirmary | 1200 | 15 | 15 | +30 HP recovery/day |
| | Surgery Suite | 2500 | 25 | 20 | Critical wound recovery |
| | Mortuary | 800 | 5 | 5 | Disposal (sanctioned) |
| **Special** | Black Market Hub | 5000 | 10 | 5 | Illegal tech, off-book trades |
| | Safe House | 3000 | 0 | 0 | Emergency extraction point |
| | Signal Bunker | 4000 | 20 | 15 | Control override protection |

### Adjacency Bonuses/Penalties
| Pair | Effect |
|------|--------|
| Barracks + Interrogation Chamber | Morale -5/day (they hear screams) |
| Mess Hall + adjacent room (any) | Mess Hall +10% efficiency |
| Containment Cell + Armory | Security +10 |
| Command Center + Generator (same floor) | -10% power efficiency |
| Recreation Room + Barracks | Stress -10/day bonus |
| Mortuary + Interrogation Chamber | No penalty |

### Phase 1 Rooms (5 Only)
Generator Room, Command Center, Barracks, Containment Cell, Armory (as colored placeholder cubes)

---

## 4. DETAINEE & INTERROGATION SYSTEM

### Caps
- Base cap: 3. +1 per Containment Cell. Max: 8.

### Detainee Profile Fields
| Field | Range |
|-------|-------|
| Name / Backstory | Procedural from 50 templates |
| Intel Value | 1–20 (total extractable) |
| Resistance Level | 1–10 |
| Willpower | 0–100 (depleted in sessions; 0 = broken) |
| Health | 0–100 (can die) |
| Threat Level | 1–5 (escape/attack risk) |
| Faction | 1 of 6 |
| Trait | 1 of 12 (e.g. "Innocent", "Career Intel", "Trained") |

### Interrogation Approaches

| Approach | Willpower Damage | Intel/Session | Health Risk | Moral Penalty |
|----------|-----------------|---------------|-------------|---------------|
| Psychological | 5–15 | 1–3 | None | Low |
| Chemical | 15–30 | 3–8 | 5–15 HP | Medium |
| Physical | 30–50 | 5–12 | 15–40 HP | High |

- Session = 30 seconds real-time. Player picks approach each session.
- Willpower → 0: detainee breaks, reveals all remaining intel at once.
- Health → 0: detainee dies, remaining intel lost permanently.
- "Innocent" trait: physical/chemical doubles moral penalty.
- "Trained" trait: +5 to all Willpower checks.

### Post-Interrogation Options
1. **Release** — Moral gain. May trigger faction events.
2. **Eliminate** — Moral loss. No further intel.
3. **Turn Asset** — Requires Intel Hub + Psychology Wing. Double agent intel over time.
4. **Transfer** — Small Budget reward, narrative choice.

### Phase 1 Scope
1 detainee slot, psychological approach only, Release or Eliminate only.

---

## 5. OPERATIVE SYSTEM

### Caps
- Base cap: 6. +2 per Barracks. Max: 14.

### Stats
| Stat | Range | Effect |
|------|-------|--------|
| Combat | 1–10 | Damage, accuracy in missions |
| Stealth | 1–10 | Detection avoidance, noise reduction |
| Tech | 1–10 | Hacking, device interaction |
| Endurance | 1–10 | HP pool, stress resistance |
| Loyalty | 0–100 | Defection risk |
| Stress | 0–100 | Performance degradation |
| HP | 0–100 | Combat health |
| XP | 0+ | Levels up stats |

### Stress Mechanics
| Stress Level | Effect |
|-------------|--------|
| 0–30 | Normal |
| 31–60 | -10% all stats |
| 61–80 | -25% all stats, may refuse orders |
| 81–100 | Breakdown — unusable until treated |

### Defection Triggers
- Loyalty < 20 for 3 consecutive days
- Witness a "morally extreme" interrogation (Physical, Innocent trait)
- Assigned to interrogation duty for 5+ consecutive days
- Faction with higher standing offers extraction (Phase 2)

### XP & Progression (Phase 2)
- XP from missions, interrogation duty, training
- Level up → +1 to one stat (player choice)
- Traits unlocked at stat thresholds

### Phase 1 Scope
4 operatives, hardcoded. Stats: Combat, HP, Stress, Loyalty only.

---

## 6. MORAL SYSTEM

- Scale: –100 to +100. Hidden from player.
- Tracked in `ResourceManager.resources["moral_alignment"]` (single source of truth).

### Thresholds & Effects
| Range | Label | Effect |
|-------|-------|--------|
| +61 to +100 | Righteous | Control inspector sent, certain research locked |
| +21 to +60 | Pragmatic | Default access, operatives loyal |
| –20 to +20 | Gray Zone | Full access to all systems |
| –21 to –60 | Ruthless | Black market full access, operatives begin questioning |
| –61 to –100 | Monstrous | Faction contacts increase, morale collapses, some operatives defect |

### Sample Moral Events
| Action | Shift |
|--------|-------|
| Physical interrogation | -10 |
| Detainee death | -15 |
| Release detainee | +8 |
| Turn asset (double agent) | -5 |
| Mission success (civilian harm) | -12 |
| Mission success (no civilian harm) | +5 |
| Operative defection | -8 |
| Let operative retire | +10 |
| Research bioweapons | -20 |

---

## 7. FACTIONS (Phase 2)

| Faction | Role | Default Standing |
|---------|------|-----------------|
| GRU | Russian military intel | Hostile |
| The Network | Freelance intelligence brokers | Neutral-tradeable |
| Control | Your own handlers (hidden agenda) | Always present |
| Crimson Brigades | Private military corp | Hostile; raids base at low standing |
| Initiative | NGO/journalist network (moral faction) | Ally if alignment > +40 |
| Unaffiliated | Independents, civilians, loose ends | Neutral |

Standing effects: Trade prices, exclusive intel, raid warnings at high standing. Retaliation missions at low standing. Crimson Brigades base raids are Phase 2 content.

---

## 8. EVENT SYSTEM

### Event Data Structure (events.json)
```json
{
  "id": "event_003",
  "trigger": "morning_phase",
  "weight": 3,
  "cooldown_days": 3,
  "text": "Control transfers emergency funds to Site Omega.",
  "flavor": "A coded message arrives at 0300: 'Expenses approved. Don't ask questions.'",
  "choices": [
    { "label": "Accept", "stat_changes": [{ "resource": "budget", "amount": 1000 }] },
    { "label": "Refuse (moral)", "stat_changes": [{ "resource": "moral_alignment", "amount": 5 }, { "resource": "control_trust", "amount": -10 }] }
  ]
}
```

### EventSystem Selection Logic
```gdscript
func select_event(phase: String) -> Dictionary:
    var candidates = []
    for event in _events:
        if event.trigger != phase: continue
        if event.has("cooldown_days") and _last_fired.get(event.id, -999) > current_day - event.cooldown_days: continue
        candidates.append(event)
    if candidates.is_empty(): return {}
    var total_weight = 0
    for e in candidates: total_weight += e.weight
    var roll = randf_range(0, total_weight)
    var accumulator = 0.0
    for e in candidates:
        accumulator += e.weight
        if roll <= accumulator:
            _last_fired[e.id] = current_day
            return e
    return candidates.back()
```

### Phase 1 Events (10)
| # | Event | Effect |
|---|-------|--------|
| 1 | Control sends mission briefing | Unlocks tactical mission |
| 2 | Unusual perimeter activity | Security -10 |
| 3 | Budget transfer from Control | Budget +1000 |
| 4 | Detainee escape attempt | Security check (pass/fail) |
| 5 | Operative stress signs | Operative stress +15 |
| 6 | Control questions decisions | Control Trust -5 |
| 7 | Informant tip | Intel +5 |
| 8 | Power fluctuation | Power capacity -10 for 1 day |
| 9 | Operative requests reassignment | Loyalty check |
| 10 | Control research dossier | Placeholder for Phase 2 research unlock |

---

## 9. ARCHITECTURE — SINGLETONS & LOAD ORDER

### 13 Autoloads (in exact load order)
```
1.  EventBus          — pure signal relay, no dependencies
2.  RoomDatabase      — loads .tres files from resources/rooms/
3.  ResourceManager   — economy, emits to EventBus
4.  FacilityManager   — room placement, reads ResourceManager
5.  OperativeManager  — personnel, reads ResourceManager
6.  MoralTracker      — alignment, reads ResourceManager, emits to EventBus
7.  EventSystem       — narrative events, reads all above
8.  DayCycle          — time cycle, calls EventSystem
9.  GameState         — state machine, listens to EventBus, controls scene transitions
10. SaveManager       — reads all singletons on save, writes all on load
11. AudioManager      — listens to EventBus, plays sounds
12. TutorialManager   — listens to EventBus, fires Day 1 popups
13. CameraManager     — manages BaseCameraRig / TacticalCameraRig switching
```

### EventBus Signals
```gdscript
# EventBus.gd
extends Node

signal day_started(day: int)
signal phase_changed(phase: String)
signal room_built(room_id: String, tile: Vector2i)
signal room_demolished(tile: Vector2i)
signal resource_changed(type: String, value: float)
signal event_fired(event: Dictionary)
signal game_over(reason: String)
signal mission_started(mission_id: String)
signal mission_completed(success: bool, result: Dictionary)
signal moral_threshold_crossed(threshold: String)
signal objective_secured()
```

### GameState
```gdscript
# GameState.gd
extends Node

enum State { MAIN_MENU, BASE_PHASE, MISSION_BRIEFING, TACTICAL_MISSION, DEBRIEF, GAME_OVER, VICTORY }
var current_state: State = State.MAIN_MENU
var in_tactical_mission: bool = false

signal state_changed(new_state: State)

func trigger_game_over(reason: String):
    current_state = State.GAME_OVER
    emit_signal("state_changed", State.GAME_OVER)
    EventBus.emit_signal("game_over", reason)

func transition_to(new_state: State):
    current_state = new_state
    in_tactical_mission = (new_state == State.TACTICAL_MISSION)
    emit_signal("state_changed", new_state)
```

---

## 10. AUTOLOAD CODE REFERENCE

### ResourceManager.gd
```gdscript
extends Node

var resources: Dictionary = {
    "budget": 5000.0,
    "intel": 0.0,
    "power": 0.0,           # net = production - consumption
    "oxygen": 100.0,
    "security": 50.0,
    "moral_alignment": 0.0,
    "control_trust": 80.0,
    "black_market_rep": 0.0
}

var base_caps: Dictionary = {
    "budget": 10000.0,
    "intel": INF,
    "power": INF,
    "oxygen": 100.0,
    "security": 100.0,
    "moral_alignment": 100.0,
    "control_trust": 100.0,
    "black_market_rep": 100.0
}

var cap_modifiers: Dictionary = {}  # room bonuses added here

func get_cap(type: String) -> float:
    return base_caps.get(type, INF) + cap_modifiers.get(type, 0.0)

func add(type: String, amount: float) -> void:
    if not resources.has(type):
        push_error("ResourceManager.add(): unknown resource '%s'" % type)
        return
    resources[type] = clamp(resources[type] + amount, 0.0, get_cap(type))
    EventBus.emit_signal("resource_changed", type, resources[type])

func spend(type: String, amount: float) -> bool:
    if resources[type] >= amount:
        resources[type] -= amount
        EventBus.emit_signal("resource_changed", type, resources[type])
        return true
    return false
```

### FacilityManager.gd
```gdscript
extends Node

var built_rooms: Array[Dictionary] = []

func build_room(room_id: String, tile: Vector2i, floor: int) -> bool:
    var room_data = RoomDatabase.get(room_id)
    if not room_data: return false
    if not ResourceManager.spend("budget", room_data.cost): return false
    built_rooms.append({
        "id": room_id, "tile": tile, "floor": floor,
        "hp": 100,
        "power_consumption": room_data.power_consumption,
        "oxygen_consumption": room_data.oxygen_consumption
    })
    if room_data.budget_cap_bonus > 0:
        ResourceManager.cap_modifiers["budget"] = ResourceManager.cap_modifiers.get("budget", 0) + room_data.budget_cap_bonus
    EventBus.emit_signal("room_built", room_id, tile)
    return true

func demolish_room(tile: Vector2i) -> void:
    var idx = built_rooms.find_custom(func(r): return r.tile == tile)
    if idx == -1: return
    var room = built_rooms[idx]
    ResourceManager.add("budget", RoomDatabase.get(room.id).cost * 0.5)
    built_rooms.remove_at(idx)
    EventBus.emit_signal("room_demolished", tile)

func has_room(room_id: String) -> bool:
    return built_rooms.any(func(r): return r.id == room_id)

func get_all_rooms() -> Array:
    return built_rooms
```

### DayCycle.gd
```gdscript
extends Node

var current_day: int = 1
var phase: String = "MORNING"

func advance_phase():
    match phase:
        "MORNING":   phase = "BASE"
        "BASE":      phase = "MISSION"
        "MISSION":   phase = "DEBRIEF"
        "DEBRIEF":   phase = "END_OF_DAY"
        "END_OF_DAY":
            current_day += 1
            phase = "MORNING"
            EventBus.emit_signal("day_started", current_day)
    EventBus.emit_signal("phase_changed", phase)
    _apply_daily_resources()
    _check_lose_conditions()

func _apply_daily_resources():
    ResourceManager.add("budget", 500)
    if FacilityManager.has_room("command_center"):
        ResourceManager.add("intel", 5)
    var total_power: float = 0.0
    var total_oxygen: float = 0.0
    for room in FacilityManager.get_all_rooms():
        total_power += room.power_consumption
        total_oxygen += room.oxygen_consumption
    ResourceManager.resources["power"] = total_power
    ResourceManager.resources["oxygen"] = clamp(ResourceManager.resources["oxygen"] - total_oxygen, 0, ResourceManager.get_cap("oxygen"))
    _check_resource_shortfall(total_power, total_oxygen)

func _check_resource_shortfall(power_used: float, oxygen_used: float):
    var power_cap = ResourceManager.get_cap("power")
    if power_used > power_cap:
        FacilityManager.trigger_power_outage(power_used - power_cap)
    var oxygen_cap = ResourceManager.get_cap("oxygen")
    if oxygen_used > oxygen_cap:
        OperativeManager.apply_oxygen_damage(oxygen_used - oxygen_cap)

func _check_lose_conditions():
    if ResourceManager.resources["security"] <= 0:
        if EventSystem.has_active_event("breach"):
            GameState.trigger_game_over("exposure")
```

### AudioManager.gd
```gdscript
extends Node

var _sounds: Dictionary = {}

func _ready():
    _load_all("res://assets/audio/sfx/")

func play(sound_id: String, volume_db: float = 0.0):
    if not _sounds.has(sound_id): return
    var player = AudioStreamPlayer.new()
    add_child(player)
    player.stream = _sounds[sound_id]
    player.volume_db = volume_db
    player.play()
    player.finished.connect(player.queue_free)
    # TODO Phase 2: replace with pool of 8 pre-allocated AudioStreamPlayers

func _load_all(path: String):
    var dir = DirAccess.open(path)
    if not dir: return
    dir.list_dir_begin()
    var file = dir.get_next()
    while file != "":
        if file.ends_with(".ogg") or file.ends_with(".wav"):
            var id = file.get_basename()
            _sounds[id] = load(path + file)
        file = dir.get_next()
```

### MoralTracker.gd
```gdscript
extends Node

func shift(amount: float, reason: String = ""):
    ResourceManager.add("moral_alignment", amount)
    _check_thresholds()

func _check_thresholds():
    var a = ResourceManager.resources["moral_alignment"]
    if a > 60:
        EventBus.emit_signal("moral_threshold_crossed", "righteous")
    elif a < -60:
        EventBus.emit_signal("moral_threshold_crossed", "monstrous")
```

### SaveManager.gd
```gdscript
extends Node

const SAVE_PATH = "user://save_v1.json"
const CURRENT_VERSION = "1.0"

func save_game():
    if GameState.in_tactical_mission:
        # Phase 1: warn player, do not save mid-mission
        return
    var data = _collect_state()
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(data))
    file.close()

func load_game():
    if not FileAccess.file_exists(SAVE_PATH): return false
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    file.close()
    if data.version != CURRENT_VERSION:
        _migrate(data)
    _apply_state(data)
    return true

func save_exists() -> bool:
    return FileAccess.file_exists(SAVE_PATH)

func _migrate(data: Dictionary):
    # Add migration logic per version increment
    pass
```

---

## 11. TACTICAL MISSION SYSTEM

### Turn Structure
- Initiative-based, **2 AP per operative per turn**
- Player activates one operative at a time, spends AP, then next operative
- When all player operatives have 0 AP → Enemy Phase begins
- Enemy Phase ends → new player turn, all AP refill

### AP Costs
| Action | Cost |
|--------|------|
| Move 1 tile | 1 AP |
| Move 2 tiles | 2 AP (max without abilities) |
| Attack (ranged) | 2 AP (full action) |
| Attack (melee) | 1 AP |
| Interact (terminal, door, loot) | 1 AP |
| Take cover | 0 AP (automatic) |

### Cover
- Half Cover: -25% to be hit (crates, desks)
- Full Cover: -50% to be hit (walls, pillars)
- `BASE_ACCURACY = 75%` (Phase 1 temp, revert for Phase 2 balance pass)

### Hit Chance Formula
```
HIT_CHANCE = 0.75 + (Combat - 5) * 0.05 - COVER_PENALTY - RANGE_PENALTY
COVER_PENALTY = 0.25 (half) or 0.50 (full)
RANGE_PENALTY = -0.05 per tile beyond optimal range
```

### Damage
```
DAMAGE = WEAPON_BASE ± 10% variance

Phase 1 weapons:
  Pistol: 20–30
  Rifle: 35–50

Instant kill: damage >= current_hp + 10
```

### Wounding & Death
| HP | State |
|----|-------|
| 100–31 | Active |
| 30–1 | Wounded (-20% all stats) |
| 0 | Downed — downed marker tile placed, operative out of mission |

### Downed Operative Recovery
- Downed operative removed from map, downed marker tile placed at fall position
- If ANY living operative reaches extraction tile → all downed operatives auto-recovered (infirmary, 14-day recovery)
- Operatives alive on map but not at extraction at mission end = **MIA**

### Mission Outcomes
| Outcome | Condition |
|---------|-----------|
| Full Success | At least 1 operative extracted + intel secured |
| Partial Success | Operatives extracted, no intel. Control Trust -5 |
| Total Failure | All operatives downed |

### Guard AI — 4 States (Semi-static, Phase 1)
| Alert Meter | State | Behavior |
|-------------|-------|----------|
| 0–30 | Unaware | Fixed facing, no action |
| 31–60 | Suspicious | Rotates ±45°, does not move |
| 61–90 | Alerted | Turns toward disturbance, takes 1 step toward last known position |
| 91–100 | Combat | Shoots if LoS available (range 8 tiles), pursues at 1 tile/turn |

**Alert Meter fills:**
- Operative in vision cone: +15/turn
- Operative in noise radius (walking): +8
- Body of downed ally found: +40
- Gunshot heard: +60 (all enemies in 8-tile radius)

**Alert Meter drains:**
- Source removed from cone: -5/turn
- Enemy returns to position: -10/turn

**Alert decay:** After 3 turns with no stimuli, Alert Meter decays.
**Group panic:** If 2+ guards hit Combat before being killed, survivors stay in Combat for 2 extra turns.

### Vision Cone
- 90° arc (45° each side of facing)
- Range: 6 tiles
- Blocked by walls and Full Cover

### Noise System (Manhattan distance)
```gdscript
func get_noise_distance(source: Vector2i, target: Vector2i) -> int:
    return abs(source.x - target.x) + abs(source.y - target.y)
```

| Noise Type | Radius |
|-----------|--------|
| Footstep | 2 tiles |
| Gunshot | 8 tiles |
| Takedown | 1 tile |
| Explosion | 12 tiles |
| Door | 3 tiles |

### Line of Sight
```gdscript
# LoSSystem.gd
func has_line_of_sight(from_tile: Vector2i, to_tile: Vector2i) -> bool:
    var from_pos = TacticalMap.tile_to_world(from_tile) + Vector3(0, 1.0, 0)
    var to_pos = TacticalMap.tile_to_world(to_tile) + Vector3(0, 1.0, 0)
    var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
    query.collision_mask = 0b0010
    var result = get_tree().root.get_world_3d().direct_space_state.intersect_ray(query)
    return result.is_empty()
# TODO Phase 2: Replace with 4 corner-to-corner raycasts for procedural maps
```

### MissionManager.gd
```gdscript
extends Node

var intel_secured: bool = false
var operatives: Array = []

const BASE_ACCURACY: float = 0.75  # PHASE_1_TEMP — revert before Phase 2 balance pass

func _calculate_outcome():
    var extracted = operatives.filter(func(op): return op.reached_extraction)
    var downed = operatives.filter(func(op): return op.is_downed)
    var mia = operatives.filter(func(op): return not op.reached_extraction and not op.is_downed)

    for op in downed:
        op.status = OP_STATUS.INFIRMARY
        op.recovery_days = 14
    for op in mia:
        op.status = OP_STATUS.MIA

    if extracted.size() == 0:
        return OUTCOME.TOTAL_FAILURE
    elif intel_secured:
        return OUTCOME.FULL_SUCCESS
    else:
        return OUTCOME.PARTIAL_SUCCESS

func _check_instant_kill(damage: int, target_hp: int) -> bool:
    return damage >= target_hp + 10  # Was +20, lowered for Phase 1 visibility
```

### TacticalMap.gd
```gdscript
extends Node3D

var grid_size: Vector2i  # Set from map data at load time (not hardcoded)

func load_map(map_data: Dictionary):
    grid_size = Vector2i(map_data.width, map_data.height)

func tile_to_world(tile: Vector2i) -> Vector3:
    return Vector3(tile.x * 4.0, 0.0, tile.y * 4.0)

func world_to_tile(world: Vector3) -> Vector2i:
    return Vector2i(int(world.x / 4.0), int(world.z / 4.0))
```

### UX (Weeks 13–14)
| Feature | Implementation |
|---------|---------------|
| F2 — skip enemy phase (dev only) | `if OS.is_debug_build() and Input.is_action_just_pressed("debug_skip_enemy"): end_enemy_phase()` |
| "ENEMY TURN" splash | `TacticalHUD.show_phase_banner("ENEMY TURN", 1.0)` |
| Camera follow operative | `CameraManager.smooth_pan_to(operative.tile_position, 0.3)` |
| Confirm order (Shift+click) | Ghost overlay on hover, confirm on click, right-click cancel |
| Mid-mission save | Warning popup: "Saving returns you to base. Mission progress lost." |

---

## 12. PHASE 1 MAP — OPERATION COLDBURN

**Briefing:** Target: GRU signals bunker beneath the Norilsk industrial district. Asset confirms three-man rotation guard detail. Objective: extract CARDINAL intelligence package from server room.

**Tileset:** Kenney Simple Dungeon (recolored dark grey/green via BaseMaterial3D.albedo_color)

**Map (8×8):**
```
     0    1    2    3    4    5    6    7
0  [WW] [WW] [WW] [WW] [WW] [WW] [WW] [WW]
1  [WW] [S ] [  ] [C ] [G1] [WW] [WW] [WW]
2  [WW] [S ] [WW] [  ] [  ] [  ] [WW] [WW]
3  [WW] [  ] [WW] [WW] [C ] [G2] [WW] [WW]
4  [WW] [  ] [  ] [OBJ][  ] [  ] [  ] [WW]
5  [WW] [WW] [  ] [WW] [C ] [  ] [WW] [WW]
6  [WW] [  ] [  ] [  ] [  ] [  ] [G3] [WW]
7  [WW] [WW] [X ] [WW] [WW] [WW] [WW] [WW]
```

**Legend:** S=Start, WW=Wall, C=Half Cover, G1/G2/G3=Guards, OBJ=Objective, X=Extraction

**Guard Positions & Facing:**
| Guard | Position | Facing |
|-------|----------|--------|
| G1 | (4,1) | South |
| G2 | (5,3) | West |
| G3 | (6,6) | North |

**Routes:**
- **Route A (direct):** Through G1 zone — high risk, combat likely
- **Route B (stealth):** East through Row 6. Tile (4,6) is at G1's max vision range (South, 6 tiles). Move through in single AP — Alert Meter +15 but does not trigger Suspicious (31) in one crossing. Stealth 5+ operative crouching minimizes exposure window.

---

## 13. SAVE SCHEMA (v1.0)

```json
{
  "version": "1.0",
  "day": 14,
  "resources": {
    "budget": 3200.0,
    "intel": 8.0,
    "power": 55.0,
    "oxygen": 60.0,
    "security": 42.0,
    "moral_alignment": -12.0,
    "control_trust": 72.0,
    "black_market_rep": 0.0
  },
  "rooms": [
    { "id": "command_center", "tile": [2, 3], "floor": 0, "hp": 100 },
    { "id": "barracks", "tile": [4, 3], "floor": 0, "hp": 100 }
  ],
  "operatives": [
    { "id": "op_001", "name": "Vance", "combat": 7, "hp": 90, "stress": 30, "loyalty": 80, "xp": 12, "status": "active" }
  ],
  "detainees": [
    { "id": "det_001", "name": "Viktor", "intel_value": 12, "resistance": 6, "willpower": 55, "health": 80 }
  ],
  "events_triggered": ["event_003", "event_007"],
  "last_fired": { "event_003": 11, "event_007": 8 },
  "flags": {
    "act1_mission1_complete": true,
    "tutorial_complete": true
  }
}
```

Notes:
- `moral_alignment` lives **only** inside `resources` (not top-level — bug fixed in doc 6)
- Mid-mission save in Phase 1: warning popup only, returns player to base. Full tactical state serialization in Phase 2.
- Version migration handled by `SaveManager._migrate()` — check `version` field on load.

---

## 14. BUILD TIMELINE (20 WEEKS)

| Week | Deliverable |
|------|-------------|
| 1 | Project setup, git repo, EventBus, GameState, MainMenu, RoomDatabase (.tres), 5 room files |
| 2 | ResourceManager (full + dynamic caps), ARCHITECTURE.md committed |
| 3 | FacilityManager, OperativeManager stub, demolish system |
| 4 | **MILESTONE 1** — all singletons load, resources tracked |
| 5 | GridSystem — 8×8 GridMap, click select, collision detection |
| 6 | Room placement — 5 rooms, power/O₂ routing |
| 6.5 | Audio — 18 SFX sourced and wired to EventBus |
| 7 | DayCycle — full phase cycle, resource application, shortfall handling |
| 8 | HUD — all resources displayed via EventBus signals |
| 9 | EventSystem — JSON load, weighted random, cooldowns |
| 10 | **MILESTONE 2** — base loop playable, rooms buildable, events fire |
| 11 | Operative system — 4 operatives, stats, stress/loyalty, Personnel screen |
| 12 | Detainee system — 1 slot, psychological interrogation, intel extraction |
| 13 | Tactical mission — 8×8 GridMap, movement, 3 guards, objective/extraction, UX features |
| 14 | Win/lose conditions, Game Over screen, confirm-order UX |
| 15 | TutorialManager — Day 1 scripted sequence |
| 16 | SaveManager — save/load with version migration |
| 17 | Full regression test — run checklist, fix all failures |
| 18 | Polish pass — SFX gaps, UI consistency, performance profile |
| 19–20 | **BUFFER** (illness/blockers/scope creep) |
| 20 | **PHASE 1 COMPLETE** — loop runs clean, client demo build delivered |

### Milestone Expectations
**Week 4:** Console shows "ResourceManager initialized / RoomDatabase loaded / EventBus ready / DayCycle ready / GameState ready: MAIN_MENU" — zero errors.
**Week 10:** Grid renders, rooms placeable, day cycle advances, events fire as text popup.
**Week 20:** Full playable loop — base → mission → debrief → day end → repeat. Save/load works. All lose conditions trigger.

---

## 15. PHASE 1 DELIVERABLE CHECKLIST

```
SYSTEMS
[ ] ResourceManager — 8 resources tracked, dynamic caps, error guard
[ ] DayCycle — morning/base/mission/debrief/end-of-day cycle
[ ] MoralTracker — alignment shifts, threshold events fire
[ ] EventSystem — 10 events with flavor text, weighted random, cooldown
[ ] GridSystem — 8x8 grid, click to place, collision detection (no overlapping)
[ ] FacilityManager — build_room(), demolish_room(), has_room(), get_all_rooms()
[ ] SaveManager — JSON save/load with version migration
[ ] AudioManager — 18 SFX wired to EventBus signals
[ ] EventBus — all singletons communicate through signals only

ROOMS (5)
[ ] Generator Room — placed, power capacity increases
[ ] Command Center — placed, Intel +5/day active
[ ] Barracks — placed, operative slot count increases
[ ] Containment Cell — placed, detainee slot count increases
[ ] Armory — placed, loadout screen accessible

OPERATIVES
[ ] 4 operatives visible in Personnel screen
[ ] Stats: Combat, HP, Stress, Loyalty displayed
[ ] Select 2–4 for mission squad
[ ] Post-mission: XP gained, stress applied, wound flag set

DETAINEES
[ ] 1 detainee can be held
[ ] Psychological interrogation — willpower drains, intel extracted
[ ] Release or Eliminate options function
[ ] Moral alignment shifts on each action

TACTICAL MISSION
[ ] TacticalView.tscn loads from GameState transition
[ ] 8×8 GridMap with COLDBURN map layout
[ ] Operatives spawn at S tiles, move via click
[ ] AP counter updates after each action
[ ] 3 guards with correct positions, facing, vision cones
[ ] Alert meter fills when operative in cone
[ ] Guard AI responds per 4-state table
[ ] Combat: hit chance formula, damage applied, HP updates
[ ] LoS: raycast blocks through WW, passes through C tiles
[ ] Objective: Interact at OBJ tile → objective_secured = true, +5 Intel
[ ] Extraction: reach X tile after objective → mission complete
[ ] Downed: operative removed, downed marker placed
[ ] Auto-recovery: all downed recovered if any operative extracts
[ ] F2 debug key skips enemy phase (debug build only)
[ ] "ENEMY TURN" splash shows on phase switch
[ ] Camera lerp follows selected operative
[ ] Mid-mission save shows warning popup

WIN/LOSE
[ ] Security = 0 + breach event → Game Over (exposure)
[ ] All operatives downed in mission → Game Over (squad wipe)
[ ] Game Over screen shows with reason

LOOP
[ ] base phase → mission → debrief → end of day → repeat
[ ] Day counter increments correctly
[ ] Game saves and reloads correctly mid-campaign

TUTORIAL
[ ] Day 1 scripted sequence fires (Generator → Command Center → End Day)
[ ] Tutorial deactivates after Day 2
```

---

## 16. ASSET LIST

### 3D Models (all placeholder in Phase 1)
| Category | Count |
|----------|-------|
| Room tiles (modular) | 25 |
| Corridor tiles | 4 |
| Base decor props | 15 |
| Operative characters (rigged) | 2 base + 12 variants |
| Detainee characters | 2 base + 6 variants |
| Enemy characters | 3 base + 6 variants |
| Tactical environment tiles | 20 |
| Tactical props | 30 |
| Weapons | 12 |
| **Total** | **~137** |

Phase 1 bridge: Kenney Simple Dungeon + Furniture Kit, recolored dark grey/green via `BaseMaterial3D.albedo_color`. No texture editing.

### UI Screens (15)
Main menu, settings, load/save, Base HUD, Build menu, Research tree, Personnel, Detainee roster, Interrogation, Mission briefing, Tactical HUD, Debrief, Event popup, Moral feedback, Game Over.

### Audio (Phase 1 — 18 SFX minimum)
`ui_click`, `ui_confirm`, `ui_deny`, `room_build`, `day_end`, `event_popup`, `mission_deploy`, `mission_success`, `mission_fail`, `interrogation_start`, `power_low`, `security_low`, `game_over`, `amb_base_idle`, `amb_tactical`, `footstep_metal`, `guard_alert`, `notification_control`

Sources: freesound.org (CC0), Soniss GDC Bundle (free annual)

No voice acting in v1. Text-only narrative. No pre-rendered cutscenes — in-engine text + portrait popups (Papers Please style). FMOD deferred to v1.5.

---

## 17. TECH STACK & TOOLS

| Layer | Choice | Notes |
|-------|--------|-------|
| Engine | Godot 4.3 stable | Pinned — no mid-project upgrades |
| Language | GDScript | No C# — faster prototyping, sufficient performance |
| Renderer | Forward+ | Bloom, SSAO, tonemapping |
| Grid | GridMap node | Single draw call per tile type, Phase 2 scales cleanly |
| AI | State machine (Phase 1), Beehave plugin (Phase 2) | |
| Data — rooms | `.tres` files | Editor-inspectable, type-safe |
| Data — events | `events.json` | Weighted, cooldown-aware |
| Save | JSON + `SaveManager.gd` | Version migration on load |
| Audio | Godot AudioStreamPlayer | Pool in Phase 2 (8 pre-allocated players) |
| Camera | Two separate rigs — BaseCameraRig + TacticalCameraRig | CameraManager handles switch |
| Editor | Godot built-in + VSCode + godot-tools extension | |
| Version control | Git, GitHub private repo | Client read-only access |

### Plugins (install timing)
- **Phantom Camera** — install Week 1 (smooth camera)
- **Beehave** — Phase 2 only
- **GDSQLite** — Phase 2 only (upgrade from JSON save)
- **GodotTodo** — optional, in-editor TODOs

---

## 18. PLATFORM & DISTRIBUTION

| Platform | Target |
|----------|--------|
| PC Windows | ✅ v1.0 primary |
| Linux | ✅ v1.0 (Godot native export) |
| Steam Deck | ✅ v1.0 verified target (<200 draw calls via GridMap) |
| macOS | ⬜ v1.5 post-launch |
| Console | ❌ Out of scope |

**Distribution:** Steam (Early Access → Full). itch.io (DRM-free).
**Pricing:** $19.99 Early Access → $24.99 full release.
**Steam page:** Phase 2 only — no public-facing content during Phase 1.

### Minimum Spec
| Component | Requirement |
|-----------|-------------|
| OS | Windows 10 64-bit |
| CPU | Intel i5-8400 / Ryzen 5 2600 |
| RAM | 8 GB |
| GPU | GTX 1060 / RX 580 (6GB VRAM) |
| Storage | 5 GB SSD |
| API | Vulkan-capable |

---

## 19. KNOWN TECH DEBT (Phase 2)

| Item | Location | Notes |
|------|----------|-------|
| AudioManager node pool | AudioManager.gd | Pre-allocate 8 AudioStreamPlayers, recycle on play — prevents GC stutter at 80+ SFX |
| LoS corner raycasts | LoSSystem.gd | Replace center-to-center with 4 corner-to-corner raycasts for procedural maps |
| Mid-mission save | SaveManager.gd | Serialize full TacticalMap state — tile data, guard positions, alert meters, operative HP/AP, turn counter |
| Fab.com character pack | Art budget | Due Week 6: exact URL + license + price + screenshots vs Phase 1 build |
| Recovery mission type | MissionManager.gd | MIA operative → 48-hour window → recovery mission on same site at higher alert |
| Drag mechanic | TacticalMap.gd | 2 AP to drag downed operative, dragging op moves at 1 tile/turn |
| Flanking bonus | MissionManager.gd | Attack from behind: +20% hit chance; opposite side of cover removes cover bonus |
| GridMap draw calls | FacilityManager.gd | 20×20 = 400 tiles. Already using GridMap — should stay under 200 draw calls on Steam Deck |
| ARCHITECTURE.md | Repo root | Commit Week 2 — autoload order, signal contracts, tech debt register |

---

## PROJECT FOLDER STRUCTURE

```
C:\Users\kibri\projects\blacksite_command\
├── godot\
│   ├── project.godot
│   ├── scenes/
│   │   ├── main/ (Main.tscn, MainMenu.tscn)
│   │   ├── base/ (BaseView.tscn, GridSystem.gd, Room.tscn)
│   │   ├── tactical/ (TacticalView.tscn, TacticalMap.gd)
│   │   └── ui/ (HUD.tscn, BuildMenu.tscn, MissionBriefing.tscn, DebriefScreen.tscn)
│   ├── autoloads/
│   │   ├── EventBus.gd
│   │   ├── RoomDatabase.gd
│   │   ├── ResourceManager.gd
│   │   ├── FacilityManager.gd
│   │   ├── OperativeManager.gd
│   │   ├── MoralTracker.gd
│   │   ├── EventSystem.gd
│   │   ├── DayCycle.gd
│   │   ├── GameState.gd
│   │   ├── SaveManager.gd
│   │   ├── AudioManager.gd
│   │   ├── TutorialManager.gd
│   │   └── CameraManager.gd
│   ├── resources/rooms/ (25 × .tres files)
│   ├── data/ (events.json)
│   └── assets/ (placeholder/, audio/sfx/, ui/)
├── design_docs\ (all .md files)
├── assets_wip\
└── builds\
```

---

*End of master spec. All decisions are final. Build from this document.*
