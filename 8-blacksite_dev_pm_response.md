# 8-blacksite_dev_pm_response.md
# Blacksite Command — Developer & PM Response to Client Round 2
> From: Development Team (Dev + PM)
> To: Publisher / Project Lead
> Previous: 7-blacksite_client_response_to_dev.md
> Status: All concerns addressed. All questions answered. 6 new issues found internally.

---

## DID CLIENT REVIEW ANSWER OUR QUESTIONS?

Yes. Every open item from doc 6 is now resolved or reassigned correctly.

| Item | Resolution |
|------|-----------|
| Faction doc ownership | ✅ Accepted — dev writes it, client provides faction names |
| Narrative events ownership | ✅ Accepted — dev writes or hires writer |
| Artist budget | ✅ Accepted — real quotes required before Phase 2 approval |
| Tactical mission doc | ✅ Client confirmed: doc first, build second |
| Git repo | ✅ Acknowledged — Week 1, no exceptions |

Client review quality: high. The power tier deadlock catch (Generator shutting itself down) and the EventSystem contract are both legitimate gaps we missed. Addressed below.

---

## ANSWERS TO ALL 6 CLIENT QUESTIONS — ROUND 2

### Critical

**Q1 — Git repo: when and access?**
Git repo will be initialized on Day 1 of Week 1. Platform: GitHub, private repository. Client will receive collaborator invite (read-only access) within 48 hours of project start. Branch strategy: `main` = milestone-stable, `dev` = active work. Commits pushed minimum every 2 days during active weeks. If no commit for 7 days, client may treat as paused without notification.

### Important

**Q2 — Kenney CC0 packs — which specific ones?**
Evaluated packs for military blacksite aesthetic compatibility:

| Pack | Use | Suitability |
|------|-----|-------------|
| [Kenney — Modular Buildings](https://kenney.nl/assets/modular-buildings) | Room shells, corridors | ⚠️ Too civilian — needs recolor |
| [Kenney — Simple Dungeon](https://kenney.nl/assets/simple-dungeon) | Underground corridors | ✅ Acceptable — dark tone |
| [Kenney — Furniture Kit](https://kenney.nl/assets/furniture-kit) | Room props, decor | ✅ Acceptable for placeholder |
| [Kenney — Minigolf Pack](https://kenney.nl/assets/minigolf-pack) | ❌ Wrong genre | ❌ Rejected |
| [Kenney — Shooting Gallery](https://kenney.nl/assets/shooting-gallery) | Weapons (placeholder) | ✅ Acceptable |

**Decision:** Simple Dungeon + Furniture Kit as bridge. All assets will be recolored to a dark grey/green military palette using Godot's `BaseMaterial3D.albedo_color` override — no texture editing needed. This keeps the bridge coherent enough for milestone reviews without looking like a children's game.

Client is correct that this is not a shipping art style. It is purely internal.

**Q3 — Tactical mission doc: before or after build?**
Doc first, build second. Confirmed. `7-tactical_mission_design.md` will be written and submitted for client review before Week 13. Target: submitted end of Week 10 alongside milestone review.

**Q4 — 2-week illness buffer?**
Built into updated timeline (see §REVISED TIMELINE below). Short answer: 2-week illness = 2-week slip on non-critical path items only. Critical path (ResourceManager → GridSystem → DayCycle) has no parallel work so slip is 1:1. Phase 1 end date moves from Week 18 to Week 20 as a realistic ceiling. Milestone reviews remain at Week 4, 10, and completion — they do not move unless client agrees.

### Nice to Know

**Q5 — GridMap node for base grid?**
**Yes.** Using Godot's `GridMap` node. Reasons:
- Single draw call per tile type (addresses Steam Deck concern directly)
- Built-in collision, navigation mesh baking support
- Editor visual placement for hand-crafted maps
- Room data stored separately in `FacilityManager` — GridMap is purely visual layer

Migration path to 20x20 in Phase 2 is trivial — GridMap scales without architecture change.

**Q6 — Editor setup?**
Primary: **Godot built-in editor** for scene/node work. Secondary: **VSCode with godot-tools extension** for GDScript — autocomplete, go-to-definition, inline errors. Debugger: Godot's built-in remote debugger + `print_debug()` for Phase 1. Phase 2: consider GDScript Debugger Pro if complex AI bugs emerge. No blind spots in current setup for Phase 1 scope.

---

## ALL CLIENT CONCERNS — STATUS AND FIXES

### 🔴 CRITICAL

---

**CONCERN 1 — Freelance artist budget too low (€800-1500 vs €10,000-17,000 reality)**

Client is correct. Our original quote was for room tiles only, not the full asset list.

Revised budget breakdown with market research:

| Category | Models | Low Estimate | High Estimate | Source |
|----------|--------|-------------|---------------|--------|
| Room tiles (modular set, 25) | 25 | €1,500 | €2,500 | ArtStation mid-tier |
| Corridor tiles | 4 | €0 (bundled) | €300 | — |
| Base decor props | 15 | €400 | €800 | Asset pack or freelance |
| Operative characters (rigged) | 2 base + 12 variants | €2,000 | €4,000 | Rigged = expensive |
| Detainee characters (rigged) | 2 base + 6 variants | €1,000 | €2,000 | |
| Enemy characters (rigged) | 3 base + 6 variants | €1,500 | €3,000 | |
| Tactical environment tiles | 20 | €1,000 | €2,000 | |
| Tactical props | 30 | €800 | €1,500 | |
| Weapons | 12 | €400 | €800 | |
| **TOTAL** | **~137** | **€8,600** | **€16,900** | |

**Action plan:**
- Week 3: Post brief on ArtStation, Fiverr Pro, and CG Trader — request quotes for room tile set only (Phase 2 entry point)
- Week 6: Compile 3 quotes, submit to client for approval
- Phase 2 art budget approved or adjusted before Phase 1 ends
- Character rigs are highest cost — evaluate Mixamo base rigs + custom overlay to reduce cost

**Cost reduction options:**
1. Use Mixamo rigged characters (free) + reskin — cuts character cost by ~60%
2. Buy a modular military character pack from Fab.com (~€150-400) — covers operatives + enemies
3. Commission room tiles only from freelancer, use asset packs for everything else

Realistic Phase 2 art budget with cost reduction: **€3,000-6,000** instead of €10,000-17,000.

---

**CONCERN 2 — Key person risk (solo dev, evenings/weekends)**

Acknowledged and addressed:

Three-point risk mitigation:

1. **Git repo** — set up Week 1, daily commits during active sessions (not just every 2 days — correcting our earlier statement)

2. **Architecture documentation** — every singleton and system gets a `ARCHITECTURE.md` comment block at the top of the file explaining what it does, what it depends on, and what depends on it. If another developer needs to pick up the project cold, they can orient in under 30 minutes.

3. **Session log** — a `DEVLOG.md` in the repo root, updated weekly. Format:
```
## Week 5 (Nov 18-24)
- Built GridSystem.gd — 8x8 grid functional, click selects tile
- Discovered: GridMap doesn't support runtime tile removal cleanly — workaround: hide tile + mark as empty in FacilityManager
- Blocker: none
- Next week: Room placement, power consumption
```

This protects client's investment and keeps the project recoverable.

---

### 🟠 HIGH

---

**CONCERN 3 — No audio week in 18-week plan**

Fixed. Audio added as a dedicated half-week:

**Week 6.5 — Basic Audio (3 days)**

Asset sources (all CC0):
- [Freesound.org](https://freesound.org) — UI clicks, alarms, ambience
- [Soniss GDC Bundle](https://sonniss.com/gameaudiogdc) — free annual bundle, high quality
- [OpenGameArt.org](https://opengameart.org) — ambient loops

Target SFX list for Phase 1 (18 sounds minimum):

| Sound | Trigger |
|-------|---------|
| `ui_click.ogg` | Any button press |
| `ui_confirm.ogg` | Build room confirmed |
| `ui_deny.ogg` | Cannot afford room |
| `room_build.ogg` | Room placed on grid |
| `day_end.ogg` | End day button |
| `event_popup.ogg` | Event notification fires |
| `mission_deploy.ogg` | Squad deploys |
| `mission_success.ogg` | Extraction reached |
| `mission_fail.ogg` | Squad wiped |
| `interrogation_start.ogg` | Interrogation session begins |
| `power_low.ogg` | Power below 20% capacity |
| `security_low.ogg` | Security below 20 |
| `game_over.ogg` | Lose condition triggered |
| `amb_base_idle.ogg` | Base view ambient loop |
| `amb_tactical.ogg` | Tactical view ambient loop |
| `footstep_metal.ogg` | Operative moves on tactical map |
| `guard_alert.ogg` | Guard detects operative |
| `notification_control.ogg` | Control message received |

Implementation: `AudioManager.gd` autoload singleton, plays sounds by string key:
```gdscript
# AudioManager.gd
extends Node

var _sounds: Dictionary = {}

func _ready():
    _load_all("res://assets/audio/sfx/")

func play(sound_id: String, volume_db: float = 0.0):
    if not _sounds.has(sound_id):
        push_warning("AudioManager: sound not found: %s" % sound_id)
        return
    var player = AudioStreamPlayer.new()
    add_child(player)
    player.stream = _sounds[sound_id]
    player.volume_db = volume_db
    player.play()
    player.finished.connect(player.queue_free)
```

No music in Phase 1. Music (4 tracks) added in Phase 2 alongside art pass.

---

**CONCERN 4 — Power tier deadlock (Generator exceeds capacity)**

Client caught a genuine logic deadlock. Fixed with graceful degradation rules:

```
POWER SHORTFALL RESOLUTION (in order):

1. Calculate deficit = power_used - power_capacity

2. If deficit > 0:
   a. Shut down Tier 3 rooms first (comfort)
   b. Recalculate deficit
   
3. If deficit still > 0:
   a. Shut down Tier 2 rooms (important)
   b. Recalculate deficit

4. If deficit still > 0 (Tier 1 rooms alone exceed capacity):
   a. DO NOT shut down Generator (circular dependency)
   b. All rooms (except Generator) run at reduced efficiency:
      efficiency = power_capacity / (power_used - generator_output)
   c. Efficiency < 50%: trigger "brownout" event — player must fix or rooms degrade
   d. Efficiency < 20%: emergency shutdown — all non-generator rooms forced offline
      Player notified: "Critical power failure. Facility systems offline."

5. If Generator itself is the only room and power_used > power_capacity:
   IMPOSSIBLE — Generator produces power, does not consume it.
   Generator Room power_consumption = 0 (it IS the power source).
   This case cannot occur by design.
```

Additional fix: Generator Room entry in `rooms.json` corrected:
```json
{ "id": "generator", "name": "Generator Room", "cost": 2000,
  "power_consumption": 0, "power_production": 50, "oxygen_consumption": 5, "tier": 1 }
```

`power_consumption` and `power_production` are now separate fields. `power_capacity` = sum of all `power_production` values. `power_used` = sum of all `power_consumption` values. No circular dependency possible.

---

**CONCERN 5 — EventSystem trigger/selection contract undefined**

Client provided a pseudocode implementation. We are adopting it with two improvements:

```gdscript
# EventSystem.gd
extends Node

var _events: Array = []
var _last_fired: Dictionary = {}  # event_id -> day number
var _active_flags: Array = []

func _ready():
    var file = FileAccess.open("res://data/events.json", FileAccess.READ)
    _events = JSON.parse_string(file.get_as_text())

func select_event(phase: String) -> Dictionary:
    var candidates = []
    for event in _events:
        if event.trigger != phase:
            continue
        # Cooldown check (default 3 days if not specified)
        var cooldown = event.get("cooldown_days", 3)
        var last = _last_fired.get(event.id, -999)
        if DayCycle.current_day - last < cooldown:
            continue
        # Flag requirement check (NEW — some events require prior flags)
        var required_flag = event.get("requires_flag", "")
        if required_flag != "" and not _active_flags.has(required_flag):
            continue
        candidates.append(event)

    if candidates.is_empty():
        return {}

    # Weighted random
    var total_weight = 0.0
    for e in candidates:
        total_weight += float(e.weight)
    var roll = randf_range(0.0, total_weight)
    var accumulator = 0.0
    for e in candidates:
        accumulator += float(e.weight)
        if roll <= accumulator:
            _last_fired[e.id] = DayCycle.current_day
            return e

    return candidates.back()

func apply_event_choice(event: Dictionary, choice_index: int):
    var choice = event.choices[choice_index]
    for change in choice.stat_changes:
        ResourceManager.add(change.resource, float(change.amount))
    for flag in choice.flags:
        if not _active_flags.has(flag):
            _active_flags.append(flag)

func trigger(event_id: String):
    # Direct trigger bypasses weight/cooldown — used by MoralTracker thresholds
    for event in _events:
        if event.id == event_id:
            _last_fired[event_id] = DayCycle.current_day
            emit_signal("event_fired", event)
            return
```

**Two improvements over client's pseudocode:**
1. `requires_flag` field — some events should only fire after prior events set a flag (e.g. "Control questions judgment" should only fire after player has made at least 3 moral choices)
2. `apply_event_choice()` — client's version showed selection only. Applying the choice (stat changes + flags) must be in EventSystem, not scattered in UI code.

Add `cooldown_days` and `requires_flag` to `events.json` schema:
```json
{
  "id": "event_006",
  "title": "Control Questions Your Judgment",
  "trigger": "morning_phase",
  "weight": 5,
  "cooldown_days": 5,
  "requires_flag": "moral_choice_made_3x",
  "flavor": "...",
  "choices": [...]
}
```

---

### 🟡 MEDIUM

---

**CONCERN 6 — Performance architecture for Phase 2**

Already addressed by GridMap decision (Q5 above). Additional notes:

- Room objects: each room is a `GridMap` tile (1 draw call) + a `Node3D` child with minimal props (2-3 MeshInstance3D max). No individual room exceeds 5 draw calls.
- Tactical map: tile data stored in `TacticalMap` class as a 2D array of `TileData` objects — not individual scene nodes. Visual tiles rendered via GridMap.
- Navigation: `NavigationServer3D` baked once per map load, not per-frame.
- Target: Phase 1 < 80 draw calls on base view. Phase 2 < 200. Steam Deck limit ~300 at 800p 60fps.

Will profile at Week 10 milestone. If over budget, switch from individual props to MultiMeshInstance3D.

---

**CONCERN 7 — RoomDatabase: JSON vs .tres**

Client raised this as a medium concern. Decision made: **Godot `.tres` resources.**

Reasons client is correct:
- Type safety catches `"power_consumptoin"` typos at load time
- Inspector editing means designers can tweak balance without touching code
- Autocomplete in GDScript via `class_name RoomData`

Implementation:

```gdscript
# RoomData.gd
extends Resource
class_name RoomData

@export var id: String = ""
@export var display_name: String = ""
@export var cost: int = 0
@export var power_consumption: float = 0.0
@export var power_production: float = 0.0
@export var oxygen_consumption: float = 0.0
@export var tier: int = 2
@export var description: String = ""
@export var unlock_condition: String = ""  # e.g. "has_room:command_center"
```

Each room is a `.tres` file in `resources/rooms/`:
```
resources/
  rooms/
    command_center.tres
    barracks.tres
    containment_cell.tres
    generator.tres
    armory.tres
```

`RoomDatabase.gd` loads all `.tres` files in that folder at startup:
```gdscript
func _ready():
    var dir = DirAccess.open("res://resources/rooms/")
    dir.list_dir_begin()
    var file = dir.get_next()
    while file != "":
        if file.ends_with(".tres"):
            var room = load("res://resources/rooms/" + file) as RoomData
            if room:
                _db[room.id] = room
        file = dir.get_next()
```

**Note:** Events remain in `events.json` — narrative data changes frequently during development and JSON is easier to edit for content than `.tres`. Only structural/balance data (rooms) goes to `.tres`.

---

## NEW ISSUES FOUND INTERNALLY (Dev Team)

Issues not raised by client that we identified during response preparation.

### 🔴 NEW CRITICAL

**NEW-7 — CameraManager not defined, only mentioned**

Doc 6 introduced `CameraManager` as an autoload but never defined it. It needs to exist before Week 13 (tactical scene switch).

```gdscript
# CameraManager.gd
extends Node

var _base_camera: Camera3D
var _tactical_camera: Camera3D
var _current: String = "base"

func register_base_camera(cam: Camera3D):
    _base_camera = cam

func register_tactical_camera(cam: Camera3D):
    _tactical_camera = cam

func switch_to_tactical():
    if _base_camera: _base_camera.current = false
    if _tactical_camera: _tactical_camera.current = true
    _current = "tactical"
    emit_signal("camera_switched", "tactical")

func switch_to_base():
    if _tactical_camera: _tactical_camera.current = false
    if _base_camera: _base_camera.current = true
    _current = "base"
    emit_signal("camera_switched", "base")

signal camera_switched(mode: String)
```

Add to autoload order between EventSystem and DayCycle.

---

**NEW-8 — FacilityManager has no room removal / demolition system**

Doc 6 defined `FacilityManager.build_room()` but never defined `demolish_room()`. Without it:
- Player cannot fix mistakes (wrong room placed)
- No room repair system (from damage rules in spec)
- Power/O₂ consumption never decreases

```gdscript
func demolish_room(tile: Vector2i, floor: int) -> bool:
    for i in range(built_rooms.size()):
        var r = built_rooms[i]
        if r.tile == tile and r.floor == floor:
            # Refund 50% of cost
            var room_data = RoomDatabase.get(r.id)
            ResourceManager.add("budget", room_data.cost * 0.5)
            # Remove resource consumption
            ResourceManager.resources["power_used"] -= r.power_consumption
            ResourceManager.resources["oxygen_used"] -= r.oxygen_consumption
            # Remove cap modifier if applicable (e.g. Storage Room)
            if r.id == "storage_room":
                ResourceManager.add_cap_modifier("budget", -5000)
            built_rooms.remove_at(i)
            emit_signal("room_demolished", tile, floor)
            return true
    return false
```

---

### 🟠 NEW HIGH

**NEW-9 — No GameState singleton**

Doc 6's lose condition code calls `GameState.trigger_game_over("exposure")` but `GameState` was never defined. This is the top-level state machine for the game.

```gdscript
# GameState.gd
extends Node

enum State { MAIN_MENU, BASE_PHASE, MISSION_BRIEFING, TACTICAL_MISSION, DEBRIEF, GAME_OVER, VICTORY }

var current_state: State = State.MAIN_MENU

signal state_changed(new_state: State)

func trigger_game_over(reason: String):
    current_state = State.GAME_OVER
    emit_signal("state_changed", State.GAME_OVER)
    # UI listens to this signal and shows Game Over screen with reason
    EventBus.emit_signal("game_over", reason)

func transition_to(new_state: State):
    current_state = new_state
    emit_signal("state_changed", new_state)
```

Add to autoload order as the first singleton — everything can emit to it.

---

**NEW-10 — No EventBus / Signal Bus**

Singletons are emitting signals to each other directly, creating tight coupling. Example: `DayCycle` calling `EventSystem`, `EventSystem` calling `ResourceManager`, `MoralTracker` calling `EventSystem.trigger()`.

If any singleton is renamed or restructured, all callers break.

Fix: Add a lightweight `EventBus.gd` autoload — a pure signal relay:

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
```

All singletons emit to `EventBus` and subscribe to `EventBus`. No singleton holds a direct reference to another. This decouples the entire system — any singleton can be replaced without touching others.

Updated autoload order:
```
1. EventBus          ← pure signals, no dependencies
2. RoomDatabase      ← loads .tres files
3. ResourceManager   ← emits to EventBus
4. FacilityManager   ← emits to EventBus, reads ResourceManager
5. OperativeManager  ← emits to EventBus, reads ResourceManager
6. MoralTracker      ← emits to EventBus, reads ResourceManager
7. EventSystem       ← emits to EventBus, reads all above
8. DayCycle          ← emits to EventBus, calls EventSystem
9. GameState         ← listens to EventBus, controls scene transitions
10. SaveManager      ← reads all singletons on save, writes all on load
11. AudioManager     ← listens to EventBus, plays sounds
12. TutorialManager  ← listens to EventBus, fires popups
13. CameraManager    ← no dependencies
```

This is the most important architectural improvement in this document. It costs 1 day to implement and saves weeks of refactoring later.

---

### 🟡 NEW MEDIUM

**NEW-11 — No Main Menu scene planned**

18-week plan goes straight from "project setup" to "ResourceManager." There is no main menu. When the game launches, what scene loads?

Add to Week 1:
- `MainMenu.tscn` — New Game, Continue, Quit buttons
- `New Game` → creates fresh save, loads `Main.tscn`
- `Continue` → loads most recent save file
- `Quit` → exits

This takes 1 day and prevents the "game crashes on launch because no save exists" bug.

---

## UPDATED AUTOLOAD ORDER (Final)

```
CONFIRMED LOAD ORDER:
1.  EventBus           ← NEW — signal relay
2.  RoomDatabase       ← .tres loader
3.  ResourceManager    ← economy
4.  FacilityManager    ← room placement
5.  OperativeManager   ← personnel
6.  MoralTracker       ← alignment
7.  EventSystem        ← narrative events
8.  DayCycle           ← time cycle
9.  GameState          ← NEW — state machine
10. SaveManager        ← persistence
11. AudioManager       ← NEW — sound
12. TutorialManager    ← onboarding
13. CameraManager      ← NEW — camera switching
```

---

## REVISED TIMELINE (Final — 20 weeks with buffer)

| Week | Deliverable | Buffer |
|------|-------------|--------|
| 1 | Project setup, git repo, EventBus, GameState, MainMenu, RoomDatabase (.tres) | — |
| 2 | ResourceManager (full), AudioManager stub | — |
| 3 | FacilityManager, OperativeManager stub, demolish system | — |
| 4 | **MILESTONE 1** — all singletons load, resources tracked, unit tests pass | +1 week buffer |
| 5 | GridSystem — 8x8 GridMap, click select, collision detection | — |
| 6 | Room placement — 5 rooms, power/O₂ routing, adjacency detection | — |
| 6.5 | Audio — 18 SFX sourced and wired to EventBus signals | — |
| 7 | DayCycle — full phase cycle, resource application, shortfall handling | — |
| 8 | HUD — all resources display via EventBus signals | — |
| 9 | EventSystem — .json load, weighted random, cooldown, flags | — |
| 10 | **MILESTONE 2** — base loop playable, doc 7 submitted for review | +1 week buffer |
| 11 | Operative system — stats, stress, loyalty, Personnel screen | — |
| 12 | Detainee system — 1 slot, psychological interrogation, Intel extraction | — |
| 13 | Tactical mission — 8x8 GridMap map, movement, 3 guards, objective/extraction | — |
| 14 | Win/lose conditions + Game Over screen + CameraManager integration | — |
| 15 | TutorialManager — Day 1 scripted sequence | — |
| 16 | SaveManager — save/load, version migration | — |
| 17 | Full regression test — run checklist, fix all failures | — |
| 18 | Polish pass — SFX gaps, UI consistency, performance profile | — |
| 19-20 | **BUFFER** — illness, blockers, scope creep absorption | +2 weeks |
| 20 | **PHASE 1 COMPLETE** — loop runs clean, client demo build delivered | — |

---

## UPDATED READINESS SCORE

| Category | Doc 4 | Doc 6 | Doc 8 | Change |
|----------|-------|-------|-------|--------|
| System definitions | 6/10 | 9/10 | 10/10 | EventBus, GameState, CameraManager, AudioManager defined |
| Code correctness | 5/10 | 8/10 | 9/10 | Power production/consumption split, demolish system |
| Data architecture | 4/10 | 8/10 | 9/10 | .tres for rooms, JSON for events, split justified |
| Test coverage | 2/10 | 7/10 | 7/10 | No change — checklist holds |
| Onboarding | 0/10 | 6/10 | 7/10 | MainMenu added |
| Architecture | 3/10 | 6/10 | 9/10 | EventBus decouples all singletons |
| **Overall** | **3.4/10** | **7.6/10** | **8.5/10** | |

---

## WHAT IS STILL OPEN

Two items remain unresolved and will not be resolved until their scheduled weeks:

| Item | Owner | Due |
|------|-------|-----|
| Real artist quotes (3 minimum) | Dev | Week 6 |
| `7-tactical_mission_design.md` | Dev | Week 10 |

Everything else is resolved, documented, and code-ready.

---

## FINAL STATEMENT

The architecture is now clean. EventBus decouples all systems. GameState owns scene transitions. CameraManager owns view switching. RoomDatabase uses typed .tres resources. AudioManager wires sound to signals. Every singleton has a defined load order.

**Week 1 action items in order:**
1. `git init` → push to GitHub → invite client (read-only)
2. Create Godot 4.3 project
3. Create autoload stubs for all 13 singletons (empty scripts, correct load order)
4. Create `resources/rooms/` folder, write 5 `.tres` files
5. Create `MainMenu.tscn` with New Game / Continue / Quit
6. First commit: "Week 1 scaffold complete"

**Score is 8.5/10. The remaining 1.5 points are in artist quotes and tactical mission design — both scheduled.**

Next document: `7-tactical_mission_design.md` (submitted at Week 10 milestone)
Parallel track: `9-factions.md` (client provides names, dev writes doc)
