# Blacksite Command — Developer Review & Client Requirements
> Reviewed by: Senior Game Developer (Godot / RTS specialist)
> Document version: 1.0

---

## VERDICT

**Can you build this from this .md alone?**
> **No. Not yet.** The .md is a strong *vision document* — it tells me *what* the game is, but almost nothing about *how* it works at implementation level. Think of it as a game pitch deck, not a development spec. Before a single line of code is written, a lot of gaps need to be filled.

---

## WHAT THIS .MD DOES WELL ✅

| Strength | Why it matters |
|----------|---------------|
| Clear genre identity | RTS + base builder is well defined — no confusion about game type |
| Layered architecture diagram | Three-layer split (Strategy / Tactical / Narrative) is clean and buildable |
| Technology stack chosen | Godot 4, Beehave, GDSQLite, FMOD — solid, realistic choices |
| Narrative hook is strong | The moral ambiguity angle creates genuine replayability motivation |
| Honest about weak points | Client already knows about scope, censorship, AI complexity — good self-awareness |
| Target audience stated | Mature 16+ sets content expectations early |
| Scope awareness | Small squad (4-8) instead of massive armies — shows realistic thinking |

---

## WHAT THIS .MD IS MISSING ❌

### 1. No Gameplay Loop Definition
The single most critical missing piece. What does the player actually **do in one session?**
```
Missing:
- How long is one in-game day/cycle?
- What triggers a tactical mission? (automatic? player-initiated?)
- Can the base be attacked while player is on a mission?
- What is the win condition per mission? Per campaign?
- What is the lose condition?
```

### 2. No Economy / Resource System Spec
The doc mentions "deep resource-management layer" but defines zero resources.
```
Missing:
- What resources exist? (Budget? Personnel? Power? Intel? Supplies?)
- How are resources generated? (Missions? Research? Passive income?)
- What do resources buy? (Rooms? Research? Operatives?)
- Is there a budget from "Control"? Can it be cut off?
```

### 3. No Facility Building Rules
"Grid-based 3D construction" — but no spec on:
```
Missing:
- Grid size? (tile dimensions, floor count, max expansion)
- Room types list (even a rough one)
- Adjacency rules? (does interrogation room next to barracks cause stress?)
- Power/oxygen system — how does it work mechanically?
- Can rooms be destroyed? Raided?
```

### 4. No Detainee / Interrogation Spec
This is a core feature — the most controversial one — and has zero mechanical detail.
```
Missing:
- How many detainees max at one time?
- What does the interrogation minigame actually look like?
- What does "resistance level" mean as a number?
- What intel do detainees give and how does it unlock content?
- What happens after interrogation? (Release? Eliminate? Turn asset?)
```

### 5. No Operative Trait System Detail
```
Missing:
- How many operatives can player have?
- What traits exist? How are they acquired?
- What does "stress" do mechanically? Does it cap performance?
- Defection — what triggers it? What are consequences?
- Skill tree or flat XP?
```

### 6. No UI/UX Wireframes or Flow
```
Missing:
- Main HUD layout
- Base management screen layout
- Mission briefing screen
- How does player switch between strategy and tactical layer?
```

### 7. No Asset List
```
Missing:
- How many unique room types need 3D models?
- How many character types (operatives, detainees, enemies)?
- How many environments for tactical missions?
- Voice acting? (yes/no)
- Cutscenes? (yes/no)
```

### 8. No Moral System Numbers
"Hidden alignment tracker" — but:
```
Missing:
- What is the scale? (-100 to +100? 5 tiers?)
- What events shift it and by how much?
- At what thresholds does it change available research/endings?
- Does the player ever see the number?
```

### 9. No Milestone or Scope Breakdown
```
Missing:
- What is MVP (Minimum Viable Prototype)?
- What is cut if budget runs out?
- Phase 1 / Phase 2 / Phase 3?
```

### 10. No Platform Target
```
Missing:
- PC only? (Steam, itch.io?)
- Console planned?
- Minimum spec / recommended spec?
```

---

## QUESTIONS I NEED ANSWERED (Client Side)

As a developer, before I touch Godot, I need the client to answer these:

### Critical (Blockers)
1. **What is the core gameplay loop?** Write it in 5 sentences: player wakes up, does X, then Y happens, then Z, session ends when...
2. **What resources exist in the game?** Name every currency/resource.
3. **What is the win condition?** Campaign end? Infinite sandbox? Multiple endings trigger how?
4. **What is the lose condition?** Base destroyed? Exposed to the world? Operative mutiny?
5. **Do you have a 3D artist?** This is the single biggest risk. Without one, the game cannot ship in 3D.

### Important (Design)
6. What does the interrogation minigame look like? (Describe it like you're playing it)
7. How many rooms total are planned for the facility builder?
8. Is multiplayer (co-op) in scope for v1.0 or cut entirely?
9. Will there be voice acting or text only?
10. What is your timeline and budget?

### Good to Know (Scope)
11. Which of the 4-6 endings are you designing first?
12. Is FMOD confirmed or is Godot's built-in audio acceptable for v1?
13. Any reference games? (XCOM? Dungeon Keeper? Uplink? Papers Please?)

---

## RISK ASSESSMENT

| Risk | Level | Notes |
|------|-------|-------|
| No 3D artist | 🔴 Critical | Game cannot ship without one. Placeholder cubes are not acceptable for market |
| AI complexity | 🔴 Critical | Behavior trees for enemies + operative AI + detainee AI = 3 separate AI systems |
| Moral system balance | 🟠 High | Easy to make players feel punished unfairly. Needs dedicated design pass |
| Steam rejection | 🟠 High | Torture/interrogation mechanics will trigger review. Need legal/content advice |
| Scope creep | 🟠 High | 6 core systems is a lot — needs strict MVP definition |
| Godot RTS tooling | 🟡 Medium | Limited reference projects; expect to build most systems from scratch |
| FMOD licensing | 🟡 Medium | FMOD is free for small projects but has revenue thresholds |
| Save system complexity | 🟡 Medium | GDSQLite is good but complex game state needs careful schema design |

---

## RECOMMENDED NEXT STEPS

Before writing any code, produce these documents in order:

```
1. GAMEPLAY LOOP DOC       — one paragraph, one session explained
2. RESOURCE SYSTEM DOC     — all currencies, sources, sinks
3. ROOM CATALOGUE          — every room type, what it does, what it costs
4. OPERATIVE SPEC          — traits list, stress mechanics, defection triggers
5. INTERROGATION SPEC      — minigame design, resistance system
6. MORAL SYSTEM SPEC       — scale, thresholds, consequences
7. MISSION STRUCTURE DOC   — how tactical layer is triggered and resolved
8. ASSET LIST              — 3D models needed, UI screens needed
9. MVP DEFINITION          — what ships in v1, what is cut
10. PLATFORM + DISTRIBUTION PLAN
```

---

## OVERALL SCORE AS A DEV SPEC

| Category | Score | Comment |
|----------|-------|---------|
| Vision clarity | 9/10 | Excellent — I know exactly what kind of game this is |
| Mechanical detail | 2/10 | Almost nothing — needs full design docs |
| Technical feasibility | 7/10 | Stack is realistic, risks acknowledged |
| Asset planning | 1/10 | Not addressed at all |
| Scope realism | 5/10 | Ambitious but not impossible for small team with 2-3 years |
| **Overall dev-readiness** | **3/10** | Strong foundation, not yet buildable |

---

## BOTTOM LINE

This .md is an excellent **pitch document** and a great starting point. The concept is solid, the tech stack is realistic, and the narrative hook is genuinely interesting. But as a developer I cannot open Godot yet — I'd be guessing at half the systems.

**Give me the 10 docs listed above and this becomes a buildable game.**
The bones are good. Now put meat on them.
