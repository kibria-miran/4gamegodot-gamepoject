# 5-blacksite_client_review.md
# Blacksite Command — Client Review of Phase 1 Build Plan
> From: Publisher / Project Lead
> To: Development Team

---

## OVERALL VERDICT

**The plan is solid — I'm approving Phase 1 to proceed. But fix the issues below before Week 2 ends or they'll compound.**

The spec (3) and build plan (4) together are good enough to start. You've done the hard work of breaking down a complex game into buildable chunks. The 14-week timeline is **optimistic but achievable** if you stick to the scope gates and don't let feature creep in.

However, I found **several contradictions between the spec and the build plan code** that will cause bugs if not addressed now.

---

## ANSWERS TO THE 5 GAPS (Your Questions From §REMAINING GAPS)

### GAP 1 — Tactical Mission Map Structure
*You asked: map size, procedural vs hand-crafted, stealth detection, extraction rules*

**Client answer:**
- **Phase 1:** Exactly what you proposed — 1 hand-crafted map. Keep it small: 8x8 tiles, 5-6 rooms, one path. The goal is to validate the movement and objective-loop, not to be fun yet.
- **Phase 2 target:** 20x20 tiles, procedurally assembled from hand-crafted room chunks. Like Slay the Spire's map generation but for rooms instead of nodes.
- **Stealth detection:** Cone-of-vision from enemy facing direction. Noise radius of 2 tiles for walking, 4 for combat. Don't overbuild this in Phase 1 — static guards is fine.
- **Extraction:** Reach the extraction tile with at least 1 operative alive. No timer yet. Timer comes in Phase 2.

### GAP 2 — Research Tree
*You asked: how many techs, what unlocks, what costs*

**Client answer:**
- Phase 2 target: **18 techs** (not 30+ — keep scope realistic), split into 3 trees of 6 each
- Costs: Budget (primary) + Intel (secondary). No time-gating yet.
- I need a separate doc with the full tree before Phase 2 starts. But for now, don't think about it.

### GAP 3 — Faction System
*You asked: what are the 6 factions, how standing works, can they attack*

**Client answer:**
The 6 factions (placeholder names — finalize before Phase 2):
1. **GRU** — Russian military intel (default hostile)
2. **The Network** — freelance intelligence brokers (neutral-tradeable)
3. **Control** — your own handlers (always present, hidden agenda)
4. **Crimson Brigades** — private military corp (hostile, raids)
5. **Initiative** — NGO/journalist network (moral faction, ally if good)
6. **Unaffiliated** — independents, civilians, loose ends

**Standing effects:** Better trade prices, exclusive intel, raid warnings at high standing. Retaliation missions at low standing.
**Attacks:** Yes — Crimson Brigades can raid the base if standing drops too low. This is Phase 2 content. Don't build it yet.

### GAP 4 — Narrative Events
*You flagged 50 events needed*

**Client answer:** 50 is Phase 2 target. For Phase 1, your list of 10 is fine. But write them with actual content — not just "Security -10" — give them flavor text, a choice (even if the choice is fake), and a consequence. That's the minimum for us to test the event system UI.

### GAP 5 — Save System Schema
*You asked for schema definition*

**Client answer:** The JSON structure in your plan (§Week 14) is good enough for Phase 1. The `moral_alignment` duplication (both top-level AND inside `resources`) is a bug — pick one. I'd say keep it in `resources` and remove the top-level field.

---

## ISSUES I NOTICE — THINGS THAT ARE OFF

These need to be fixed. Some are bugs waiting to happen, others are design gaps.

### 🔴 CRITICAL — Fix Before Week 2

**1. "Security" is referenced but doesn't exist as a tracked stat.**
- Lose condition says "Security = 0 + breach event → Game Over"
- Event #2 says "Security -10"
- The grid section mentions rooms contributing to Security
- **But ResourceManager.gd has NO `security` resource.**
- **Fix:** Add `security: 50` (starting value, range 0-100) to ResourceManager. Rooms like Security Checkpoint should increase it. Events should decrease it. Lose condition checks it.

**2. Power and O₂ are never consumed.**
- Rooms list Power and O₂ consumption, and the save JSON tracks `power_used` and `oxygen_used`.
- But `DayCycle._apply_daily_resources()` only adds budget and intel — it never subtracts power_used or oxygen_used.
- **Fix:** In `_apply_daily_resources()`, total all room power/oxygen consumption and subtract from capacity. If `power_used > power_capacity`, rooms start malfunctioning. If `oxygen_used > oxygen_capacity`, morale drops, operatives take damage.

**3. `moral_alignment` is duplicated in the save schema.**
- Top-level: `"moral_alignment": -12`
- Inside `resources`: `"moral_alignment": -12`
- **Fix:** Keep it in one place. Recommend inside `resources` for consistency with the autoload singleton pattern.

### 🟠 HIGH — Fix Before Week 6

**4. ResourceManager.add() clamps to `get_cap()` but doesn't handle room modifiers.**
- `get_cap("budget")` returns 10000 hardcoded.
- But Storage Room says "+5000 Budget overflow cap."
- **Fix:** Make caps dynamic — rooms can increase them. Store base_cap and let rooms add modifiers.

**5. Event system triggers with no context.**
- `EventSystem.trigger("control_inspector_sent")` — what does this do? Is it a popup? A stat change? A new mission?
- **Fix:** Define an event data structure: `{ id, trigger_conditions, text, choices, stat_changes[] }`. Even a JSON file is fine. Just have a contract.

**6. No O₂ starvation or power outage mechanics defined.**
- If power_used exceeds capacity, what happens? Rooms shut down? Which ones?
- If oxygen runs out, operatives suffocate? Over how long?
- **Fix:** Write a 10-line design doc for resource shortfall behavior before Week 6.

**7. The tactical mission is 4 tiles — that's not enough to test the combat system.**
- Phase 1 needs to validate that tile-based movement *feels* right, that the camera works, and that the objective/extraction loop functions.
- 4 tiles won't surface camera bugs, pathfinding edge cases, or UI layout issues.
- **Recommendation:** Expand to 8x8 tiles minimum. Still hand-crafted, still no AI, but enough space to move around.

### 🟡 MEDIUM — Fix Before Phase 1 Ship

**8. No error handling in ResourceManager code.**
- `func add(type: String, amount: float):` will crash if `type` doesn't exist in the dictionary.
- **Fix:** `if not resources.has(type): return` or use a typed dictionary with default values.

**9. Save system has no version migration plan.**
- The JSON has `"version": "1.0"` but there's no code to handle old versions.
- **Fix:** In the load function, check version and run migration functions if needed. This is easy now, painful later.

**10. No test strategy.**
- How do you know Day 1 → Day 2 transition works? That resources persist through save/load? That events fire in the right order?
- **Fix:** Don't need a full unit test suite, but at minimum: one manual test script (sequence of actions that must produce expected results) to run before each milestone.

**11. Learning curve / tutorial not addressed.**
- New players land in a 3D base with 8 resources, a grid system, and an interrogation mechanic. They will be lost.
- **Fix:** Phase 1 needs a simple tooltip system or a "first day" scripted sequence. Even a text popup on Day 1 saying "Click a tile to build your Command Center" is enough.

---

## QUESTIONS I NEED ANSWERED (From Client to Developer)

### Critical

1. **3D artist — do you have one, or are we shipping with placeholder cubes?** The risk doc flags this. I need a name or a hiring budget number before Phase 2.

2. **What's your experience level with Godot?** If this is your first Godot project, the 14-week timeline is unrealistic — I'd double it. No judgment, but I need to know for milestone planning.

3. **Godot 4.0, 4.1, 4.2, or 4.3?** The spec just says "Godot 4.x." APIs changed significantly between versions. Pick one and pin it.

### Important

4. **Are we shipping placeholder art in the first public demo, or do we wait for final art?** I need to know if we're doing an early-access Steam page during Phase 1 or only after Phase 2.

5. **How are you handling the camera?** 3D base view + tactical view are two different camera modes. Is this a single camera rig that switches, or two separate viewports? The build plan doesn't mention this.

6. **C# or GDScript?** The spec lists both. Pick one. GDScript is faster to prototype but C# gives better tooling for complex systems. Your call, but I need a decision.

7. **Can you give me a rough estimate of the Phase 1 budget?** Not asking for a spreadsheet — just: are you doing this in your spare time, part-time contract, or full-time?

### Good To Know

8. **What reference games are you using for the tactical layer?** XCOM (tile-based)? Commandos (real-time)? Shadow Tactics (stealth focus)? This affects the tile size, movement speed, and camera setup.

9. **Do you want design feedback during Phase 1 or only at milestone reviews?** I can be hands-off or hands-on. Your preference.

10. **Does the "4-6 endings" plan still hold, or has that changed?** The latest spec says 5. Earlier docs said 4-6. Which is it?

---

## BOTTOM LINE

The build plan is **approved for execution.** The spec is good enough to start. But the 11 issues I listed above need fixes, and all 10 questions need answers before Week 4.

**Most important action item:** Fix the Security stat gap and the Power/O₂ consumption gap immediately — those will cause bugs in Week 2 if not addressed. Everything else can wait until their respective weeks.

**Go build. I'll check in at Week 4 for the first milestone review.**
