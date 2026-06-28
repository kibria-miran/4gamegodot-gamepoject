# Blacksite Command

## Brief Description
A dark 3D real-time strategy game where you command a covert black ops facility. Manage base infrastructure, research illegal technologies, interrogate detainees, and deploy operatives worldwide. Every decision carries moral weight — pursue ruthless efficiency for maximum results or struggle with conscience at the cost of mission success. A deep resource-management layer intertwines with tactical RTS combat missions.

**Target Audience:** Mature (16+)
**Genre:** 3D Real-Time Strategy / Base Management
**Engine:** Godot 4.x

---

## Backstory
Year 2027. A clandestine multinational initiative known as **Project Chimera** has been reactivated after being buried in the aftermath of the Cold War. Its mandate: operate outside all national and international law to neutralize threats before they materialize.

You are the newly appointed Commander of **Site Omega** — a remote blacksite buried beneath the Siberian permafrost. The previous commander was declared "lost" after a routine interrogation went critical. Your handler, a shadowy figure known only as **Control**, provides objectives but never the full picture.

As you expand Site Omega, you uncover layers of conspiracy. The "threats" you're neutralizing grow increasingly domestic. Detainees whisper about false flags. Your operatives begin asking questions. The line between protecting your country and committing crimes against humanity blurs with every new wing you construct.

---

## Architecture (High-Level)

```
┌─────────────────────────────────────────────────┐
│                  Game Layers                      │
├─────────────────────────────────────────────────┤
│  STRATEGY LAYER (Base Management)                │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │ Facility │ │ Research │ │ Personnel /       │ │
│  │ Building │ │  Tree    │ │ Detainee Mgmt     │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
├─────────────────────────────────────────────────┤
│  TACTICAL LAYER (RTS Missions)                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │ Squad    │ │ Combat   │ │ Extraction /      │ │
│  │ Control  │ │  Encount.│ │ Evac              │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
├─────────────────────────────────────────────────┤
│  NARRATIVE LAYER                                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │ Moral    │ │ Faction  │ │ Ending Branches   │ │
│  │ Choices  │ │ Standing │ │ (4-6 endings)     │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Core Systems
1. **Facility Builder** — Grid-based 3D construction of underground base (rooms, corridors, defenses). Power/oxygen/security routing.
2. **Research Web** — Non-linear tech tree. Weapons, surveillance, interrogation methods, bioweapons, counter-intel. Some techs locked behind moral thresholds.
3. **Personnel System** — Operatives gain XP, traits, stress, loyalty. Can break under pressure, defect, or become assets for rival factions.
4. **Detainee System** — Each detainee has a backstory, intel value, resistance level. Interrogation minigame with multiple approaches (psychological, chemical, physical).
5. **Tactical RTS** — Top-down 3D missions. Small squad tactics (4-8 operatives). Stealth vs. full assault. Dynamic environments.
6. **Moral Compass** — Hidden alignment tracker. Affects available research, ending, operatives' loyalty, and which factions contact you.

---

## Technologies

| Layer | Technology |
|---|---|
| Engine | Godot 4.x (C# or GDScript) |
| 3D Rendering | Godot Forward+ / Mobile renderer |
| Networking (future) | ENet / Godot RPC (if co-op/multiplayer added) |
| AI | Behavior trees (Beehave plugin or custom) |
| UI | Godot Control nodes + Theme system |
| Data | JSON/Resources for game data, SQLite (via GDSQLite) for persistent save |
| Audio | FMOD or Godot AudioStreamPlayer with dynamic mixing |
| Post-Processing | Godot WorldEnvironment (bloom, SSAO, tonemapping) |

---

## Strong Points

- **Unique premise** — Underexplored RTS setting (black ops facility management + tactical missions)
- **Strong narrative potential** — Moral choice system creates replayability (4-6 endings)
- **Dual-layer gameplay** — Base building + tactical RTS appeals to both management and combat fans
- **Scope manageable for solo/small team** — Small squad tactics (not massive armies) keeps asset requirements reasonable
- **Godot is free** — No engine licensing costs

## Weak Points

- **Mature theme limits audience** — Violence, torture, unethical research will restrict platform distribution
- **Complex AI required** — Both for enemy combatants and NPC operatives/detainees
- **Asset-heavy** — 3D models for base tiles, characters, weapons, environments; needs a 3D artist
- **Moral choice systems are hard to balance** — Players may feel punished for roleplaying
- **No established template** — Not many Godot RTS examples to reference; significant custom systems needed
- **Censorship risk** — May be rejected by Steam/App Store if not carefully handled
