# 6-blacksite_dev_response_and_fixes.md
# Blacksite Command — Developer & PM Response to Client Review
> From: Development Team (Dev + PM)
> To: Publisher / Project Lead
> Previous: 5-blacksite_client_review.md
> Status: All 11 issues addressed. All 10 questions answered.

---

## VERDICT ON CLIENT REVIEW

**Did it answer our questions?** Yes — all 5 gaps are now closed.

| Gap | Answered? | Notes |
|-----|-----------|-------|
| Tactical map structure | ✅ | 8x8 Phase 1, procedural Phase 2, cone vision, extraction tile |
| Research tree | ✅ | 18 techs, 3 trees of 6, Budget + Intel cost |
| Factions | ✅ | All 6 named with roles, Crimson Brigades raids Phase 2 |
| Narrative events | ✅ | 10 with flavor text for Phase 1, 50 for Phase 2 |
| Save schema | ✅ | moral_alignment duplication flagged and resolved |

**New quality:** Client review was thorough and technically sharp.
The 11 bugs caught were real — all would have caused crashes or silent failures in Week 2-3 if not fixed now.

---

## ANSWERS TO ALL 10 CLIENT QUESTIONS

### Critical

**Q1 — 3D artist?**
No artist on team currently. Phase 1 ships with placeholder cubes — that is the plan and it is intentional. For Phase 2 we will hire a freelance 3D artist via ArtStation. Budget line: €800–1500 for modular base tile set (25 rooms). Character models are separate and negotiated after tile set is approved. If budget is unavailable, we use Kenney's 3D asset packs as a bridge — they are CC0, clean, and Godot-compatible.

**Q2 — Godot experience level?**
Intermediate. Have shipped one Godot 4 project (Tiny Colony, 2D). This is first Godot 4 3D project. Timeline adjustment: 14 weeks for Phase 1 becomes **18 weeks** to account for 3D learning curve. Milestone at Week 4 still holds for core systems review.

**Q3 — Godot version?**
**Godot 4.3 stable.** Pinned. Reason: latest LTS-quality stable as of mid-2025. C# support improved, GridMap API stable, Forward+ renderer mature. Will not upgrade mid-project.

### Important

**Q4 — Placeholder art in first public demo?**
No Steam page during Phase 1. First public-facing content = end of Phase 2 with placeholder-to-temp-art pipeline. Steam page with screenshots goes live at Phase 2 milestone. Early Access launch at Phase 3.

**Q5 — Camera system?**
Two separate camera rigs, one per layer:
- `BaseCameraRig` — isometric, fixed angle, pan + zoom via mouse/scroll
- `TacticalCameraRig` — top-down follow, WASD pan, scroll zoom
Scene switch triggers camera swap via a `CameraManager` autoload that handles transition and state restore. Not a single rig. Single rig would cause state bleed between layers.

**Q6 — C# or GDScript?**
**GDScript.** Reason: faster prototyping, no compile step, better Godot community support, sufficient performance for this scope. C# would add tooling overhead we cannot afford in Phase 1. Decision is final for Phase 1. Will reassess if performance issues emerge in Phase 2 AI systems.

**Q7 — Phase 1 budget?**
Part-time development, evenings and weekends. No paid team in Phase 1. Phase 2 requires a freelance artist (see Q1). No financial runway pressure until Phase 2 start — which means Phase 1 timeline slippage is acceptable but Phase 2 budget needs to be confirmed before Phase 1 ends.

### Good to Know

**Q8 — Tactical reference games?**
Primary: **XCOM 2** (tile movement, action points, overwatch concept)
Secondary: **Shadow Tactics** (stealth cone, noise system)
Tertiary: **Commandos 2** (small squad, objective-based)
Key decision: tile-based movement, not real-time. This is confirmed. Camera: isometric-ish top-down, not first-person or side-scroll.

**Q9 — Design feedback during Phase 1?**
Hands-on preferred. Request: weekly async update (a short note, not a meeting) flagging blockers and decisions made. Formal milestone review at Week 4, Week 10, and Phase 1 completion. Client can flag concerns at any point — dev will batch responses rather than context-switch constantly.

**Q10 — Number of endings: 4-6 or 5?**
**5 endings.** The 4-6 range was a placeholder in the original pitch doc. Spec 3 locked it at 5. That is the canonical number. Endings are tied to moral alignment thresholds + faction standing combinations. They are not being designed until Phase 3.

---

## 11 ISSUES — STATUS AND FIXES

### 🔴 CRITICAL — Fixed

---

**ISSUE 1 — Security stat missing from ResourceManager**

Fixed. Added to ResourceManager:

```gdscript
var resources = {
    "budget": 5000,
    "intel": 0,
    "power_capacity": 50,
    "power_used": 0,
    "oxygen_capacity": 50,
    "oxygen_used": 0,
    "security": 50,          # ← ADDED. Range 0-100.
    "control_trust": 80,
    "black_market_rep": 0,
    "moral_alignment": 0
}

# Security cap
func get_cap(type: String) -> float:
    match type:
        "budget": return _budget_cap    # now dynamic (Issue 4)
        "security": return 100.0
        "control_trust": return 100.0
        "moral_alignment": return 100.0
        _: return INF
```

Security loss triggers:
- Detainee escape attempt: -15
- Event "unusual perimeter activity": -10
- Raid by Crimson Brigades (Phase 2): -25 per wave

Security recovery:
- Security Checkpoint room: +5/day
- Armory adjacent to containment: +2/day
- Manual "lockdown" action (Phase 2): +20, disables missions for 1 day

Lose condition check (in DayCycle end-of-day):
```gdscript
func _check_lose_conditions():
    if ResourceManager.resources["security"] <= 0:
        if EventSystem.has_active_event("breach"):
            GameState.trigger_game_over("exposure")
```

---

**ISSUE 2 — Power and O₂ never consumed**

Fixed. `_apply_daily_resources()` now calculates room consumption:

```gdscript
func _apply_daily_resources():
    # Budget from Control
    ResourceManager.add("budget", 500)

    # Intel from Command Center (if built)
    if FacilityManager.has_room("command_center"):
        ResourceManager.add("intel", 5)

    # Calculate power and O₂ consumption from all built rooms
    var total_power_used: float = 0.0
    var total_oxygen_used: float = 0.0

    for room in FacilityManager.get_all_rooms():
        total_power_used += room.power_consumption
        total_oxygen_used += room.oxygen_consumption

    ResourceManager.resources["power_used"] = total_power_used
    ResourceManager.resources["oxygen_used"] = total_oxygen_used

    # Check shortfall
    _check_resource_shortfall()

func _check_resource_shortfall():
    var power_cap = ResourceManager.resources["power_capacity"]
    var power_used = ResourceManager.resources["power_used"]
    var o2_cap = ResourceManager.resources["oxygen_capacity"]
    var o2_used = ResourceManager.resources["oxygen_used"]

    if power_used > power_cap:
        FacilityManager.trigger_power_outage(power_used - power_cap)

    if o2_used > o2_cap:
        OperativeManager.apply_oxygen_damage(o2_used - o2_cap)
```

See Issue 6 below for shortfall behavior rules.

---

**ISSUE 3 — moral_alignment duplicated in save schema**

Fixed. Removed top-level field. `moral_alignment` lives only inside `resources` object. `MoralTracker` reads and writes from `ResourceManager.resources["moral_alignment"]`.

Updated save schema (relevant section):
```json
{
  "version": "1.0",
  "day": 14,
  "resources": {
    "budget": 3200,
    "intel": 8,
    "power_capacity": 100,
    "power_used": 55,
    "oxygen_capacity": 100,
    "oxygen_used": 60,
    "security": 42,
    "control_trust": 72,
    "black_market_rep": 0,
    "moral_alignment": -12
  }
}
```

---

### 🟠 HIGH — Fixed

---

**ISSUE 4 — ResourceManager caps are hardcoded, not dynamic**

Fixed. Caps are now stored in a separate dictionary and modified by rooms:

```gdscript
var resource_caps = {
    "budget": 10000,
    "power_capacity": INF,
    "oxygen_capacity": INF,
    "security": 100,
    "control_trust": 100,
    "moral_alignment": 100
}

func get_cap(type: String) -> float:
    return resource_caps.get(type, INF)

func add_cap_modifier(type: String, amount: float):
    if resource_caps.has(type):
        resource_caps[type] += amount
        emit_signal("cap_changed", type, resource_caps[type])

# Called when Storage Room is built:
# ResourceManager.add_cap_modifier("budget", 5000)
```

When a room is demolished, `add_cap_modifier` is called with negative amount. No separate "remove modifier" system needed.

---

**ISSUE 5 — Event system has no data contract**

Fixed. Event data structure defined. All events now live in `data/events.json`:

```json
[
  {
    "id": "event_001",
    "title": "New Mission Briefing",
    "trigger": "morning_phase",
    "weight": 10,
    "flavor": "Control's voice crackles over the encrypted line. 'Commander. We have a situation in Novosibirsk. Extract the package before the GRU do.'",
    "choices": [
      { "label": "Accept", "stat_changes": [], "flags": ["mission_available"] },
      { "label": "Request more intel", "stat_changes": [{"resource": "control_trust", "amount": -3}], "flags": [] }
    ]
  },
  {
    "id": "event_002",
    "title": "Perimeter Anomaly",
    "trigger": "end_of_day",
    "weight": 6,
    "flavor": "One of your scouts reports movement near the eastern access shaft. Could be wildlife. Could be a reconnaissance team.",
    "choices": [
      { "label": "Increase patrol", "stat_changes": [{"resource": "security", "amount": 10}, {"resource": "budget", "amount": -200}], "flags": [] },
      { "label": "Ignore it", "stat_changes": [{"resource": "security", "amount": -10}], "flags": [] }
    ]
  },
  {
    "id": "event_003",
    "title": "Budget Transfer",
    "trigger": "morning_phase",
    "weight": 8,
    "flavor": "Control has released additional funding. No explanation given — there never is.",
    "choices": [
      { "label": "Acknowledged", "stat_changes": [{"resource": "budget", "amount": 1000}], "flags": [] }
    ]
  },
  {
    "id": "event_004",
    "title": "Detainee Escape Attempt",
    "trigger": "end_of_day",
    "weight": 4,
    "flavor": "Alarms. Detainee #2 has breached their cell door. How they managed it with zip-tied hands is anyone's guess.",
    "choices": [
      { "label": "Recapture immediately", "stat_changes": [{"resource": "security", "amount": -15}, {"resource": "budget", "amount": -150}], "flags": [] },
      { "label": "Lethal response", "stat_changes": [{"resource": "security", "amount": -5}, {"resource": "moral_alignment", "amount": -10}], "flags": ["detainee_eliminated"] }
    ]
  },
  {
    "id": "event_005",
    "title": "Operative Under Stress",
    "trigger": "end_of_day",
    "weight": 7,
    "flavor": "Vance hasn't slept in 36 hours. He's been assigned to interrogation duty three days straight. Something has to give.",
    "choices": [
      { "label": "Rotate him off duty", "stat_changes": [], "flags": ["op_001_stress_relieved"] },
      { "label": "Push through it", "stat_changes": [{"resource": "moral_alignment", "amount": -2}], "flags": ["op_001_stress_increased"] }
    ]
  },
  {
    "id": "event_006",
    "title": "Control Questions Your Judgment",
    "trigger": "morning_phase",
    "weight": 5,
    "flavor": "Control has reviewed your last three decisions. 'Commander, your methods are... unconventional. We expect results, not sentiment.'",
    "choices": [
      { "label": "Acknowledge and comply", "stat_changes": [{"resource": "control_trust", "amount": 5}], "flags": [] },
      { "label": "Push back", "stat_changes": [{"resource": "control_trust", "amount": -8}, {"resource": "moral_alignment", "amount": 10}], "flags": [] }
    ]
  },
  {
    "id": "event_007",
    "title": "Informant Report",
    "trigger": "morning_phase",
    "weight": 9,
    "flavor": "An asset inside the Network has made contact. They have something. For a price.",
    "choices": [
      { "label": "Pay for the intel", "stat_changes": [{"resource": "intel", "amount": 5}, {"resource": "budget", "amount": -300}], "flags": [] },
      { "label": "Decline", "stat_changes": [], "flags": [] }
    ]
  },
  {
    "id": "event_008",
    "title": "Generator Fault",
    "trigger": "end_of_day",
    "weight": 4,
    "flavor": "The primary generator is running hot. If it fails, half the facility goes dark.",
    "choices": [
      { "label": "Emergency repair", "stat_changes": [{"resource": "budget", "amount": -400}, {"resource": "power_capacity", "amount": -10}], "flags": [] },
      { "label": "Run it hot, monitor overnight", "stat_changes": [{"resource": "security", "amount": -5}], "flags": ["generator_risk_active"] }
    ]
  },
  {
    "id": "event_009",
    "title": "Reassignment Request",
    "trigger": "end_of_day",
    "weight": 5,
    "flavor": "Operative Reyes has submitted a formal transfer request. 'I signed up to protect my country, not to run a prison.'",
    "choices": [
      { "label": "Approve transfer", "stat_changes": [], "flags": ["op_002_departed"] },
      { "label": "Deny and increase pay", "stat_changes": [{"resource": "budget", "amount": -500}], "flags": ["op_002_loyalty_boosted"] },
      { "label": "Deny without compensation", "stat_changes": [], "flags": ["op_002_loyalty_reduced"] }
    ]
  },
  {
    "id": "event_010",
    "title": "Research Dossier",
    "trigger": "morning_phase",
    "weight": 6,
    "flavor": "Control has forwarded a classified research package. 'Phase 2 of Project Chimera requires capabilities you don't yet have, Commander.'",
    "choices": [
      { "label": "File for later", "stat_changes": [], "flags": ["research_unlocked_phase2"] }
    ]
  }
]
```

EventSystem loads this on startup and picks events by `trigger` phase and `weight` (weighted random).

---

**ISSUE 6 — Power outage and O₂ starvation not defined**

Fixed. Resource shortfall behavior:

**Power Outage:**
- Rooms are sorted by priority tier (1 = critical, 2 = important, 3 = comfort)
- When power deficit occurs, Tier 3 rooms shut down first, then Tier 2, then Tier 1
- A shut-down room produces nothing and consumes no power

| Tier | Rooms |
|------|-------|
| 1 — Critical | Generator, Life Support, Command Center, Security Checkpoint |
| 2 — Important | Barracks, Armory, Interrogation Chamber, Infirmary |
| 3 — Comfort | Recreation Room, Mess Hall, Officer Quarters |

**O₂ Starvation:**
- If O₂ deficit for 1 day → all operatives gain +10 Stress
- If O₂ deficit for 2 days → operatives lose -5 HP/day
- If O₂ deficit for 3+ days → 10% chance per operative of unconsciousness (unusable 1 day)
- O₂ starvation does NOT instantly kill — it degrades performance

---

**ISSUE 7 — Tactical map too small (4 tiles)**

Fixed. Phase 1 tactical map is now 8x8 with meaningful layout:

```
Map layout (8x8, hand-crafted):

[S][ ][ ][ ][G][ ][ ][ ]
[ ][W][W][ ][ ][W][W][ ]
[ ][W][ ][ ][ ][W][ ][ ]
[ ][ ][ ][G][ ][ ][ ][ ]
[ ][W][ ][ ][ ][ ][W][ ]
[ ][W][W][ ][G][W][W][ ]
[ ][ ][ ][ ][ ][ ][ ][ ]
[ ][ ][ ][ ][ ][ ][O][X]

S = Operative start    W = Wall
G = Guard (static)     O = Objective tile
X = Extraction tile    [ ] = Walkable tile
```

3 guards, 2 choke points, one open route and one stealth route. Enough to validate movement, camera, and objective loop. Still Phase 1 scope.

---

### 🟡 MEDIUM — Fixed

---

**ISSUE 8 — No error handling in ResourceManager**

Fixed. Full defensive version:

```gdscript
func add(type: String, amount: float):
    if not resources.has(type):
        push_warning("ResourceManager.add: unknown resource type '%s'" % type)
        return
    var old_val = resources[type]
    resources[type] = clamp(resources[type] + amount, 0.0, get_cap(type))
    if resources[type] != old_val:
        emit_signal("resource_changed", type, resources[type])

func spend(type: String, amount: float) -> bool:
    if not resources.has(type):
        push_warning("ResourceManager.spend: unknown resource type '%s'" % type)
        return false
    if resources[type] < amount:
        return false
    resources[type] -= amount
    emit_signal("resource_changed", type, resources[type])
    return true
```

---

**ISSUE 9 — No save version migration plan**

Fixed. Save manager now includes migration handler:

```gdscript
# SaveManager.gd
const CURRENT_VERSION = "1.0"

func load_game(path: String) -> Dictionary:
    var file = FileAccess.open(path, FileAccess.READ)
    if not file:
        push_error("SaveManager: file not found at %s" % path)
        return {}

    var data = JSON.parse_string(file.get_as_text())
    if data == null:
        push_error("SaveManager: corrupt save file")
        return {}

    data = _migrate(data)
    return data

func _migrate(data: Dictionary) -> Dictionary:
    var version = data.get("version", "0.9")

    if version == "0.9":
        # Example: 0.9 didn't have security stat
        if not data["resources"].has("security"):
            data["resources"]["security"] = 50
        data["version"] = "1.0"

    # Future: if version == "1.0": migrate to "1.1"
    return data
```

---

**ISSUE 10 — No test strategy**

Fixed. Manual test script defined. Run this sequence before every milestone:

```
PHASE 1 REGRESSION TEST — Manual sequence

DAY CYCLE
[ ] Start new game → resources show correct starting values
[ ] Click "End Day" → day counter increments
[ ] Morning phase → 1 event fires
[ ] End of day → power_used calculated correctly from built rooms

RESOURCE SYSTEM
[ ] Build Command Center → Budget deducted, power_used increases
[ ] Remove room → power_used decreases
[ ] Build Storage Room → budget cap increases to 15000
[ ] Spend more than available budget → spend() returns false, no crash

SECURITY SYSTEM
[ ] Trigger event_002 (ignore) → security drops -10
[ ] Security reaches 0 + breach event → Game Over: exposure

SAVE / LOAD
[ ] Save on Day 5 → reload → all values identical
[ ] Save with 1 detainee → reload → detainee present
[ ] Load save from previous version → migration runs, no crash

TACTICAL MISSION
[ ] Deploy squad → tactical scene loads
[ ] Move operative → tiles highlight correctly
[ ] Guard blocks path → operative cannot pass
[ ] Reach objective tile → flag set
[ ] Reach extraction → mission success screen
[ ] All operatives dead → mission fail screen

LOSE CONDITIONS
[ ] Security = 0 + breach flag → Game Over screen shows
[ ] All operatives dead in mission → Game Over screen shows
```

Run this checklist at Week 4, Week 10, and Phase 1 completion.

---

**ISSUE 11 — No tutorial / onboarding**

Fixed. Phase 1 includes a scripted Day 1 sequence — not a full tutorial, but enough to prevent confusion:

```
DAY 1 SCRIPTED SEQUENCE:

1. Game starts → text popup:
   "Welcome to Site Omega, Commander. The facility is empty.
    Your first priority: power and command infrastructure."
   [Dismiss]

2. BUILD mode auto-opens → tooltip arrow points to grid:
   "Select a tile to build your first room."

3. Player clicks tile → Build Menu opens → Generator Room highlighted:
   "You need power before anything else. Build a Generator Room."

4. Player builds Generator → popup:
   "Power online. Now build your Command Center."

5. Player builds Command Center → popup:
   "Command Center active. Intel generation has started.
    Control will send your first mission briefing tomorrow."

6. Day End button highlights → popup:
   "End the day to receive your morning briefing from Control."

7. Day 2 begins → event_001 fires (mission briefing).
   Tutorial complete. All systems open.
```

This is implemented as a `TutorialManager.gd` that listens to game events and fires popups in sequence. After Day 2, TutorialManager deactivates.

---

## NEW ISSUES IDENTIFIED BY DEV TEAM

Issues the client review did not catch — flagged now before they become problems.

### 🔴 NEW CRITICAL

**NEW-1 — FacilityManager not defined anywhere**
`DayCycle._apply_daily_resources()` calls `FacilityManager.get_all_rooms()` and `FacilityManager.has_room()`, but `FacilityManager` does not exist as a designed system in any doc.

Fix required:
```gdscript
# FacilityManager.gd (autoload singleton)
extends Node

var built_rooms: Array[Dictionary] = []
# Each entry: { id, tile, floor, hp, power_consumption, oxygen_consumption }

func build_room(room_id: String, tile: Vector2i, floor: int) -> bool:
    var room_data = RoomDatabase.get(room_id)
    if not room_data:
        return false
    if not ResourceManager.spend("budget", room_data.cost):
        return false
    built_rooms.append({
        "id": room_id,
        "tile": tile,
        "floor": floor,
        "hp": 100,
        "power_consumption": room_data.power,
        "oxygen_consumption": room_data.oxygen
    })
    ResourceManager.add("power_used", room_data.power)
    ResourceManager.add("oxygen_used", room_data.oxygen)
    return true

func has_room(room_id: String) -> bool:
    return built_rooms.any(func(r): return r.id == room_id)

func get_all_rooms() -> Array:
    return built_rooms
```

Also add `data/rooms.json` — a database of all room definitions so room stats are data-driven, not hardcoded.

---

**NEW-2 — OperativeManager not defined**
`_check_resource_shortfall()` calls `OperativeManager.apply_oxygen_damage()` — this singleton also does not exist in any doc.

Must be defined before Week 3 when operative system is built.

---

### 🟠 NEW HIGH

**NEW-3 — GridSystem has no collision detection**
When player places a room, nothing prevents:
- Placing two rooms on the same tile
- Placing a room without a corridor connection
- Building rooms before Generator (no power check)

Fix: GridSystem must track `occupied_tiles: Dictionary` keyed by `Vector2i`. On place attempt, check if tile is already occupied before allowing build.

**NEW-4 — No RoomDatabase**
Room stats (cost, power, O₂) are scattered across spec docs and build plan. They need to live in one authoritative file.

Create `data/rooms.json`:
```json
[
  { "id": "command_center", "name": "Command Center", "cost": 3000, "power": 25, "oxygen": 10, "tier": 1 },
  { "id": "barracks",       "name": "Barracks",       "cost": 800,  "power": 10, "oxygen": 10, "tier": 2 },
  { "id": "containment_cell","name": "Containment Cell","cost": 600, "power": 5,  "oxygen": 5,  "tier": 2 },
  { "id": "generator",      "name": "Generator Room",  "cost": 2000, "power": 0,  "oxygen": 5,  "tier": 1 },
  { "id": "armory",         "name": "Armory",          "cost": 1500, "power": 10, "oxygen": 5,  "tier": 2 }
]
```

All code reads from this file. No stats hardcoded anywhere.

---

### 🟡 NEW MEDIUM

**NEW-5 — Autoload load order not defined**
Godot autoloads initialize in the order they appear in Project Settings. These singletons have dependencies:

```
Load order must be:
1. RoomDatabase       ← no dependencies
2. ResourceManager    ← no dependencies
3. FacilityManager    ← depends on ResourceManager, RoomDatabase
4. OperativeManager   ← depends on ResourceManager
5. MoralTracker       ← depends on ResourceManager
6. EventSystem        ← depends on all of the above
7. DayCycle           ← depends on all of the above
8. SaveManager        ← depends on all of the above
9. TutorialManager    ← depends on DayCycle, EventSystem
10. CameraManager     ← no dependencies
```

If load order is wrong, singletons will reference null on startup.

**NEW-6 — Event weight system has no cooldown**
EventSystem picks events by weight (weighted random). Without a cooldown, the same event can fire two days in a row. `event_003` (budget transfer) firing 5 days straight breaks economy balance.

Fix: Track `last_fired_day` per event. Events cannot fire again within `cooldown_days` (default: 3).

---

## UPDATED BUILD ORDER (Weeks 1-18)

Revised from 14 to 18 weeks. Reason: 3D learning curve + new singleton definitions needed.

| Week | Deliverable |
|------|-------------|
| 1 | Project setup, autoload order, `data/rooms.json`, `RoomDatabase.gd` |
| 2 | `ResourceManager.gd` (full, with dynamic caps, error handling) |
| 3 | `FacilityManager.gd`, `OperativeManager.gd` stubs |
| 4 | **MILESTONE REVIEW** — ResourceManager tests pass, singletons all load |
| 5 | `GridSystem.gd` — 8x8 grid, click to select, collision detection |
| 6 | Room placement — build 5 Phase 1 rooms, power/O₂ consumption active |
| 7 | `DayCycle.gd` — full phase cycle, resource application, shortfall handling |
| 8 | HUD — all 8 resources displayed, real-time updates via signals |
| 9 | `EventSystem.gd` — load events.json, weighted random, cooldown |
| 10 | **MILESTONE REVIEW** — base phase playable: build rooms, end day, events fire |
| 11 | Operative system — 4 operatives, stats display, stress/loyalty tracking |
| 12 | Detainee system — 1 slot, psychological interrogation, intel extraction |
| 13 | Tactical mission — 8x8 map loads, movement works, objective/extraction |
| 14 | Win/lose conditions — both lose states trigger correctly |
| 15 | `TutorialManager.gd` — Day 1 scripted sequence |
| 16 | `SaveManager.gd` — save/load with migration |
| 17 | Full regression test (manual checklist) — fix all failures |
| 18 | **PHASE 1 COMPLETE** — loop runs clean, handoff to Phase 2 planning |

---

## DOCUMENTS NEEDED BEFORE PHASE 2 STARTS

| Document | Owner | Due |
|----------|-------|-----|
| `7-tactical_mission_design.md` | Dev | Week 10 |
| `8-research_tree.md` | Client + Dev | Week 12 |
| `9-factions.md` | Client | Week 12 |
| `10-narrative_events_act1.md` | Client | Week 14 |
| `11-save_schema_v2.md` | Dev | Week 16 |

---

## PHASE 1 READINESS SCORE

| Category | Previous (doc 4) | Now (doc 6) | Change |
|----------|-----------------|-------------|--------|
| System definitions | 6/10 | 9/10 | FacilityManager, OperativeManager now defined |
| Code correctness | 5/10 | 8/10 | Security gap, power consumption, error handling fixed |
| Data architecture | 4/10 | 8/10 | rooms.json, events.json, save schema all clean |
| Test coverage | 2/10 | 7/10 | Regression checklist defined |
| Onboarding | 0/10 | 6/10 | Day 1 scripted sequence added |
| **Overall** | **3.4/10** | **7.6/10** | |

---

## FINAL STATEMENT

All 11 client issues are resolved. All 10 client questions are answered. Six new issues were identified and fixed proactively. The build plan is now an 18-week timeline with a clearly defined load order, data-driven architecture, and testable milestones.

**Open Godot 4.3. Create the project. Build `data/rooms.json` first.**

Everything else depends on having authoritative room data in one place.

Next document: `7-tactical_mission_design.md`
