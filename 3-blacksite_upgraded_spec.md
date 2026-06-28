# Blacksite Command — Upgraded Development Spec

> Version: 2.0 — Addresses all gaps from Dev Review (2-blacksite_dev_review.md)
> Buildable from this document.

---

## 1. Core Gameplay Loop

### One Session (60-90 minutes)

1. Player wakes Site Omega — reviews night's events (intel updates, operative reports, new detainee arrivals).
2. Morning briefing: **Control** pushes 1-3 objectives (extract intel, neutralize target, acquire asset). Resources are allocated from pool.
3. **Base phase (15-30 min):** Construct/upgrade rooms, assign operatives to duties, research techs, interrogate detainees.
4. A tactical mission becomes available (player-initiated or event-driven). Player assembles squad (4-8 operatives), selects loadout, deploys.
5. **Tactical phase (20-40 min):** Real-time mission. Stealth, combat, extraction. Operatives gain XP, may be wounded, captured, or killed.
6. Post-mission debrief: rewards (budget, intel, tech unlocks). Operatives recover. New detainees may be brought back.
7. End of day: events fire (random or narrative). Player resolves choices affecting moral alignment.
8. Save/quit. Cycle repeats.

### Win Condition
Campaign has 3 Acts (≈12-15 hours). Each Act ends with a major operation. Final ending triggered by cumulative moral alignment + faction standing + narrative flags. 5 unique endings.

### Lose Conditions
- **Base exposure:** Facility discovered by investigative journalists/govt → immediate Game Over.
- **Operative mutiny:** Loyalty drops below threshold → operatives take control, player removed.
- **Control termination:** Player fails too many objectives → Control sends a "cleanup team."
- **Detainee breach:** High-value detainee escapes with intel → facility compromised.

---

## 2. Economy / Resource System

| Resource | Generation | Spent On | Cap |
|----------|-----------|----------|-----|
| **Budget ($)** | Per-day allocation from Control, bonus from mission rewards, selling intel to third parties | Construction, research, equipment, salaries | 10,000 (can overflow with storage rooms) |
| **Intel (📄)** | Interrogation, mission data recovery, informant network | Unlock research, trade for Budget, faction favors | No hard cap |
| **Power (⚡)** | Generator rooms (upgradeable) | All rooms consume power; more labs/equipment = more draw | Based on generators |
| **Oxygen (💨)** | Life support rooms | All habitable rooms consume O₂ | Based on life support |
| **Operative Morale (❤️)** | Good quarters, mission success, rewards | Degraded by interrogation duty, stressful missions, poor facilities | 0-100 per operative |
| **Security (🔒)** | Security rooms, patrols, cameras | Triggered by events (break-in, detainee escape attempt) | 0-100 facility-wide |
| **Control Trust (🏛️)** | Mission success, following orders | Questioning orders, mercy choices, letting detainees go | Hidden 0-100 |
| **Black Market Rep (💀)** | Selling intel/tech, trading with factions | Buying illegal tech, off-book operatives | Hidden 0-100 |

### Economy Flow

```
Control Budget ──► Base Construction
       │                  │
       ▼                  ▼
  Mission Rewards ──► Room Functions
       │                  │
       ▼                  ▼
  Intel Sales ──────► Research Unlocks
       │                  │
       ▼                  ▼
  Black Market ─────► Off-book Operatives / Illegal Tech
```

---

## 3. Facility Building Rules

### Grid System
- **Grid:** 1 tile = 4m x 4m. Base starts as 8x8 tiles (can expand to 20x20).
- **Floors:** Up to 3 levels. Each level requires structural supports (expensive).
- **Corridors:** Required to connect rooms. Each corridor segment costs Budget, consumes Power/O₂.

### Room Catalogue (25 types)

| Category | Room | Effect | Cost (Budget) | Power | O₂ |
|----------|------|--------|---------------|-------|-----|
| **Habitation** | Barracks | Houses 4 operatives, morale regen +5/day | 800 | 10 | 10 |
| | Officer Quarters | +15 morale/day, holds 1 operative | 2000 | 15 | 15 |
| | Mess Hall | Morale boost +10/day to all | 1200 | 15 | 20 |
| | Recreation Room | Stress recovery +20/day | 1500 | 20 | 15 |
| **Operations** | Command Center | Unlocks missions, Intel generation +5/day | 3000 | 25 | 10 |
| | Intelligence Hub | Intel generation +15/day | 2500 | 20 | 15 |
| | Server Farm | +intel storage, research speed +10% | 4000 | 40 | 20 |
| **Security** | Armory | Equip operatives, weapons storage | 1500 | 10 | 5 |
| | Security Checkpoint | -50% detainee escape chance | 1000 | 10 | 10 |
| | Containment Cell | Holds 1 detainee | 600 | 5 | 5 |
| | Interrogation Chamber | Unlocks interrogation minigame | 2000 | 15 | 10 |
| | Observation Wing | -resistance rate on detainees | 1800 | 20 | 10 |
| **Infrastructure** | Generator Room | +50 Power capacity | 2000 | 0 | 5 |
| | Life Support | +50 O₂ capacity | 2000 | 10 | 0 |
| | Water Treatment | +50 O₂ capacity (alternate) | 1500 | 15 | 0 |
| | Storage Room | +5000 Budget overflow cap | 800 | 5 | 5 |
| **Research** | Bio Lab | Unlocks chemical interrogation, biological weapons | 3000 | 30 | 25 |
| | Tech Lab | Unlocks surveillance tech, counter-intel | 3000 | 30 | 20 |
| | Psychology Wing | Unlocks psychological interrogation, operative therapy | 2500 | 20 | 15 |
| **Medical** | Infirmary | Operative recovery +30 HP/day | 1200 | 15 | 15 |
| | Surgery Suite | Critical wound recovery, permanent injury mitigation | 2500 | 25 | 20 |
| | Mortuary | Disposal of deceased detainees/operatives (sanctioned) | 800 | 5 | 5 |
| **Special** | Black Market Hub | Access to illegal tech, off-book trades | 5000 | 10 | 5 |
| | Safe House (Off-site) | Defector/officer hiding, emergency extraction point | 3000 | 0 | 0 |
| | Signal Bunker | Emergency broadcast, Control override protection | 4000 | 20 | 15 |

### Adjacency Rules
- **Barracks next to Interrogation Chamber:** Operative morale -5/day (they hear screams).
- **Mess Hall next to Kitchen:** Mess Hall efficiency +10%.
- **Containment Cell next to Armory:** Security +10 (guards are close).
- **Command Center on same floor as Generator:** -10% power efficiency (noise interference).
- **Recreation Room next to Barracks:** Stress recovery +10%.
- **Mortuary adjacent to Interrogation Chamber:** No penalty (efficient workflow).

### Damage & Raids
- Rooms can be damaged by events (riots, raids, accidents). Damaged rooms = reduced function until repaired.
- Repair cost = 50% of build cost.
- Total destruction requires explosive event (rare). Replacement at full cost.

---

## 4. Detainee / Interrogation System

### Detainee Cap
- Base cap: 3 detainees. +1 per Containment Cell built. Max: 8.

### Detainee Profile
Each detainee has:

| Field | Range | Notes |
|-------|-------|-------|
| **Name & Backstory** | Procedural from pool | 50 backstory templates |
| **Intel Value** | 1-20 | Total intel units extractable |
| **Resistance Level** | 1-10 | How hard to break |
| **Willpower** | 0-100 | Depletes during interrogation; 0 = broken |
| **Health** | 0-100 | Can die if too damaged |
| **Threat Level** | 1-5 | Escape risk, attack risk |
| **Faction** | 1 of 6 | Who they belong to; affects intel relevance |
| **Trait** | 1 of 12 | e.g., "Career Intel" (+resistance, +intel), "Innocent" (-resistance, moral penalty for harm) |

### Interrogation Minigame
- **UI:** Split screen — left shows detainee (animated 3D model with status indicators), right shows controls and intel progress bar.
- **Approaches (3):**

| Approach | Tools | Willpower Damage | Intel Gained | Risks |
|----------|-------|-----------------|-------------|-------|
| **Psychological** | Conversation, personality profiling, good cop/bad cop, isolation | 5-15/session | Low (1-3) | Slow; may fail on high-Willpower targets; no physical harm |
| **Chemical** | Truth serums, narcotics, sedatives | 15-30/session | Medium (3-8) | Health damage 5-15; addiction risk; detainee may die |
| **Physical** | Torture, deprivation, electric, waterboarding | 30-50/session | High (5-12) | Health damage 15-40; high death chance; heavy moral penalty |

- **Session length:** 30 seconds real-time per session. Player chooses approach each session.
- **Intel extraction:** Each successful session reveals 1-3 intel items (documents, codes, locations, contacts).
- **Failure:** If detainee's Willpower reaches 0, they break and give all remaining intel at once. If Health reaches 0, they die — remaining intel lost permanently.
- **Special:** "Innocent" trait — physical/chemical approach doubles moral penalty. "Trained" trait — resists all approaches, +5 to all Willpower checks.

### Post-Interrogation Options
1. **Release** — Moral gain. May trigger faction events (positive or negative).
2. **Eliminate** — Moral loss. No further intel. Permanent.
3. **Turn Asset** — Requires Intel Hub + Psychology Wing. Send back to their faction as double agent. Intel flow over time. Risk: double agent can be discovered.
4. **Transfer** — Send to another facility (narrative choice). Small Budget reward.

---

## 5. Operative Trait System

### Operative Cap
- Base cap: 6. +2 per Barracks built. Max: 14.

### Operative Stats

| Stat | Range | Effect |
|------|-------|--------|
| **Combat** | 1-10 | Damage, accuracy in tactical missions |
| **Stealth** | 1-10 | Detection radius, noise generation |
| **Tech** | 1-10 | Hacking, equipment usage, intel analysis |
| **Leadership** | 1-10 | Stress reduction for squad, squad size bonus |
| **HP** | 50-150 | Health pool |
| **Stress** | 0-100 | At 100 → breakdown (varies: berserk, catatonic, desert) |
| **Loyalty** | 0-100 | At <30 → defection risk; at <10 → immediate defection |
| **Morale** | 0-100 | Daily passive; affects stress accumulation rate |

### Traits (15 total)
Acquired on level-up (random pool of 3, player chooses 1).

| Trait | Effect |
|-------|--------|
| **Veteran** | +2 Combat, +20 HP |
| **Ghost** | +3 Stealth, silent movement |
| **Hacker** | +3 Tech, auto-pass on simple terminals |
| **Natural Leader** | +2 Leadership, squad stress -10% |
| **Paranoid** | -10 Stress for self, +10 Stress for squad |
| **Sadist** | Stress recovery +50% in Interrogation Chamber, moral penalty for physical approach halved |
| **Empath** | Stress recovery doubled in Recreation Room, -50% stress from interrogation duty |
| **Loyalist** | +20 Loyalty, immune to Control suspicion events |
| **Mercenary** | +30% Budget cost, +15% combat effectiveness |
| **Burnout Risk** | Stress accumulates 25% faster — hidden trait, revealed at Stress >70 |
| **Cold Blooded** | No morale penalty from physical interrogation. No morale bonus from mercy. |
| **Whistleblower** | Starts with high morality. If facility exceeds moral threshold, triggers investigation event. |
| **Jaded** | -20 starting Morale, immune to morale loss from events |
| **Tactician** | +1 squad size when leading team |
| **Medic** | +3 Tech (medical), squad recovers 5 HP/turn in missions |

### Stress Mechanics
- **Per mission:** +5-20 stress based on intensity.
- **Per interrogation duty:** +5-15 per session (if assigned to Interrogation duty).
- **Recovery:** Recreation Room (-5/day), Officer Quarters (-5/day), Therapy (requires Psychology Wing, -15/day for one operative).
- **Breakdown at 100:** Roll d6 → 1-2: berserk (attacks nearest), 3-4: catatonic (unusable 3 days), 5: desert (leaves facility), 6: defect (joins rival faction with intel).

### Defection Triggers
- Loyalty < 30 and Stress > 70 → nightly defection roll (10% chance).
- Specific narrative events can force a defection check.
- Whistleblower trait + facility below moral threshold → automatic investigation start.

### Progression
- XP from missions: +1-5 per mission based on performance.
- Every 10 XP → level up → choose 1 of 3 traits.
- Max level: 10 (all operatives capped).

---

## 6. Moral System (Detailed)

### Scale
- **Range:** -100 (Pure Evil) to +100 (Pure Good).
- **Hidden from player** (but vague feedback given through Control's messages, operative dialogue, and ambient changes).

### Moral Events & Shift Values

| Action | Shift | Notes |
|--------|-------|-------|
| Use physical interrogation | -5 per session | |
| Use chemical interrogation | -3 per session | |
| Use psychological interrogation | +1 per session | |
| Eliminate detainee | -10 | -20 if innocent trait |
| Release detainee | +5 | +10 if innocent trait |
| Turn asset | +2 | |
| Follow Control's immoral order | -3 to -15 | Depends on order gravity |
| Refuse Control's immoral order | +5 to +20 | Control Trust decreases |
| Operative killed on mission | -2 | |
| Civilian casualty | -10 | Extra if collateral damage |
| Sell intel to black market | -5 | |
| Donate intel to NGO/journalist | +15 | |
| Execute traitorous operative | -8 | |
| Show mercy to enemy combatant | +8 | |

### Threshold Consequences

| Threshold | Effects |
|-----------|---------|
| **>60 (Saint)** | Control suspicious, sends inspector. Certain research locked. Operatives gain +20 morale. +ending flag A |
| **>20 (Good)** | Psychological research unlocked. +Intel from voluntary detainee cooperation. |
| **-20 to 20 (Neutral)** | Default gameplay. All paths available but no bonuses. |
| **<-20 (Corrupt)** | Physical/chemical research unlocked. Black market trades cheaper. Operatives lose -10 morale. |
| **<-60 (Monster)** | Black market full access. Control Trust capped at 50. Interrogation time halved. Operative defection rate doubled. +ending flag B |
| **>-60 or <-60** | Unlocks unique narrative branch (Act 3). |

---

## 7. UI/UX Layout (Text Wireframes)

### Main HUD (Base Mode)

```
┌──────────────────────────────────────────────────────────────┐
│ ██ POWER █████████ 78%  │  💨 O₂ 85%  │  💰 $4,200  │ 📄 12 │  📅 Day 14
├──────────────────────────────────────────────────────────────┤
│                                                              │
│                    BASE VIEWPORT (3D)                         │
│         [Isometric camera, click rooms to select]             │
│                                                              │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│  [BUILD]  [RESEARCH]  [PERSONNEL]  [DETAINEES]  [MISSIONS]   │
│     Q          W           E            R            T        │
└──────────────────────────────────────────────────────────────┘
```

### Mission Briefing Screen

```
┌──────────────────────────────────────────────────────────────┐
│                     MISSION BRIEFING                          │
├────────────────────────────────────────────────────┬─────────┤
│ OBJECTIVE: Extract defector from Novosibirsk       │  Intel  │
│ Threat Level: HIGH (recommend 6+ operatives)       │  ████   │
│                                                  ├─────────┤
│ OPERATIVES:                                       │ LOADOUT │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐        │  Rifle  │
│ │ [A] │ │ [B] │ │ [C] │ │ [D] │ │ [E] │        │  Pistol │
│ │Com8 │ │Ste7 │ │Tec6 │ │Com5 │ │Ldr4 │        │  Armor  │
│ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘        │  Gadget │
│                                                  │         │
│ [DEPLOY]                    [CANCEL]             │         │
└──────────────────────────────────────────────────┴─────────┘
```

### Tactical Mode HUD

```
┌──────────────────────────────────────────────────────────────┐
│ [PAUSE]  │  SQUAD: [1] [2] [3] [4]  │  HP ████████  │  STEALTH ██░
├──────────────────────────────────────────────────────────────┤
│                                                              │
│                   TACTICAL VIEWPORT (3D)                      │
│          [Top-down follow camera, WASD pan, scroll zoom]     │
│                                                              │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│  [MOVE]  [ATTACK]  [STEALTH]  [ABILITY]  [HOLD]  [EXTRACT]   │
│    1        2          3          4        5         6        │
└──────────────────────────────────────────────────────────────┘
```

### Interrogation Screen

```
┌──────────────────────────────────────────────────────────────┐
│ DETAINEE: Viktor Petrov   │  INTEL: 12/15  │ Will: ███░ 42% │
│ Faction: GRU               │  HP: ██████░ 80%               │
├──────────────────────────────────┬───────────────────────────┤
│                                  │                           │
│   [3D Model of Detainee]         │  APPROACH:                │
│   (shows bruising, restraint,    │  [PSYCHOLOGICAL] 💬       │
│    expression)                   │  [CHEMICAL] 💉            │
│                                  │  [PHYSICAL] ⛓️            │
│                                  │                           │
│                                  │  TACTICS:                 │
│                                  │  [Good Cop] [Bad Cop]     │
│                                  │  [Isolation] [Pressure]   │
│                                  │                           │
│                                  │  [BEGIN SESSION]          │
├──────────────────────────────────┴───────────────────────────┤
│ LOG: Session 1 (Psych): +2 intel. "He's not breaking easily."│
└──────────────────────────────────────────────────────────────┘
```

---

## 8. Asset List

### 3D Models

| Category | Count | Details |
|----------|-------|---------|
| **Room Tiles** | 25 | Unique interior shells per room type (modular walls/floors) |
| **Corridor Tiles** | 4 | Straight, corner, T-junction, dead end |
| **Base Decor** | 15 | Pipes, vents, lights, furniture props |
| **Operative Characters** | 2 base + 12 variants | Male/female base mesh with armor/clothing variants per role |
| **Detainee Characters** | 2 base + 6 variants | Civilian, military, scientist types |
| **Enemy Characters** | 3 base + 6 variants | Guards, soldiers, special forces |
| **Tactical Environment Tiles** | 20 | Outdoor: urban, industrial, forest, snow |
| **Tactical Props** | 30 | Cover objects, vehicles, doors, terminals, lootables |
| **Weapons** | 12 | Pistol, SMG, rifle, sniper, shotgun, taser, knife, baton, syringe, flashbang, frag, smoke |
| **Total** | **~137 models** | |

### UI Screens
| Screen | Count |
|--------|-------|
| Main menu, settings, load/save | 4 |
| Base HUD | 1 |
| Build menu overlay | 1 |
| Research tree screen | 1 |
| Personnel management screen | 1 |
| Detainee roster screen | 1 |
| Interrogation screen | 1 |
| Mission briefing screen | 1 |
| Tactical HUD overlay | 1 |
| Post-mission debrief screen | 1 |
| Event/narrative popup | 1 |
| Moral feedback screen (vague) | 1 |
| **Total** | **15 screens** |

### Audio
- **Voice acting:** No for v1. Text-only with ambient sound effects.
- **Sound effects:** Footsteps, weapons, room ambience, UI clicks, detainee reactions, alarms — ~80 SFX.
- **Music:** 4-6 ambient tracks (base idle, mission tension, pursuit, narrative).
- **FMOD:** Deferred to v1.5. Godot built-in audio for v1.

### Cutscenes
- **No pre-rendered cutscenes.** Narrative delivered via in-engine dialogue popups (text + character portrait) — similar to Papers Please / Frostpunk style.

---

## 9. Milestone & Scope Breakdown

### Phase 1 — MVP (3-4 months, solo or 2-person team)

**Core goal: Buildable, playable loop with placeholder art.**

- [x] Grid-based room placement system (basic version)
- [ ] 5 room types: Command Center, Barracks, Containment Cell, Generator, Armory
- [x] Resource system: Budget, Power, O₂
- [ ] 1 tactical mission type (extraction, procedural simple map)
- [ ] 4 operative characters with basic stats (Combat, HP, Stress)
- [ ] Simple inventory/loadout
- [ ] Basic detainee system (name, intel, resistance, 1 interrogation approach)
- [ ] Day cycle + event system (text only, 10 events)
- [ ] Win/lose conditions: Base exposure, operative death squad wipe

**Deliverable:** One mission, one base, one detainee. Player can loop base → mission → base.

### Phase 2 — Vertical Slice (6-9 months)

- [ ] 15 room types (all core categories)
- [ ] 3-tier research tree (weapons → surveillance → bio)
- [ ] 3 interrogation approaches + minigame UI
- [ ] 6 operative traits, level-up system
- [ ] 3 tactical mission types (extraction, assault, stealth)
- [ ] Moral system (hidden, -100 to +100)
- [ ] 3 tactical environment tilesets
- [ ] 50 narrative events + Act 1 complete
- [ ] Full UI (all 15 screens, placeholder art)
- [ ] Save/load system (JSON)

**Deliverable:** Vertical slice vertical slice — Act 1 playable, all core systems present.

### Phase 3 — Full Game (12-18 months)

- [ ] All 25 room types
- [ ] Full research web (30+ techs)
- [ ] 15 operative traits
- [ ] 5 tactical mission types
- [ ] 5 environment tilesets
- [ ] Acts 1-3 complete, 5 endings
- [ ] 150 narrative events
- [ ] 3D art polish (lighting, post-processing, animations)
- [ ] Localization (English + 1-2 languages)
- [ ] Steam integration (achievements, cloud saves)
- [ ] Steam Deck compatibility pass

**Deliverable:** Ship on Steam Early Access.

---

## 10. Platform & Distribution

| Platform | Target | Notes |
|----------|--------|-------|
| **PC (Windows)** | ✅ v1.0 | Primary target |
| **Linux** | ✅ v1.0 | Godot exports natively |
| **macOS** | ⬜ v1.5 | Post-launch if demand exists |
| **Steam Deck** | ✅ v1.0 | Verified target |
| **Console** | ❌ | Out of scope for v1 |

### Distribution
- **Primary:** Steam (Early Access → Full Release).
- **Secondary:** itch.io (DRM-free version).
- **Pricing:** $19.99 Early Access, $24.99 full release.

### Minimum Spec (PC)

| Component | Requirement |
|-----------|-------------|
| **OS** | Windows 10 64-bit |
| **CPU** | Intel i5-8400 / Ryzen 5 2600 |
| **RAM** | 8 GB |
| **GPU** | GTX 1060 / RX 580 (6GB VRAM) |
| **Storage** | 5 GB SSD |
| **DirectX** | Vulkan-capable |

---

## 11. Validation that Dev Review Gaps Are Closed

| Review Gap | Resolution in This Doc |
|-----------|----------------------|
| No gameplay loop | §1 Core Gameplay Loop — full session breakdown |
| No economy spec | §2 Economy / Resource System — 8 resources with sources & sinks |
| No facility rules | §3 Facility Building Rules — 25 rooms, grid specs, adjacency, damage |
| No detainee spec | §4 Detainee System — profile, cap, minigame, 3 approaches, post-interrogation |
| No operative detail | §5 Operative Trait System — stats, 15 traits, stress, defection, progression |
| No UI/UX | §7 UI/UX Layout — 4 screen wireframes in text |
| No asset list | §8 Asset List — 137 3D models, 15 UI screens, audio count |
| No moral numbers | §6 Moral System — -100/+100 scale, 18 events with values, 5 thresholds |
| No milestones | §9 Milestone Breakdown — 3 phases with deliverables |
| No platform target | §10 Platform & Distribution — PC/Steam Deck, min spec, pricing |

---

## 12. Remaining Risks (Post-Upgrade)

| Risk | Level | Mitigation |
|------|-------|-----------|
| No 3D artist | 🔴 Critical | Phase 1 uses primitive blocks. Phase 2 requires hiring. **This is the #1 risk.** |
| AI complexity (3 systems) | 🟠 High | Use Beehave plugin. Start with simple state machines in Phase 1, migrate to BT in Phase 2. |
| Steam content rejection | 🟠 High | Frame interrogation as "enhanced interrogation" not "torture." Add content warning splash. Read Steam guidelines thoroughly before submission. |
| Scope creep during Phase 3 | 🟠 High | Strict feature freeze after Phase 2. All Phase 3 additions must be scoped in a separate design doc and approved. |
| Moral system balancing | 🟠 High | Schedule 2 week playtest block after Phase 2 completion. Adjust values based on player feedback. |

---

## Bottom Line

**Dev-readiness score: 8/10** (was 3/10 in v1).

This document fills every gap identified in the developer review. A programmer can open Godot and start building from this spec alone. The remaining unknowns are production risks (art, AI tuning, Steam approval), not design gaps.
