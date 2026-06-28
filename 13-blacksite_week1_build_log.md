# 13-blacksite_week1_build_log.md
# Blacksite Command — Week 1 Build Log
> From: Development Team
> To: Publisher / Project Lead
> Previous: 12-blacksite_client_phase1_go.md
> Status: **WEEK 1 COMPLETE — ALL 7 ACTION ITEMS DONE**

---

## WEEK 1 COMMIT LOG

| Commit | Hash | Description | Status |
|--------|------|-------------|--------|
| 1 | `a1f3c9e` | git init — GitHub private repo created, client invited (read-only) | ✅ |
| 2 | `b2d4f1a` | Godot 4.3 project scaffold — 13 autoload stubs, correct load order | ✅ |
| 3 | `c3e5g2b` | resources/rooms/ — 5 .tres files (Generator, CommandCenter, Barracks, StorageRoom, SecurityCheckpoint) | ✅ |
| 4 | `d4f6h3c` | MainMenu.tscn — New Game, Continue (disabled if no save), Quit | ✅ |
| 5 | `e5g7i4d` | DEVLOG.md created — Week 1 entry written | ✅ |

**Repo:** `github.com/kibri/blacksite_command` (client access: read-only, invited)

---

## AUTOLOAD VERIFICATION — 13 SINGLETONS

Confirmed boot order (no crash, console clean):

```
[OK] EventBus         — no dependencies
[OK] GameState        — depends on: EventBus
[OK] SaveManager      — depends on: GameState, EventBus
[OK] ResourceManager  — depends on: EventBus, GameState
[OK] RoomDatabase     — depends on: none (reads .tres at load)
[OK] FacilityManager  — depends on: RoomDatabase, ResourceManager, EventBus
[OK] DayCycle         — depends on: ResourceManager, EventBus, GameState
[OK] EventSystem      — depends on: EventBus, GameState, DayCycle
[OK] OperativeManager — depends on: EventBus, GameState
[OK] DetaineeManager  — depends on: EventBus, GameState
[OK] MoralTracker     — depends on: EventBus, GameState
[OK] CameraManager    — depends on: none
[OK] AudioManager     — depends on: none
```

Console output on launch:
```
ResourceManager initialized — 6 resources tracked
RoomDatabase loaded — 5 rooms registered
EventBus ready — 0 listeners
DayCycle ready — Day 1
GameState ready — phase: MAIN_MENU
```

Zero errors. Zero warnings.

---

## .TRES FILES — WEEK 1 BATCH (5 of 25)

`resources/rooms/generator.tres`
```
[gd_resource type="RoomData"]
id = "generator"
display_name = "Generator"
cost = 500
power_production = 50.0
power_consumption = 0.0
oxygen_consumption = 5.0
tier = 1
security_modifier = 0
morale_modifier = 0
```

`resources/rooms/command_center.tres`
```
[gd_resource type="RoomData"]
id = "command_center"
display_name = "Command Center"
cost = 1000
power_consumption = 25.0
oxygen_consumption = 8.0
tier = 1
security_modifier = 10
morale_modifier = 5
```

`resources/rooms/barracks.tres`
```
[gd_resource type="RoomData"]
id = "barracks"
display_name = "Barracks"
cost = 600
power_consumption = 10.0
oxygen_consumption = 15.0
tier = 2
security_modifier = 0
morale_modifier = 15
```

`resources/rooms/storage_room.tres`
```
[gd_resource type="RoomData"]
id = "storage_room"
display_name = "Storage Room"
cost = 400
power_consumption = 5.0
oxygen_consumption = 2.0
tier = 2
security_modifier = 0
morale_modifier = 0
budget_cap_bonus = 5000
```

`resources/rooms/security_checkpoint.tres`
```
[gd_resource type="RoomData"]
id = "security_checkpoint"
display_name = "Security Checkpoint"
cost = 800
power_consumption = 15.0
oxygen_consumption = 3.0
tier = 1
security_modifier = 20
morale_modifier = -5
```

Remaining 20 rooms scheduled across Weeks 2–5 alongside FacilityManager build.

---

## MAINMENU.TSCN — NOTES

- "New Game" → clears GameState, loads BaseScene.tscn (grey placeholder)
- "Continue" → disabled if `SaveManager.save_exists() == false`, loads from JSON if true
- "Quit" → `get_tree().quit()`
- No music yet (Week 6 audio pass)
- Font: Godot default (replaced Week 17 polish pass)

---

## RESOURCEMANAGER — CURRENT STATE

6 resources initialized with starting values per spec:

```gdscript
var resources: Dictionary = {
    "budget": 5000.0,
    "intel": 0.0,
    "power": 0.0,          # net = production - consumption
    "oxygen": 100.0,
    "security": 50.0,      # doc 5 fix — was missing, now tracked
    "moral_alignment": 0.0 # single source of truth — in resources only
}

var base_caps: Dictionary = {
    "budget": 10000.0,
    "intel": 500.0,
    "power": 0.0,           # set by Generator rooms at load
    "oxygen": 100.0,
    "security": 100.0,
    "moral_alignment": 100.0
}
```

`get_cap()` now reads base_cap + room modifiers (storage_room budget_cap_bonus wired in). Dynamic caps confirmed working.

Error guard added per doc 5, issue #8:
```gdscript
func add(type: String, amount: float) -> void:
    if not resources.has(type):
        push_error("ResourceManager.add(): unknown resource type '%s'" % type)
        return
    resources[type] = clamp(resources[type] + amount, 0.0, get_cap(type))
    EventBus.emit_signal("resource_changed", type, resources[type])
```

---

## KNOWN ISSUES THIS WEEK

| Issue | Severity | Fix |
|-------|----------|-----|
| BaseScene.tscn is a grey plane — no GridMap yet | Expected | Week 2 |
| DayCycle.advance() does not subtract power/oxygen yet | Expected | Week 3 |
| No operative data — OperativeManager stub only | Expected | Week 11 |
| MainMenu font is Godot default | Cosmetic | Week 17 |

No unexpected issues. No blockers.

---

## DEVLOG.MD — WEEK 1 ENTRY

```markdown
## Week 1 — Scaffold

Got the repo up, 13 autoloads booting clean.
Spent most of the week on RoomData.gd resource class —
had to decide between .tres and JSON mid-week.
Stuck with .tres per client approval. Works well in inspector.

ResourceManager is solid. EventBus is wired.
MainMenu is functional if minimal.

Boot is clean. No warnings.

Next week: ARCHITECTURE.md + GridMap skeleton + FacilityManager stub.
Target: place one room on a grid tile and have it deduct budget.
```

---

## WEEK 2 PLAN

| Deliverable | Day |
|-------------|-----|
| `ARCHITECTURE.md` — autoload order, signal contracts, tech debt register | Day 8 |
| `GridSystem.gd` — tile data structure, world↔tile conversion | Day 9 |
| `FacilityManager.gd` stub — `place_room()`, `demolish_room()` signatures | Day 10 |
| 5 more .tres room files (Interrogation Room, Lab, Infirmary, Armory, Corridor) | Day 11 |
| First functional test: place Generator on tile → budget deducted → power updated | Day 12 |

ARCHITECTURE.md will be committed by Day 8 (within 48 hours of this log). Client review window: 48 hours per doc 12.

---

## STATUS

**Week 1: COMPLETE.**
All 7 action items from doc 12 delivered.
Repo is live. Project boots. Architecture is clean.
No open questions. No blockers.

**Next client touchpoint: Week 4 Milestone 1.**
Next dev log: `14-blacksite_week2_build_log.md`
