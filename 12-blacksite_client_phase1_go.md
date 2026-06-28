# 12-blacksite_client_phase1_go.md
# Blacksite Command — Client Final Approval: All Specs Locked
> From: Publisher / Project Lead
> To: Development Team
> Previous: 11-blacksite_dev_pm_response.md
> Status: **SPEC PHASE CLOSED. BUILD PHASE BEGINS.**

---

## OVERALL VERDICT — Doc 11 Response

**All blocking issues resolved. All decisions made. Overall readiness: 8.9/10.**

Doc 11 is the cleanest response in this project cycle. Every fix from doc 10 was applied, scheduled, or flagged correctly. The approval table at the bottom is unambiguous. No open questions remain.

I am closing the spec phase. No more design documents needed before Week 4 milestone. The game is now in build.

---

## FINAL APPROVAL TABLE

| Item | Status | Notes |
|------|--------|-------|
| OQ-3 — Guard behavior Option B | ✅ **CONFIRMED** | Semi-static, 4-state AI with 1-step alert movement |
| Recovery mission — Phase 2, debrief text removed | ✅ **CONFIRMED** | Text fix for Phase 1, full design for Phase 2 |
| Mid-mission save — warning popup | ✅ **CONFIRMED** | Phase 1 warning, Phase 2 full state serialization |
| Route B tile (4,6) — description fix, not map change | ✅ **CONFIRMED** | Cone edge becomes a skill check |
| Downed operative auto-recovery on extraction | ✅ **CONFIRMED** | No drag mechanic Phase 1, downed marker tile |
| BASE_ACCURACY 75% for Phase 1 | ✅ **CONFIRMED** | `# PHASE_1_TEMP` comment required |
| One-hit kill threshold HP+10 | ✅ **CONFIRMED** | Enables playtesting visibility |
| Manhattan distance for noise radius | ✅ **APPLIED** | Correct fix, simple change |
| Dynamic grid_size from map data | ✅ **APPLIED** | var not const |
| Briefing rewritten for dungeon tileset | ✅ **APPLIED** | "GRU signals bunker beneath Norilsk industrial district" |
| 5 UX suggestions (F2, Enemy splash, follow cam, confirm move, save warning) | ✅ **SCHEDULED** | Weeks 13-14 |
| LoS corner raycasts | ✅ **FLAGGED** | Phase 2, TODO in code |
| AudioManager node pool | ✅ **FLAGGED** | Phase 2, pre-allocate 8 players |
| Fab.com pack — specific link | ⏸ **DUE WEEK 6** | See below |
| ARCHITECTURE.md | ⏸ **DUE WEEK 2** | See below |

---

## REMAINING OPEN ITEMS (2 — both scheduled, both condition-passing)

### 1. Fab.com Pack — Specific Link (Week 6)

This is the only item that can delay Phase 2. If Week 6 passes without a specific pack name + license check + price confirmation, Phase 2 budget discussions are postponed indefinitely. I will not approve a Phase 2 art spend on "~€150-400 maybe some pack on Fab maybe."

**Clarification on what I need:**
- Exact URL or pack title
- License type (CC0? Paid commercial? Royalty-free?)
- Total cost for all relevant packs (not per-pack estimates)
- Screenshots of the pack's art style against a screenshot of your Phase 1 placeholder build (so I can judge aesthetic compatibility)

Deliver this at Week 6 milestone or earlier.

### 2. ARCHITECTURE.md (Week 2)

The format proposed in doc 11 (autoload order, signal contracts, known tech debt) is acceptable. I need to see the first commit of this file in Week 2. It does not need to be complete — it needs to exist and be structurally correct. Subsequent weeks add to it.

If Week 2 passes without ARCHITECTURE.md, I consider the key-person risk mitigation plan (doc 8, Concern 2) broken and will escalate.

---

## NOTES ON THE APPROACH

**You built a 8.9/10 plan with 13 singletons, a clean event bus architecture, 20-week timeline with buffer, data-driven design, and a playable tactical loop — without writing a single line of game code yet. That is the correct way to build a complex game.**

Most projects fail because the developer opens Godot on Day 1 and starts placing nodes. You did the opposite: you spec'd, reviewed, responded, revised, and iterated on paper until the architecture was clean. The result is that Week 1 build will be structured, testable, and documented.

This approach is why I approved the project.

---

## WHAT I EXPECT TO SEE AND WHEN

### Week 1 (due end of week)

```
Commit 1 — git init, push to GitHub, client invited
Commit 2 — Godot 4.3 project created, 13 autoload stubs (empty scripts, correct order)
Commit 3 — resources/rooms/ folder with 5 .tres files
Commit 4 — MainMenu.tscn (New Game, Continue, Quit)
Commit 5 — DEVLOG.md entry: "Week 1 scaffold complete"
```

I do not need to review every commit. But if Week 1 passes without a commit, I will reach out.

### Week 2

```
Commit containing ARCHITECTURE.md with:
  - Autoload order (confirmed 13-singleton list)
  - Signal contracts for EventBus
  - Known tech debt register (copied from our docs)
  - First entry in DEVLOG.md
```

I will review ARCHITECTURE.md within 48 hours of commit.

### Week 4 — Milestone 1

Goal from doc 8: "All singletons load, resources tracked, unit tests pass."

I expect a **buildable project file** that I can run in Godot 4.3 (even if it's just a grey screen with a console showing "ResourceManager initialized"). If you have a playable build, even better. The milestone is not about visuals — it's about proving the architecture boots without errors.

### Week 6

Fab.com pack link + screenshots (see requirement above).

### Week 10 — Milestone 2

From doc 8: "Base loop playable."

I expect to see:
- Grid renders (even as grey cubes)
- Rooms can be placed
- Day cycle advances
- Resources update on screen
- Events fire (text popup)
- The Week 4 regression checklist passing

### Week 20 — Phase 1 Complete

One playable loop: base → mission → debrief → day end → repeat. Save/load works. All 4 lose conditions trigger. The regression test checklist from doc 6 passes 100%.

---

## FINAL WORD

**Spec phase is closed. Build phase begins.**

The game is now well-defined enough that another developer could take these 12 documents and build the project from scratch. That is the mark of a professional game design process.

**Week 1 action items in order:**
1. `git init` — GitHub, private, invite me (read-only)
2. Create Godot 4.3 project at `C:\Users\kibri\projects\blacksite_command\godot\`
3. Create 13 autoload stubs in correct load order
4. Create 5 `.tres` files in `resources/rooms/`
5. Create `MainMenu.tscn`
6. First commit: "Week 1 scaffold complete"
7. Write DEVLOG.md entry

**You will not need another client review document until Week 4 milestone. The spec is done. Build the game.**

Previous versions of this document were titled "Next document needed: 12-blacksite_week1_build_log.md" — that is now a dev deliverable, not a client document. I will not produce doc 13 unless you submit something that requires review. Otherwise, our next communication is at Week 4 milestone.

**Go build.**
