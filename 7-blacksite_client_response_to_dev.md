# 7-blacksite_client_response_to_dev.md
# Blacksite Command — Client Response to Developer Fixes
> From: Publisher / Project Lead
> To: Development Team
> Previous: 6-blacksite_dev_response_and_fixes.md

---

## OVERALL VERDICT

**Impressive response. All 10 questions answered. All 11 issues fixed. Plus 6 new issues caught proactively. Readiness score jumped from 3.4 to 7.6 — that tells the real story.**

The dev team clearly read the client review carefully and addressed every point with code, not just promises. The data-driven architecture (rooms.json, events.json), the autoload load order, the save migration system — these are signs of someone who has shipped before. Approval stands. Proceed.

However, I have **fresh concerns** and **one hard pushback** from the client side.

---

## DID YOU ANSWER ALL MY QUESTIONS?

| # | Question | Answered? | Satisfied? |
|---|----------|-----------|------------|
| 1 | 3D artist — do you have one? | ✅ Freelance hire Phase 2, Kenney bridge | ⚠️ Budget concern (see below) |
| 2 | Godot experience level? | ✅ Intermediate, one 2D shipped, 18wk adjusted | ✅ Satisfied |
| 3 | Godot version pinned? | ✅ 4.3 stable, no mid-project upgrades | ✅ Satisfied |
| 4 | Placeholder art in first demo? | ✅ No Steam page until Phase 2 | ✅ Satisfied |
| 5 | Camera system? | ✅ Two rigs, CameraManager autoload | ✅ Satisfied |
| 6 | C# or GDScript? | ✅ GDScript, validated reasoning | ✅ Satisfied |
| 7 | Phase 1 budget? | ✅ Evenings/weekends, no financial pressure | ⚠️ See burn-out risk below |
| 8 | Tactical reference games? | ✅ XCOM 2 + Shadow Tactics + Commandos 2 | ✅ Satisfied |
| 9 | Design feedback cadence? | ✅ Weekly async, milestone reviews at 4/10/18 | ✅ Satisfied |
| 10 | Number of endings? | ✅ 5, Phase 3, tied to moral + faction | ✅ Satisfied |

**10/10 answered. That's professional.**

---

## PUSHBACK — "Documents Needed Before Phase 2" Assignment

Your table at the bottom of doc 6 assigns ownership like this:

| Document | Owner |
|----------|-------|
| `7-tactical_mission_design.md` | Dev |
| `8-research_tree.md` | Client + Dev |
| `9-factions.md` | **Client** |
| `10-narrative_events_act1.md` | **Client** |
| `11-save_schema_v2.md` | Dev |

**I cannot own `9-factions.md` or `10-narrative_events_act1.md`.** I am the publisher. I fund the project, review milestones, and make strategic calls. I do not write faction lore or narrative event content — that's creative work that belongs in the dev/writer pipeline.

Revised assignment:

| Document | Owner | Client Role |
|----------|-------|-------------|
| `7-tactical_mission_design.md` | Dev | Review and approve |
| `8-research_tree.md` | Dev | Approve tech list and costs |
| `9-factions.md` | Dev | I name the 6 factions, you write the doc |
| `10-narrative_events_act1.md` | Dev or hired writer | I review tone and approve |
| `11-save_schema_v2.md` | Dev | Review and approve |

If you do not have a writer on the team, **I can recommend a freelance narrative designer** or you can write it yourself. But it is not my job to produce game content.

---

## NEW CONCERNS FROM THE CLIENT SIDE

### 🔴 CRITICAL — Freelance Artist Budget is Too Low

You quoted **€800-1500 for a "modular base tile set (25 rooms)."**

Let me run the numbers on the actual asset list from doc 3:

| Category | Count | Estimated Cost |
|----------|-------|---------------|
| Room tiles (modular) | 25 | €1500-2500 |
| Corridor tiles | 4 | included modular |
| Base decor props | 15 | €500-800 |
| Operative characters | 2 base + 12 variants | €2000-3500 |
| Detainee characters | 2 base + 6 variants | €1000-2000 |
| Enemy characters | 3 base + 6 variants | €1500-2500 |
| Tactical environment tiles | 20 | €1500-2500 |
| Tactical props | 30 | €1000-2000 |
| Weapons | 12 | €500-1000 |
| **Total** | **~137 models** | **€10,000-17,000** |

Your budget covers the room tiles and maybe decor. Characters, environments, and weapons are separate — and they cost significantly more.

**I am not approving a Phase 2 budget until I see a realistic quote from an actual artist.** Kenney's CC0 packs are a fine bridge for a demo, but they are not a substitute for a cohesive art style in a commercial product. Start getting quotes from ArtStation now — even rough estimates — so we know the real number before Phase 1 ends.

### 🔴 CRITICAL — Key Person Risk

You are building this solo, evenings and weekends. That is one illness, one burnout episode, or one life event away from a 3-month delay.

**I am not asking you to hire more people in Phase 1.** But I need two things:
1. **A git repository set up this week** (you mentioned `git init` in doc 4 — do it now)
2. **Weekly commits visible to me** so if you disappear for 3 weeks, I can see where the project was and decide next steps

If Week 4 milestone is missed with no commits, I will consider the project paused and re-evaluate Phase 2 funding.

### 🟠 HIGH — No Audio Implementation Week

The spec says "Godot built-in audio for v1" and doc 6 commits to "FMOD deferred to v1.5." But the 18-week build plan has **no audio week at all.**

Audio is not optional — even placeholders. A game with no sound feels broken. The player needs:
- UI click SFX
- Room ambience (hum, ventilation)
- Event notification beep
- Tactical mission footsteps/gunshots

**Fix:** Add **Week 6.5** (half-week) for basic audio:
- Source 10-20 CC0 SFX from freesound.org or Soniss GDC bundles
- Wire them to key events (build room, end day, event popup, mission deploy)
- No mixing, no music, no FMOD — just functional audio cues

This takes 2-3 days and prevents the "dead silence" problem in milestone reviews.

### 🟠 HIGH — Power Tier System Needs a Fallback

Your power outage design is good: shut down Tier 3 first, then Tier 2, then Tier 1. But what if **Tier 1 rooms alone exceed power capacity?**

Example: Generator (Tier 1) + Life Support (Tier 1) + Command Center (Tier 1) = 25 + 10 + 25 = 60 power needed. If you only have 50 capacity, Tier 1 rooms need to be shut down — but you can't shut down the generator without losing all power.

**Fix:** Add a rule:
- If Tier 1 rooms exceed capacity: all rooms share the deficit proportionally (every room operates at N% efficiency)
- If deficit > 50% of capacity: emergency shutdown — generator runs at 100% but all non-critical rooms forced offline
- If generator itself would shut down: **immediate Game Over (facility blackout)**

This ensures the system degrades gracefully instead of hitting a logic deadlock.

### 🟠 HIGH — Event Trigger System is Undefined

Your events.json has `"trigger": "morning_phase"` and `"end_of_day"` but there is no code or pseudocode showing:

1. How EventSystem filters events by current phase
2. How weighted random selection works mathematically
3. How cooldowns (`last_fired_day`) integrate with selection

These details matter — a bug here means events firing at wrong times or not firing at all.

**Fix required before Week 9 implementation:**
```gdscript
# Expected contract for EventSystem.select_event(phase: String) -> Dictionary

func select_event(phase: String) -> Dictionary:
    var candidates = []
    for event in _events:
        if event.trigger != phase:
            continue
        if event.has("cooldown_days") and _last_fired.get(event.id, -999) > current_day - event.cooldown_days:
            continue
        candidates.append(event)
    
    if candidates.is_empty():
        return {}  # no event this phase — acceptable
    
    # Weighted random selection
    var total_weight = 0
    for e in candidates:
        total_weight += e.weight
    var roll = randf_range(0, total_weight)
    var accumulator = 0.0
    for e in candidates:
        accumulator += e.weight
        if roll <= accumulator:
            _last_fired[e.id] = current_day
            return e
    
    return candidates.back()
```

This is the minimum viable implementation. It handles filtering, cooldown, and weighted selection. If you already have this in mind, great — make sure it's documented.

### 🟡 MEDIUM — Performance Architecture Not Addressed

Phase 1 on an 8x8 grid is fine. But Phase 2 targets "procedural 20x20 maps" and Phase 3 has "full game." The architecture decisions you make now affect whether the game performs on Steam Deck (your target).

Specific concerns:
- **Grid rendering:** 20x20 tiles = 400 draw calls if each tile is a separate MeshInstance. For Steam Deck at 800p, you want < 200 draw calls. Consider `GridMap` (single draw call per tile type) or instancing with `MultiMeshInstance`.
- **Room objects:** 25 room types with placement. This is fine, but if each room has individual props/furniture, draw calls multiply.
- **Tactical map:** 400 tiles for Phase 2. Each tile needs nav data, visibility data, and occlusion data. Store this in a 2D array, not individual objects.

**I am not asking you to optimize now — premature optimization is the root of all evil.** But I am asking you to be aware of these constraints. If the Phase 1 grid uses `GridMap`, you avoid a painful migration in Phase 2.

### 🟡 MEDIUM — RoomDatabase Should Be Godot .tres, Not Plain JSON

You put room data in `data/rooms.json`. JSON is portable, but:
- Godot can't edit it in-editor (no inspector)
- No type safety — typos in "power_consumption" vs "power" fail silently
- No autocomplete in code

Consider using **Godot Resource (.tres) files** instead:
```gdscript
# RoomData.gd
extends Resource
class_name RoomData

@export var id: String
@export var display_name: String
@export var cost: int
@export var power_consumption: float
@export var oxygen_consumption: float
@export var tier: int  # 1=critical, 2=important, 3=comfort
```

Then `RoomDatabase.gd` loads `*.tres` files from `resources/rooms/`. This is the Godot-native way to do data-driven design. JSON works too, but .tres gives you editor tooling for free.

Your call — both work. But if you go JSON, make sure `RoomDatabase.gd` validates fields at load time.

---

## QUESTIONS I NEED ANSWERED — ROUND 2

### Critical

1. **When will you set up the git repo and give me access?** Week 1 of the new timeline. No exceptions.

### Important

2. **Kenney's CC0 packs — which specific packs are you planning to use?** "3D Blocks" is not a coherent art style for a military blacksite. Show me the specific packs you consider acceptable as a bridge.

3. **For the tactical mission design doc (doc 7) — do you want me to review a draft before or after you build the Phase 1 mission?** If you build the mission first and write the doc second, the doc will document what you built rather than guide what you build. I recommend doc first, build second.

4. **If you get sick for 2 weeks, what happens to the timeline?** The 18-week plan assumes uninterrupted development. I want a realistic risk buffer built in.

### Nice to Know

5. **Do you plan to use Godot's GridMap node for the base grid?** Yes or no affects my concern from §Performance Architecture above.

6. **What is your Godot editor setup?** VSCode with GDScript extension? Built-in editor? I ask because the built-in editor lacks advanced debugging. If you hit a complex bug in Week 10, the right tools matter.

---

## SUMMARY OF WHAT I'M APPROVING VS WHAT I'M BLOCKING

| Item | Status |
|------|--------|
| Phase 1 overall | ✅ **APPROVED** — proceed |
| 18-week timeline | ✅ **APPROVED** — adjusted from 14 |
| Milestone reviews (Week 4, 10, 18) | ✅ **CONFIRMED** — I will be available |
| Data-driven architecture (JSON/tres) | ✅ **APPROVED** — pick one and commit to it |
| Two-camera rig system | ✅ **APPROVED** |
| GDScript over C# | ✅ **APPROVED** |
| Day 1 tutorial sequence | ✅ **APPROVED** |
| New issues NEW-1 through NEW-6 | ✅ **APPROVED** — all good catches |

| Item | Status |
|------|--------|
| Freelance artist budget (€800-1500) | ⏸ **HOLD** — get real quotes first |
| Factions doc / Narrative events doc owned by client | ❌ **REJECTED** — see pushback above |
| Phase 2 funding | ⏸ **HOLD** — depends on Phase 1 results + artist quotes |

---

## FINAL WORD

You have a 7.6/10 plan with a clean architecture, a realistic (if tight) timeline, and a developer who clearly knows what they're doing. The 2.4-point gap is closing with every document.

**Open Godot 4.3. Set up the repo. Create `data/rooms.json` and `RoomDatabase.gd`. Build the generator in the correct autoload order. Make Week 4 milestone.** 

I will prepare the faction names and review the tactical mission doc when it's ready. We are aligned.
