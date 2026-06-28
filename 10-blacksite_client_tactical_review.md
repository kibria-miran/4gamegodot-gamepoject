# 10-blacksite_client_tactical_review.md
# Blacksite Command — Client Review: Doc 8 (Dev Response) & Doc 9 (Tactical Mission Design)
> From: Publisher / Project Lead
> To: Development Team
> Previous: 8-blacksite_dev_pm_response.md, 9-tactical_mission_design.md

---

## OVERALL VERDICT — DOC 8 (Dev Response)

**Readiness score of 8.5/10 is fair. EventBus is the right call and makes the architecture production-grade.**

The EventBus decoupling (NEW-10) is the single most important improvement across all documents so far. It turns a fragile web of singleton-to-singleton calls into a clean pub/sub system. Worth the 1-day investment. The refined autoload order (13 singletons, dependency-aware) is solid.

All 6 questions answered. All 5 concerns from doc 7 fixed. I have **no blocking issues** with doc 8.

### Minor callouts on doc 8:

**AudioManager creates a new AudioStreamPlayer per SFX call.** For 18 sounds in Phase 1 this is fine, but for Phase 2 (80+ SFX) spawning and freeing nodes per play will cause GC stutter. Consider an `AudioStreamPlayer` pool (pre-allocate 8 players, recycle them). Non-blocking — flag it for Week 17 polish pass.

**Cost reduction options mention "Fab.com military character pack" but no specific pack.** Unacceptable for budget approval. I need a link or a pack name before Phase 2 budget discussion. "~€150–400" is too vague.

**ARCHITECTURE.md format was promised but not shown.** I need to see the actual format and first entries in a week 2 commit so I can review it before systems get complex.

**Overall:** Approved. Proceed to Week 1.

---

## OVERALL VERDICT — DOC 9 (Tactical Mission Design)

**Good document. 7/10 — buildable but needs corrections before Week 13 execution.**

The turn structure (initiative-based, 2 AP, op-by-op activation) is well-defined. The stealth system (vision cone, alert meter, noise radius) is the strongest section — clearly inspired by Shadow Tactics but adapted for turn-based. The 8x8 hand-crafted map is simple but sufficient for validation.

However, I found **issues that will cause gameplay problems or broken expectations** during playtesting. Fix these before building.

---

## ANSWERS TO OPEN QUESTIONS (OQ-1, OQ-2)

### OQ-1 — Partial Success (extract without objective)
**Answer: Option B — Partial success.**
Rewards: operatives extracted safely, no intel reward, Control Trust -5.
Your reasoning is correct: Option A (total failure) is too punishing and discourages risk-taking. Partial success keeps the player engaged and gives narrative tension for the next mission. Approved.

### OQ-2 — Alert State Persistence After Guard Killed
**Answer: Decay after 3 turns with no stimuli.**
Agree with your recommendation. But add: if 2+ guards were in Combat state before being killed, remaining alerted guards should stay in Combat for at least 2 more turns (group panic response). Single guard dying shouldn't cascade.

---

## WEAK POINTS & ISSUES IN DOC 9

### 🔴 CRITICAL — Structural Problems

**1. Guard behavior contradiction: static vs. functional.**

The text says "All guards in Phase 1 are static with fixed facing. They do not patrol." But `_on_alert_meter_changed()` shows:
- "alerted" state: "moves to last known position (basic)"
- "combat" state: "shoots at operative if LoS available"

These are contradictory. If guards are truly static, the Alert Meter has no mechanical consequence — being "alerted" or in "combat" matters only if the guard can actually act on it. What does "suspicious" look like visually? What does "alerted" do if the guard doesn't move?

**Fix needed before Week 13 build:**
- Option A: Truly static guards — Alert Meter triggers different visual states only (color change, VFX cue). "Combat" guard shoots from position (range check). Remove movement logic from Phase 1.
- Option B: Semi-static — guards do not patrol their route (no wander AI), but if Alert Meter reaches "alerted" (61+), guard turns to face the direction of the disturbance and takes 1 step toward it. "Combat" guard pursues at 1 tile/turn.
- **My recommendation:** Option B. Static with zero reaction feels broken. Even a single-step response validates the Alert Meter system.

**2. Route B (stealth) passes through G1's vision cone.**

The stealth route description says: "slide east through Row 6 (below all guards) — avoids all guards if Stealth ≥ 5."

But **tile (4,6) is in Guard 1's vision cone.** G1 at (4,0) faces South with range 6. Tile (4,6) is at distance 6 — exactly at max range. No walls block the line of sight down column 4. An operative passing through (4,6) will enter G1's vision cone and accumulate +15 Alert Meter per turn.

With Stealth 5+, the operative gets +1 movement range when crouching, but that doesn't affect vision cone detection. The statement "avoids all guards if Stealth ≥ 5" is misleading.

**Fix:**
- Adjust the map so the stealth route is genuinely stealthy, OR
- Update the route description to be accurate: "Route B minimizes exposure — only crosses G1's cone edge at (4,6). Move through quickly to keep Alert Meter low."

I prefer the second option. The tension of briefly entering a cone edge makes the stealth route more interesting than a guaranteed safe path.

**3. Downed operative recovery is undefined.**

Doc says: "If another operative is adjacent at end of mission: recovered (returns to base, needs infirmary)."

But downed operatives are "removed from tactical map" when HP reaches 0. The movement system has no "carry" or "drag" action. How does an operative become adjacent to a downed operative who has already been removed from the map?

**Fix one of:**
- Downed operatives remain on the map as a body tile (cannot move, can be stepped over). Another operative can spend 2 AP to "Drag" them. Dragging operative moves at 1 tile/turn.
- Or: reaching extraction with a living operative adjacent to the body tile = recovered. No explicit drag mechanic needed for Phase 1.

**4. Extraction tile rule: all remaining operatives left behind marked MIA.**

What if 3 of 4 operatives were downed and the last surviving operative extracts? The 3 downed ops are in the map — are they "left behind"? But downed = removed from map per the text. So they're already gone. What does "left behind mean" for operatives who were already downed?

**Clarify:** "Operatives who were downed during the mission are assumed to have been recovered if extraction is reached. Operatives who were active (alive on the map) at extraction time but did not reach the extraction tile are MIA." Or define differently — but the current text is ambiguous.

---

### 🟠 HIGH — Gameplay / Balance Issues

**5. AP economy: 2 tiles per turn on an 8x8 map may feel slow.**

Path from start zone to extraction (optimal route B stealth) is ~14-16 tiles. At 2 tiles/turn, that's 7-8 player turns. Each turn has operatives activating one at a time, then enemy phase. With 3 operatives and 3 guards, that's roughly 7 * (3 + 3) = 42 action phases for a single mission. At 10-20 seconds per phase, the mission takes 7-14 minutes. This is fine for Phase 1 testing.

But what about combat? If Route A (direct approach through G1) involves fighting, each combat shot uses 2 AP (ranged attack = full turn), meaning an operative fires once per turn. A firefight could take 3-4 turns per engagement. With 3 guards across the map, that's a 15-20 minute mission. Acceptable.

**Not asking for changes — just noting this for the Week 10 milestone review. If playtesting shows the mission dragging, consider Phase 1 adjustment: 3 AP per operative instead of 2.**

**6. Hit chance formula may be frustrating in playtesting.**

New operative (Combat 5): 65% + 0% - 25% (half cover) - range penalty = ~30-40% effective hit rate. Against full cover: 15%. In a game with limited ammo and 2 AP per attack, missing 2-3 times in a row (probability: 34% chance of 3 consecutive misses at 65% base) feels bad.

**Phase 1 recommendation:** Bump BASE_ACCURACY to 75% temporarily. This is testing data — tune for fun later. 75% base gives 50% vs. half cover and 25% vs. full cover. Still challenging but less frustrating for testers who need to validate the loop, not the balance.

**7. One-hit kill rule is misaligned with Phase 1 weapons.**

Rule: "damage ≥ current HP + 20 = instant kill." With pistol (20-30 damage), an operative at 100 HP needs 120 damage in one hit — impossible. With rifle (35-50), an operative at 30 HP needs 50 damage — possible but requires max roll.

**This rule will not trigger in Phase 1 testing.** It only matters when operatives are wounded. Consider disabling it for Phase 1 or lowering the threshold to "damage ≥ current HP + 10" so testers can see the mechanic.

---

### 🟡 MEDIUM — Design / Implementation Issues

**8. Center-based LoS has known corner-case failures.**

Your LoS code uses `PhysicsRayQueryParameters3D` from tile center to tile center. This fails when a wall occupies only part of a tile edge — the center-to-center ray can pass through a diagonal gap that the character model cannot physically fit through.

Godot's `GridMap` navmesh baking handles this, but the raycast doesn't. For Phase 1 on an 8x8 grid this likely won't cause visible problems, but flag it now for Phase 2 procedural maps. **Use 4 corner-to-corner raycasts** in Phase 2 instead of single center-to-center.

**9. Noise distance uses Euclidean but should use Manhattan for grid stealth.**

`source_tile.distance_to(enemy.tile)` returns Euclidean distance. On a tile grid, this means a noise at (0,0) reaches an enemy at (2,0) at distance 2, but also reaches an enemy at (1,1) at distance ~1.4. This creates non-intuitive behavior — the player can't predict which guards will hear a noise because diagonal distance is shorter than expected.

**Fix:** Use Manhattan distance (`abs(dx) + abs(dy)`) for noise radius. It's predictable on a grid and matches how movement works.

**10. Debrief screen mentions "recovery mission available" but no recovery mission type exists.**

Phase 2 mission types list: Neutralize, Stealth, Escort. No "Recovery." If an operative is MIA, what mission type does the player run? The debrief text creates an expectation the game cannot fulfill.

**Fix:** Either (A) remove "recovery mission available" from debrief text, or (B) add Recovery to Phase 2 mission types. I recommend B — MIA operatives are a strong narrative hook. But if it's not in scope, remove the text.

**11. TacticalMap grid_size is hardcoded to (8,8).**

Phase 2 procedural maps will need variable sizes. Change to `var grid_size: Vector2i` set from map data at load time. Trivial fix now, painful refactor later.

**12. Narrative vs tileset mismatch.**

Map narrative says "GRU safehouse in an industrial district" — an above-ground urban environment. The placeholder tileset is Kenney Simple Dungeon (underground stone, torches). The aesthetic mismatch is obvious to anyone who's seen both packs.

**Fix:** Either (A) rewrite the briefing to be underground (e.g. "GRU bunker beneath an industrial district"), or (B) pick a different Kenney pack. Option A is simpler — change two sentences. I recommend A with a note that the Phase 2 tileset will match the environment.

---

## SUGGESTIONS & IMPROVEMENTS

### FROM THE CLIENT

**1. Add a "skip enemy phase" debug toggle (F2 key) for Phase 1 testing.**

During development, sitting through 3 guards' alert-check cycles every turn gets tedious. Add a dev-only keybind (`F2`) that skips all enemy AI for the turn. Remove this keybind before Phase 1 deliverable.

**2. The turn flow should show a "ENEMY PHASE" splash.**

When player ends their turn, flash "ENEMY TURN" on screen for 1 second. This prevents the confusion of "why can't I click my operative?" when control transfers. Small UX touch, big quality-of-life improvement.

**3. Consider a "camera follow operative" toggle (default: on).**

When selecting an operative, the camera should smoothly pan to center on them (not snap). Godot's CameraManager can do this with `lerp()` on position. Makes the tactical layer feel polished even with placeholder art.

**4. Add a "confirm order" option (optional) for movement.**

Players can misclick on a grid. Holding Shift and clicking shows a movement path ghost. Clicking again confirms. If misclicked, right-click cancels. This is standard in tactical games (XCOM) and prevents "I clicked the wrong tile and now my operative is dead" rage-quits.

**5. Save tactical map state for save/load.**

The current save schema (doc 6, §Week 14) saves base state but not tactical mission state. If a player saves mid-mission, they should resume there — not at base. This needs to be in the Phase 1 save schema or explicitly deferred with a warning popup ("Saving during a mission will return you to base"). I recommend the latter for Phase 1 — add warning popup, implement full mid-mission save in Phase 2.

---

## WHAT I'M APPROVING VS NOT

| Item | Status |
|------|--------|
| Doc 8 — Dev Response (all fixes) | ✅ **APPROVED** — proceed to Week 1 |
| Doc 9 — Tactical Mission Design | ✅ **APPROVED WITH CONDITIONS** — see below |
| EventBus architecture (NEW-10) | ✅ **APPROVED** — best decision in this cycle |
| GridMap for base and tactical | ✅ **APPROVED** |
| .tres for rooms, JSON for events | ✅ **APPROVED** — clean split |
| 20-week timeline with 2-week buffer | ✅ **APPROVED** |
| Partial success (OQ-1: Option B) | ✅ **APPROVED** |
| Alert decay 3 turns (OQ-2) | ✅ **APPROVED** — with group panic caveat |
| **OQ-3 (new): Confirm guard behavior** | **⏸ NEEDS ANSWER** — see critical issue #1 |
| Phase 2 Recovery mission type | **⏸ NEEDS DECISION** — see issue #10 |
| Mid-mission save (deferred) | **⏸ NEEDS DECISION** — warning popup or full save |

---

## FINAL WORD

**Doc 8 is the strongest document since this project started.** The EventBus architecture, the clean autoload order, the power production/consumption split, the AudioManager, the demolish system — this is a developer who has learned from past projects. 8.5/10 is fair and I expect 9.5/10 by the Week 4 milestone.

**Doc 9 is buildable but needs 3 fixes before Week 13:**
1. Resolve the guard behavior contradiction (static vs. reactive). My vote: Option B (semi-static with limited movement on alert).
2. Fix the stealth route description — tile (4,6) is in G1's vision cone. Update the description, not the map.
3. Define downed operative recovery mechanics (drag/carry or proximity-based at extraction).

**Fix those three items, address the 12 medium issues in the Week 17 polish pass, and this project is on track for a solid Phase 1 deliverable at Week 20.**
