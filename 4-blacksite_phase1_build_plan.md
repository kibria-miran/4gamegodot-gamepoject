# 4-blacksite_phase1_build_plan.md
# Blacksite Command — Phase 1 Build Plan
> Previous: 3-blacksite_upgraded_spec.md (Dev-Readiness: 8/10)
> This document: What to do NOW. Open Godot. Start building.

---

## SPEC REVIEW — DID IT ANSWER EVERYTHING?

**Short answer: Yes — 90% complete. Good enough to build Phase 1.**

| Section | Status | Notes |
|---------|--------|-------|
| Gameplay loop | ✅ Answered | Clear 8-step session flow |
| Resource system | ✅ Answered | 8 resources, sources, sinks defined |
| Facility building | ✅ Answered | 25 rooms, grid rules, adjacency, damage |
| Detainee system | ✅ Answered | Profile fields, minigame, 3 approaches |
| Operative traits | ✅ Answered | 15 traits, stress table, defection triggers |
| Moral system | ✅ Answered | -100/+100 scale, 18 events with values |
| UI wireframes | ✅ Answered | 4 screens in text wireframe format |
| Asset list | ✅ Answered | 137 models, 15 UI screens, 80 SFX |
| Milestones | ✅ Answered | 3 phases, clear deliverables |
| Platform | ✅ Answered | PC/Steam Deck, min spec, pricing |

---

## REMAINING GAPS (10% still missing)

These won't block Phase 1 but must be resolved before Phase 2:

### GAP 1 — Tactical Mission Map Structure
The spec says "procedural simple map" for Phase 1 but gives zero detail on:
- How big is one tactical map? (tile count, room count)
- Is the map hand-crafted or procedurally generated?
- How does stealth detection work mechanically? (cone of vision? noise radius?)
- How does the player "extract"? (reach a tile? survive X turns? escort a target?)

**Action required:** Write a 1-page tactical mission design doc before Phase 2.

### GAP 2 — Research Tree Not Defined
Section 2 mentions a "3-tier research tree (weapons → surveillance → bio)" for Phase 2, but no tech list exists anywhere in the spec.
- How many techs total?
- What does each unlock?
- What is the cost (Budget? Intel? Time?)

**Action required:** Write a full research tree doc before Phase 2 starts.

### GAP 3 — Faction System Not Specced
Section 4 mentions "1 of 6 factions" for detainees and §6 mentions "Faction Standing" as a moral system output — but no factions are named or defined.
- What are the 6 factions?
- How does faction standing affect gameplay?
- Can factions attack the base?

**Action required:** Write a factions doc before Act 1 narrative is written.

### GAP 4 — Narrative Events Not Written
Phase 2 requires "50 narrative events + Act 1 complete" but no single event is written in the spec. This is significant creative work.

**Action required:** Begin writing event scripts as a separate document. Target: 10 events before Phase 2 starts.

### GAP 5 — Save System Schema
Spec says "JSON" for save system but a game this complex needs a defined schema. What state gets saved? In what structure?

**Action required:** Define save schema before implementing any persistent systems.

---

## WHAT TO DO RIGHT NOW — PHASE 1 EXECUTION PLAN

**Target:** Working prototype in 3-4 months. Placeholder art. All core systems functional.

---

### STEP 1 — Godot Project Setup (Day 1-2)

```
project structure:
blacksite_command/
├── project.godot
├── scenes/
│   ├── main/
│   │   ├── Main.tscn           ← root scene
│   │   └── GameManager.gd
│   ├── base/
│   │   ├── BaseView.tscn       ← grid + camera
│   │   ├── GridSystem.gd
│   │   └── Room.tscn
│   ├── tactical/
│   │   ├── TacticalView.tscn
│   │   └── Squad.gd
│   ├── ui/
│   │   ├── HUD.tscn
│   │   ├── BuildMenu.tscn
│   │   └── MissionBriefing.tscn
│   └── systems/
│       ├── ResourceManager.gd
│       ├── DayCycle.gd
│       ├── MoralTracker.gd
│       └── EventSystem.gd
├── resources/
│   ├── rooms/
│   ├── operatives/
│   └── detainees/
├── data/
│   ├── rooms.json
│   ├── events.json
│   └── operatives.json
└── assets/
    ├── placeholder/    ← colored boxes for now
    ├── ui/
    └── audio/
```

**Project settings to set immediately:**
```
Application → Run → Main Scene: res://scenes/main/Main.tscn
Rendering → Renderer: Forward+
Display → Window → Size: 1920x1080
Display → Window → Resizable: true
Editor → Export/Serialization: Use text format (no binary .scn)
```

---

### STEP 2 — Core Systems Build Order

Build in this exact order. Do not skip ahead.

#### WEEK 1-2 — Resource Manager
The foundation everything else reads from.

```gdscript
# ResourceManager.gd (autoload singleton)
extends Node

var resources = {
    "budget": 5000,
    "intel": 0,
    "power_capacity": 50,
    "power_used": 0,
    "oxygen_capacity": 50,
    "oxygen_used": 0,
    "control_trust": 80,
    "black_market_rep": 0,
    "moral_alignment": 0
}

signal resource_changed(type, new_value)

func add(type: String, amount: float):
    resources[type] = clamp(resources[type] + amount, 0, get_cap(type))
    emit_signal("resource_changed", type, resources[type])

func spend(type: String, amount: float) -> bool:
    if resources[type] >= amount:
        resources[type] -= amount
        emit_signal("resource_changed", type, resources[type])
        return true
    return false

func get_cap(type: String) -> float:
    match type:
        "budget": return 10000
        "moral_alignment": return 100
        _: return INF
```

#### WEEK 2-3 — Grid System
```
Target:
- 8x8 grid rendered in 3D (flat colored tiles)
- Click tile → select
- Right-click → build menu popup
- Place a box (placeholder room) on tile
- Room costs Budget (calls ResourceManager.spend)
- Room tracks Power and O₂ consumption
```

#### WEEK 3-4 — 5 Placeholder Rooms
From the spec, Phase 1 rooms only:
```
1. Command Center  → generates +5 Intel/day, costs $3000, 25 power, 10 O₂
2. Barracks        → +1 operative slot, costs $800, 10 power, 10 O₂
3. Containment Cell → +1 detainee slot, costs $600, 5 power, 5 O₂
4. Generator Room  → +50 power capacity, costs $2000
5. Armory          → enables loadout screen, costs $1500, 10 power, 5 O₂
```

All rendered as colored cubes with a text label. No 3D art needed yet.

#### WEEK 4-5 — Day Cycle
```gdscript
# DayCycle.gd (autoload singleton)
extends Node

var current_day: int = 1
var phase: String = "MORNING"  # MORNING → BASE → MISSION → DEBRIEF → END_OF_DAY

signal day_started(day_number)
signal phase_changed(new_phase)
signal end_of_day(day_number)

func advance_phase():
    match phase:
        "MORNING":   phase = "BASE"
        "BASE":      phase = "MISSION"
        "MISSION":   phase = "DEBRIEF"
        "DEBRIEF":   phase = "END_OF_DAY"
        "END_OF_DAY":
            current_day += 1
            phase = "MORNING"
            emit_signal("day_started", current_day)
    emit_signal("phase_changed", phase)
    _apply_daily_resources()

func _apply_daily_resources():
    # Apply per-day resource generation from all built rooms
    ResourceManager.add("budget", 500)   # base Control allocation
    ResourceManager.add("intel", 5)      # base if Command Center built
```

#### WEEK 5-6 — Operative System (Basic)
```
Phase 1 target (minimum viable):
- 4 operatives, hardcoded
- Stats: Combat, HP, Stress, Loyalty only
- Display on Personnel screen
- Assign to mission (select 2-4 for squad)
- After mission: apply XP, stress, possible wound
```

#### WEEK 6-8 — Detainee System (Basic)
```
Phase 1 target:
- 1 detainee slot (1 Containment Cell)
- Detainee has: Name, Intel Value (1-20), Resistance (1-10), Willpower (0-100)
- Only 1 interrogation approach: Psychological
- Each session: -10 Willpower, +1-3 Intel extracted
- Post-interrogation: Release or Eliminate only (no Turn Asset yet)
```

#### WEEK 8-10 — Tactical Mission (Minimal)
```
Phase 1 target:
- 1 hand-crafted mission map (not procedural yet)
- 4 tiles: Start, Corridor, Objective Room, Extraction Point
- 2 enemy guards (static, no AI — just blocking tiles)
- Operatives move tile-to-tile (click to move)
- Reach Objective → "Intel secured" flag set
- Reach Extraction → mission success screen
- If all operatives dead → mission fail
```

This is intentionally primitive. The goal is a working loop, not polish.

#### WEEK 10-11 — Moral Tracker
```gdscript
# MoralTracker.gd (autoload singleton)
extends Node

var alignment: float = 0.0  # -100 to +100, hidden

func shift(amount: float, reason: String = ""):
    alignment = clamp(alignment + amount, -100, 100)
    _check_thresholds()

func _check_thresholds():
    if alignment > 60:
        EventSystem.trigger("control_inspector_sent")
    elif alignment < -60:
        EventSystem.trigger("black_market_full_access")
```

#### WEEK 11-12 — Event System (10 events)
```
Phase 1 events (text popup only, no visuals):

1.  "Control sends a new mission briefing." → Unlocks tactical mission
2.  "An operative reports unusual activity near the perimeter." → Security -10
3.  "Budget transfer received from Control." → +$1000
4.  "A detainee has attempted escape." → Security check (pass/fail)
5.  "An operative shows signs of stress." → Operative stress +15
6.  "Control questions your recent decisions." → Control Trust -5
7.  "An informant provides a tip." → +5 Intel
8.  "Power fluctuation in the generator." → Power capacity -10 for 1 day
9.  "An operative requests reassignment." → Loyalty check
10. "Control provides a new research dossier." → (placeholder for Phase 2 research)
```

#### WEEK 12-13 — Win/Lose Conditions
```
Lose condition 1: Base Exposure
    - Security drops to 0 AND a "breach event" fires → Game Over screen

Lose condition 2: Squad Wipe
    - All operatives dead on a mission → Game Over screen

(Other lose conditions from spec deferred to Phase 2)
```

#### WEEK 13-14 — HUD + Navigation
```
Implement 3 screens (placeholder art):
1. Base HUD — shows resources (Budget, Power, O₂, Intel, Day)
2. Build Menu — grid click → show available rooms → confirm purchase
3. Mission Briefing — show mission, select squad, deploy button
4. Post-mission debrief — show XP gained, casualties, intel earned
```

#### WEEK 14 — Save System (JSON)
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
    "control_trust": 72,
    "moral_alignment": -12
  },
  "rooms": [
    { "id": "command_center", "tile": [2, 3], "floor": 0, "hp": 100 },
    { "id": "barracks", "tile": [4, 3], "floor": 0, "hp": 100 }
  ],
  "operatives": [
    { "id": "op_001", "name": "Vance", "combat": 7, "hp": 90, "stress": 30, "loyalty": 80, "xp": 12 }
  ],
  "detainees": [
    { "id": "det_001", "name": "Viktor", "intel_value": 12, "resistance": 6, "willpower": 55, "health": 80 }
  ],
  "moral_alignment": -12,
  "events_triggered": ["event_003", "event_007"],
  "flags": {
    "act1_mission1_complete": true
  }
}
```

---

### STEP 3 — Phase 1 Deliverable Checklist

Before calling Phase 1 complete, every item must be ticked:

```
SYSTEMS
[ ] ResourceManager singleton — all 8 resources tracked
[ ] DayCycle singleton — morning/base/mission/debrief/end-of-day cycle
[ ] MoralTracker singleton — alignment shifts, 2 threshold events
[ ] EventSystem — 10 events fire correctly
[ ] GridSystem — 8x8 grid, click to place rooms, power/O₂ routing
[ ] Save/Load — JSON save writes and loads correctly

ROOMS (5)
[ ] Command Center — built, Intel generation per day works
[ ] Barracks — built, operative slot increase works
[ ] Containment Cell — built, detainee slot increase works
[ ] Generator Room — built, power capacity increase works
[ ] Armory — built, loadout screen accessible

OPERATIVE SYSTEM
[ ] 4 operatives visible in Personnel screen
[ ] Stats display: Combat, HP, Stress, Loyalty
[ ] Assign to mission squad (select 2-4)
[ ] Post-mission: XP gained, stress applied, wound flag

DETAINEE SYSTEM
[ ] 1 detainee can be held
[ ] Psychological interrogation — willpower drains, intel extracted
[ ] Release or Eliminate post-interrogation
[ ] Moral alignment shifts on each action

TACTICAL MISSION
[ ] 1 hand-crafted map loads
[ ] Operatives move tile-to-tile
[ ] 2 static enemy guards block passage
[ ] Reach objective → flag set
[ ] Reach extraction → mission success
[ ] Squad wipe → mission fail

UI
[ ] Base HUD — all resources display, update in real-time
[ ] Build menu — room list, cost, confirm purchase
[ ] Mission briefing — squad select, deploy
[ ] Post-mission debrief — results display
[ ] Game Over screen

WIN / LOSE
[ ] Security = 0 + breach event → Game Over (exposure)
[ ] All operatives dead → Game Over (squad wipe)

LOOP
[ ] Player can complete: base phase → mission → debrief → end of day → repeat
[ ] Day counter increments correctly
[ ] Game can be saved and reloaded mid-campaign
```

---

## WHAT THIS PHASE DOES NOT INCLUDE

Do not build these in Phase 1. They are Phase 2:

- ❌ 3D art (all placeholder cubes/boxes)
- ❌ Research tree
- ❌ Multiple interrogation approaches (Psychological only)
- ❌ Traits system
- ❌ Stress breakdowns
- ❌ Defection
- ❌ AI enemy behavior
- ❌ Stealth system
- ❌ Faction standing
- ❌ Adjacency bonuses
- ❌ Multiple mission types
- ❌ Narrative (Act 1 story)
- ❌ FMOD audio

---

## RECOMMENDED TOOLS & PLUGINS (Install now)

| Tool | Purpose | Install |
|------|---------|---------|
| **Beehave** | Behavior trees for AI (Phase 2) | Godot Asset Library |
| **GDSQLite** | Save system (upgrade from JSON in Phase 2) | GitHub |
| **Phantom Camera** | Smooth camera controls | Godot Asset Library |
| **GodotTodo** | Track in-editor TODOs | Godot Asset Library |

Only install Phantom Camera now. The rest wait until Phase 2.

---

## DEVELOPMENT ENVIRONMENT SETUP

```bash
# Recommended folder structure on your machine
C:\Users\kibri\projects\blacksite_command\
├── godot\              ← Godot project lives here
├── design_docs\        ← All .md spec files
├── assets_wip\         ← Raw asset files (Blender, etc.)
├── references\         ← Screenshots, mood boards
└── builds\             ← Exported builds

# Version control
git init
git add .
git commit -m "Phase 1 scaffold — Godot project setup"

# .gitignore for Godot
echo ".godot/\nexport/\n*.import" > .gitignore
```

---

## PHASE 1 COMPLETION CRITERIA

Phase 1 is done when **one person can play this loop without crashing:**

> Day 1 → Review resources → Build a Barracks → Build a Containment Cell →
> Assign operative to interrogation → Extract 3 Intel from detainee →
> Assemble squad → Deploy on extraction mission → Succeed →
> Return, debrief, XP applied → Day 2 begins → Save game → Reload → Still works.

If that loop runs cleanly, Phase 1 is complete. Start Phase 2.

---

## NEXT DOCUMENTS NEEDED (Before Phase 2 Starts)

Produce these before the Phase 1 milestone is hit:

| Document | Purpose | Priority |
|----------|---------|----------|
| `5-tactical_mission_design.md` | Map structure, stealth mechanics, extraction rules | 🔴 Critical |
| `6-research_tree.md` | All 30+ techs, costs, unlock conditions | 🟠 High |
| `7-factions.md` | 6 factions, standing system, attack conditions | 🟠 High |
| `8-narrative_events.md` | 50 events for Phase 2, Act 1 story outline | 🟠 High |
| `9-save_schema_v2.md` | Full JSON/SQLite schema for complex save state | 🟡 Medium |

---

## FINAL VERDICT

**The spec (3-blacksite_upgraded_spec.md) is good enough to open Godot and build.**

The 10% gaps (tactical map structure, research tree, factions, narrative events) will not block you for the next 3-4 months. You have enough to build all of Phase 1.

**Start with `ResourceManager.gd`. Everything else depends on it.**

The game is buildable. Begin.
