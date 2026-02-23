  # Multi-Ability Arena — Game Overview

> A 3v3 multiplayer hero combat experience built entirely in UEFN with Verse, designed to showcase advanced gameplay engineering, custom device authoring, and polished player-facing systems.

---

## Table of Contents

1. [High-Level Concept](#1-high-level-concept)
2. [Player Fantasy & Experience Pillars](#2-player-fantasy--experience-pillars)
3. [Game Flow](#3-game-flow)
4. [Heroes & Abilities](#4-heroes--abilities)
5. [Core Gameplay Systems](#5-core-gameplay-systems)
6. [Multiplayer & Match Systems](#6-multiplayer--match-systems)
7. [Map & Arena Design](#7-map--arena-design)
8. [HUD & Player Feedback](#8-hud--player-feedback)
9. [Technical Architecture](#9-technical-architecture)
10. [Custom Verse Devices](#10-custom-verse-devices)
11. [Data Structures & Algorithms](#11-data-structures--algorithms)
12. [Vector Math Applications](#12-vector-math-applications)
13. [Polish & Juice](#13-polish--juice)
14. [Scope & Milestones](#14-scope--milestones)
15. [Publishing & Portfolio Deliverables](#15-publishing--portfolio-deliverables)

---

## 1. High-Level Concept

**Genre:** Team-based ability arena  
**Mode:** 3v3 (6 players)  
**Match Length:** 5–8 minutes  
**Platform:** Fortnite (UEFN Island)  
**Win Condition:** First team to reach the score limit, or the team with the highest score when the timer expires.

Players pick from a roster of distinct heroes, each with a primary ability, a secondary ability, and an ultimate. Teams fight across a symmetrical arena, earning points for eliminations. Strategic ability usage, team composition, and map control determine the winner.

---

## 2. Player Fantasy & Experience Pillars

### Fantasy
*"I'm a powerful hero with unique abilities, and my team is counting on me to use them at exactly the right moment."*

### Pillars

| Pillar | Description |
|---|---|
| **Readable Combat** | Every ability has clear visual/audio tells so players can react and counterplay. |
| **Meaningful Choices** | Hero selection, ability timing, and positioning all matter. Button-mashing loses to smart play. |
| **Team Synergy** | Abilities are designed so combinations between heroes feel powerful and rewarding. |
| **Fast Pacing** | Short respawn timers and compact map keep downtime low and action high. |
| **Accessible Depth** | Easy to pick up in the first round; room to improve for dozens of matches. |

---

## 3. Game Flow

### Pre-Match
```
Lobby (waiting for players)
  → Team Assignment (auto-balance or manual)
    → Hero Select Phase (30 s countdown, default assigned if no pick)
      → Spawn into Arena
```

### Match Loop
```
Round Start (brief invulnerability)
  → Combat Phase
    → Elimination → Victim respawns after delay → Combat continues
  → (Optional) Mid-match event triggers at halftime
  → Timer expires OR score limit reached
    → Match End
```

### Post-Match
```
Victory/Defeat screen with stats
  → MVP highlight (most elims, most ability damage, most assists)
    → Return to Lobby / Replay
```

### State Diagram

```
WAITING_FOR_PLAYERS → HERO_SELECT → COUNTDOWN → IN_PROGRESS → MATCH_END → WAITING_FOR_PLAYERS
```

Each state is managed by a central `game_state_manager` Verse device that gates transitions and broadcasts events to all subsystems.

---

## 4. Heroes & Abilities

### Roster (4 heroes at launch)

Each hero has **3 abilities** and a **passive trait**.

---

#### 4.1 — Titan (Tank / Front-line)

| Slot | Name | Description | Cooldown | Details |
|---|---|---|---|---|
| Passive | **Fortified** | Takes 15% reduced damage while standing still for more than 1 s. | — | Encourages holding ground. |
| Primary (L1) | **Seismic Slam** | Smashes the ground, dealing AoE damage in a 5 m radius and applying a 1.5 s slow. | 8 s | Uses radial distance check from impact point. |
| Secondary (L2) | **Barrier Charge** | Dashes forward 10 m. Enemies hit take damage and are knocked back. | 12 s | Raycast in movement direction; knockback uses vector math. |
| Ultimate (R1+L1) | **Earthshatter** | After a 1 s wind-up, sends a shockwave in a 15 m cone dealing heavy damage and stunning for 2 s. | 60 s | Cone check via dot-product against forward vector. |

---

#### 4.2 — Specter (Flanker / Assassin)

| Slot | Name | Description | Cooldown | Details |
|---|---|---|---|---|
| Passive | **Shadow Step** | Move speed increased by 10% when no enemies are within 20 m line-of-sight. | — | Distance + LOS check each tick. |
| Primary (L1) | **Phantom Strike** | Teleports 8 m in the aim direction and deals burst damage to the first enemy within 2 m of the destination. | 6 s | Destination = origin + aimDir * 8 m; overlap sphere at dest. |
| Secondary (L2) | **Smoke Bomb** | Drops a smoke cloud at current position, granting invisibility for 3 s or until attacking. | 14 s | Status effect: `Invisible`. Broken on damage-dealt event. |
| Ultimate (R1+L1) | **Death Mark** | Marks a target enemy. For 6 s, marked target takes 30% bonus damage from all sources. | 50 s | Status effect: `Marked`. Tracked via agent-keyed map. |

---

#### 4.3 — Sage (Support / Healer)

| Slot | Name | Description | Cooldown | Details |
|---|---|---|---|---|
| Passive | **Mending Aura** | Nearby allies within 8 m regenerate 2 HP/s. | — | Periodic distance check against teammates. |
| Primary (L1) | **Healing Orb** | Launches a projectile that heals the first ally hit for 40 HP. Damages enemies for 20 HP if it hits them instead. | 5 s | Projectile with friend-or-foe detection. |
| Secondary (L2) | **Purify** | Removes all negative status effects from a targeted ally within 15 m. | 16 s | Iterates status effect list, removes entries with `negative` tag. |
| Ultimate (R1+L1) | **Sanctuary** | Creates a 6 m radius zone that heals allies for 25 HP/s and blocks enemy projectile abilities for 8 s. | 65 s | Area device; projectile collision toggle. |

---

#### 4.4 — Blaster (Ranged / Damage)

| Slot | Name | Description | Cooldown | Details |
|---|---|---|---|---|
| Passive | **Lock On** | Consecutive hits on the same target within 4 s deal escalating damage (+5% per stack, max 4 stacks). | — | Per-target hit counter with timestamp decay. |
| Primary (L1) | **Concussion Rocket** | Fires a projectile that explodes on impact, dealing AoE damage in a 3 m radius and applying knockback. | 7 s | Explosion origin = hit point; knockback vector = normalize(target - origin) * force. |
| Secondary (L2) | **Gravity Snare** | Throws a device that pulls enemies within 5 m toward its center over 2 s. | 15 s | Each tick: direction = normalize(snarePos - enemyPos); apply velocity. |
| Ultimate (R1+L1) | **Orbital Barrage** | After a 2 s channel, rains down 5 explosions over a targeted 10 m area over 3 s. | 55 s | Random points within radius; each explosion is an AoE damage event. |

---

### Hero Balance Targets

| Stat | Titan | Specter | Sage | Blaster |
|---|---|---|---|---|
| HP | 250 | 150 | 175 | 175 |
| Move Speed | 0.85× | 1.15× | 1.0× | 1.0× |
| Role | Disruptor / Anchor | Pick / Flank | Sustain / Utility | Damage / Zone |

---

## 5. Core Gameplay Systems

### 5.1 Health System

- Each hero has a maximum HP defined by their class.
- Damage is processed through a central `apply_damage(source, target, amount, damage_type)` function.
- Healing is processed through `apply_healing(source, target, amount)`.
- When HP reaches 0, the elimination event fires.
- **Overkill protection:** damage cannot carry below 0.
- **Damage types:** `Physical`, `Ability`, `Ultimate`, `Environmental`. Used for stat tracking and potential resistances.

### 5.2 Damage Pipeline

```
Incoming Damage
  → Check for invulnerability status
  → Apply damage modifiers (Titan passive, Death Mark, etc.)
  → Subtract from current HP
  → Fire OnDamagedEvent (for HUD flash, hit markers, etc.)
  → If HP <= 0 → fire OnEliminatedEvent
```

### 5.3 Ability System

Each ability is represented by a Verse struct:

```
ability_definition := struct:
    Name : string
    Cooldown : float
    Duration : float
    DamageAmount : float
    HealAmount : float
    Range : float
    Radius : float
    AbilityType : ability_type  # enum{Primary, Secondary, Ultimate}
    DamageType : damage_type
```

**Activation flow:**
1. Player presses ability input.
2. System checks `is_on_cooldown` (compares current time against `last_used + cooldown`).
3. If off cooldown, execute ability logic (targeting, projectile spawn, area check, etc.).
4. Start cooldown timer.
5. Update HUD cooldown display.

### 5.4 Cooldown System

- Cooldowns are tracked per-agent, per-ability using a map: `map(agent, map(ability_slot, float))` where the float is the timestamp of last activation.
- A helper function `get_remaining_cooldown(agent, slot) -> float` is called every HUD tick.
- Ultimate cooldowns only begin charging after the ultimate effect ends.

### 5.5 Status Effect System

Status effects are stored in a per-agent array:

```
status_effect := struct:
    EffectType : effect_type  # enum{Slow, Stun, Invisible, Marked, Invulnerable, HealOverTime, ...}
    Duration : float
    StartTime : float
    Magnitude : float
    IsNegative : logic  # used by Sage's Purify
    Source : agent
```

- Processed each tick: expired effects are removed.
- Certain effects (Stun) disable ability input.
- Certain effects (Invisible) alter player visibility.
- Stacking rules: same-type effects from the same source refresh duration; from different sources, the strongest magnitude wins.

### 5.6 Respawn System

1. On elimination, the player enters a spectator state.
2. A respawn timer begins (4 s base).
3. On timer expiry, the player spawns at a team-specific spawn point chosen to be the farthest from enemies (weighted random).
4. A 2 s invulnerability period begins post-spawn.

### 5.7 Score System

- +1 point per elimination.
- +0.5 point per assist (dealt damage to the eliminated player within 10 s of their death, but did not land the final blow).
- Team score = sum of individual scores.
- Score limit: configurable, default **20**.
- Displayed on persistent HUD scoreboard.

---

## 6. Multiplayer & Match Systems

### 6.1 Player Join/Leave

- On join: assign to team with fewer players (or random if equal). Initialize hero as default until hero select.
- On leave: remove from team roster, clean up status effects, release any held resources. If a team drops below minimum, pause match and wait for backfill or forfeit timer (30 s).

### 6.2 Team Assignment

- Two teams: **Alpha** and **Bravo**.
- Max 3 per team.
- Late joiners are assigned to the team with the fewest members.

### 6.3 Match Timer

- Default: **6 minutes**.
- Displayed on HUD.
- At 60 s remaining, an audio + visual "one minute warning" fires.
- At 0 s, the match ends. Team with higher score wins. Tie → sudden death (next elimination wins).

### 6.4 Game State Manager

The `game_state_manager` device is the authoritative controller for all match flow. It owns the state machine:

| State | Entry Condition | Exit Condition |
|---|---|---|
| `WaitingForPlayers` | Island loaded | Minimum player count reached (4) |
| `HeroSelect` | Min players reached | 30 s timer expires |
| `Countdown` | Hero select ends | 5 s countdown expires |
| `InProgress` | Countdown ends | Score limit reached OR timer expires |
| `MatchEnd` | Match concludes | 15 s post-match timer expires |

All other systems subscribe to state-change events to enable/disable themselves appropriately (e.g., abilities are disabled during `HeroSelect` and `MatchEnd`).

---

## 7. Map & Arena Design

### Layout Philosophy

- **Symmetrical** across a central axis so neither team has a positional advantage.
- **Three lanes** with connecting flanks to support different hero playstyles.
- **Verticality** via ramps and platforms to reward positioning and create interesting vector-math scenarios (knockback off ledges, projectile arcs).

### Key Areas

| Area | Purpose |
|---|---|
| **Center Point** | Open area, high risk/high reward. Line-of-sight from multiple angles. |
| **Side Lanes** | Narrower corridors favoring close-range heroes and ambush play. |
| **High Ground Platforms** | Elevated positions on each side for ranged heroes. Accessible by ramps. |
| **Team Bases** | Spawn areas with one-way shields preventing spawn camping. |
| **Hazard Zones** | Environmental areas (e.g., a pit) where knockback abilities become extra dangerous. |

### Rough Top-Down Layout

```
  ┌──────────────────────────────────────────┐
  │  [ALPHA SPAWN]                           │
  │   ══════╗        ┌─────────┐             │
  │         ║  RAMP  │ HIGH    │             │
  │   LANE  ║────────│ GROUND  │  LANE      │
  │    A    ║        └─────────┘    C        │
  │         ║                       ║        │
  │   ══════╝   ┌─────────────┐    ║════    │
  │             │   CENTER    │    ║        │
  │             │   POINT     │    ║        │
  │   ══════╗   └─────────────┘    ║════    │
  │         ║                       ║        │
  │   LANE  ║        ┌─────────┐    ║        │
  │    A    ║────────│ HIGH    │  LANE      │
  │         ║  RAMP  │ GROUND  │    C        │
  │   ══════╝        └─────────┘             │
  │                          [BRAVO SPAWN]   │
  └──────────────────────────────────────────┘
           LANE B (center corridor)
```

---

## 8. HUD & Player Feedback

### HUD Elements

| Element | Position | Details |
|---|---|---|
| **Health Bar** | Bottom-center | Numerical + bar. Flashes red on damage, pulses green on heal. |
| **Ability Icons (×3)** | Bottom-center, above health | Show cooldown sweep, grayed out when unavailable, glow when ready. |
| **Team Score** | Top-center | Alpha score (left) vs Bravo score (right). |
| **Match Timer** | Top-center, below score | MM:SS format. Turns red at 60 s. |
| **Kill Feed** | Top-right | "[Player] eliminated [Player] with [Ability]" — fades after 5 s. |
| **Status Effect Icons** | Below health bar | Small icons for active buffs/debuffs with remaining duration. |
| **Hit Marker** | Crosshair | Flashes on successful damage; special marker for elimination. |
| **Damage Numbers** | World-space | Float up from damaged target. Color-coded by damage type. |
| **Respawn Timer** | Center screen | Large countdown during death state. |

### Audio Feedback

| Event | Sound |
|---|---|
| Ability activated | Unique per ability |
| Ability on cooldown (attempted use) | Error buzz |
| Damage taken | Impact thud + directional indicator |
| Elimination scored | Satisfying confirm chime |
| Low health | Heartbeat loop |
| Match countdown | Tick... tick... tick... HORN |

---

## 9. Technical Architecture

### System Dependency Graph

```
game_state_manager
  ├── team_manager
  │     └── player_manager (join/leave/assignment)
  ├── hero_select_manager
  │     └── hero_registry (definitions, stats)
  ├── ability_system
  │     ├── cooldown_tracker
  │     ├── status_effect_manager
  │     └── damage_pipeline
  │           ├── health_manager
  │           └── elimination_handler
  │                 ├── respawn_manager
  │                 └── score_manager
  ├── hud_controller
  │     ├── scoreboard_widget
  │     ├── ability_bar_widget
  │     ├── health_bar_widget
  │     └── kill_feed_widget
  └── map_hazard_manager
```

### Verse File Organization

```
/ProjectName/
├── Core/
│   ├── game_state_manager.verse        # Master state machine
│   ├── team_manager.verse              # Team assignment & roster
│   ├── player_manager.verse            # Join/leave, player data
│   └── match_config.verse              # Tunable constants
├── Combat/
│   ├── health_manager.verse            # HP tracking, damage/heal application
│   ├── damage_pipeline.verse           # Damage flow, modifiers, events
│   ├── ability_system.verse            # Ability activation, targeting
│   ├── cooldown_tracker.verse          # Per-agent cooldown state
│   ├── status_effect_manager.verse     # Buff/debuff processing
│   └── elimination_handler.verse       # Death, assists, kill credit
├── Heroes/
│   ├── hero_registry.verse             # Hero definitions & stats
│   ├── hero_titan.verse                # Titan-specific ability logic
│   ├── hero_specter.verse              # Specter-specific ability logic
│   ├── hero_sage.verse                 # Sage-specific ability logic
│   └── hero_blaster.verse              # Blaster-specific ability logic
├── Match/
│   ├── hero_select_manager.verse       # Hero pick phase logic
│   ├── respawn_manager.verse           # Respawn timers, spawn selection
│   └── score_manager.verse             # Scoring, leaderboard
├── UI/
│   ├── hud_controller.verse            # HUD lifecycle
│   ├── scoreboard_widget.verse         # Score display
│   ├── ability_bar_widget.verse        # Ability icons & cooldowns
│   ├── health_bar_widget.verse         # Health display
│   └── kill_feed_widget.verse          # Kill notifications
├── Map/
│   ├── map_hazard_manager.verse        # Environmental hazards
│   └── spawn_point_selector.verse      # Weighted spawn logic
└── Utility/
    ├── math_helpers.verse              # Vector operations, angle checks
    └── timer_helpers.verse             # Countdown utilities
```

---

## 10. Custom Verse Devices

Building custom devices in Verse is a key requirement from the Disney job listing. The following devices are built from scratch (not wrappers around existing Fortnite devices):

### 10.1 — Ability Executor Device

**Purpose:** Central hub that listens for player input events, resolves the correct ability for the player's hero and slot, checks cooldowns, and delegates to the specific ability implementation.

**Key interfaces:**
- `RegisterHero(agent, hero_id)` — binds a hero to a player.
- `OnAbilityInput(agent, slot)` — entry point from input binding.
- Fires `OnAbilityActivated` and `OnAbilityCooldownStarted` events for other systems to consume.

### 10.2 — Projectile Simulator Device

**Purpose:** Simulates ability projectiles (Healing Orb, Concussion Rocket) since UEFN doesn't expose full projectile physics to Verse. Uses a tick-based position update along a direction vector, checking for collisions each step.

**Technique:**
- Each tick: `new_position = current_position + direction * speed * delta_time`
- Overlap sphere at `new_position` to check for agent hits.
- Despawn after max range or on hit.

### 10.3 — Area Effect Zone Device

**Purpose:** Creates persistent area effects (Sage's Sanctuary, Blaster's Gravity Snare). Periodically checks all agents within a radius and applies the appropriate effect.

**Technique:**
- Spawns a visual indicator (VFX prop).
- Each tick: iterate over all alive agents, compute distance to center, apply effect if within radius.
- Auto-despawns after duration.

### 10.4 — Knockback Applicator Device

**Purpose:** Applies physics-based knockback to agents. Computes direction and magnitude, then applies an impulse.

**Technique:**
- `knockback_dir = Normalize(target_position - source_position)`
- `impulse = knockback_dir * knockback_force`
- Apply via velocity manipulation over several ticks (ease-out curve for natural feel).

### 10.5 — Status Effect Tracker Device

**Purpose:** Manages the lifecycle of all status effects on all agents. Handles application, stacking, ticking, expiration, and cleansing.

---

## 11. Data Structures & Algorithms

Demonstrating computer science fundamentals as called out in the job description.

### Data Structures Used

| Structure | Usage | Why |
|---|---|---|
| **Hash Map** (`map(agent → data)`) | Player state, cooldowns, health, score | O(1) lookup per agent. Critical for real-time per-agent operations. |
| **Array / List** | Status effects per agent, kill feed entries, spawn points | Ordered collection; iterated frequently, appended/removed by index. |
| **Enum** | Game states, ability types, damage types, effect types | Type-safe state representation. Prevents invalid states. |
| **Struct** | Ability definitions, status effects, hero stats | Groups related data with named fields. Readable and maintainable. |
| **Queue (via array)** | Kill feed display (FIFO: oldest entries fade first) | Maintains display order; bounded size. |
| **Weighted Random Selection** | Spawn point selection (weight = distance from enemies) | Prevents spawn-camping by favoring distant spawn points. |

### Algorithms

| Algorithm | Usage |
|---|---|
| **Spatial distance check** | Determine which agents are within ability radius, aura range, etc. |
| **Dot product for cone checks** | Titan's Earthshatter: `dot(Normalize(targetPos - originPos), forwardDir) > cos(halfAngle)` |
| **Weighted random** | Spawn point selection. Weight each point by minimum distance to any enemy. |
| **Tick-based simulation** | Projectile movement, status effect expiration, cooldown updates. |
| **Damage modifier pipeline** | Chain of responsibility pattern: each modifier (passive, status, etc.) adjusts damage in sequence. |

---

## 12. Vector Math Applications

Demonstrating 3D vector math proficiency as required by the job listing.

### 12.1 Knockback Direction

```
knockback_direction := Normalize(target.GetPosition() - ability_source_position)
impulse := knockback_direction * knockback_force
```

### 12.2 Cone Ability Targeting (Earthshatter)

```
to_target := Normalize(target.GetPosition() - caster.GetPosition())
forward := caster.GetForwardVector()
angle := ArcCos(DotProduct(to_target, forward))
if angle < cone_half_angle:
    # Target is inside the cone
```

### 12.3 Projectile Simulation

```
projectile_position += projectile_direction * speed * delta_time
distance_traveled += speed * delta_time
if distance_traveled > max_range:
    Despawn()
```

### 12.4 Gravity Snare Pull

```
pull_direction := Normalize(snare_center - target.GetPosition())
pull_strength := Lerp(max_pull, 0.0, distance / snare_radius)
velocity := pull_direction * pull_strength
```

### 12.5 Spawn Point Selection (Distance Weighting)

```
for each spawn_point:
    min_enemy_distance := Min(Distance(spawn_point, enemy) for each enemy)
    weight := min_enemy_distance * min_enemy_distance  # squared to heavily favor far points
select spawn_point via weighted random using weights
```

### 12.6 Line-of-Sight Check (Specter Passive)

```
direction_to_enemy := Normalize(enemy.GetPosition() - self.GetPosition())
# Raycast from self toward enemy; if hit geometry before enemy distance, LOS is blocked
```

---

## 13. Polish & Juice

### Visual Effects

| Event | VFX |
|---|---|
| Ability activation | Colored particle burst matching hero theme |
| Damage taken | Screen-edge red vignette, camera shake |
| Elimination | Dramatic particle explosion on victim |
| Respawn | Beam-down effect at spawn point |
| Status effect applied | Aura/overlay on affected player (e.g., purple tint for Marked) |
| Low health | Pulsing red overlay, desaturation |
| Cooldown ready | Icon glow + subtle sound cue |

### Game Feel Targets

- **Responsiveness:** Ability activates within 1 frame of input (no network-induced delay for local feedback).
- **Impact:** Every hit communicates force through visual + audio + camera feedback.
- **Clarity:** No confusion about what happened or why. Every death has a clear cause in the kill feed.

---

## 14. Scope & Milestones

### Milestone 1 — Foundation (Week 1–2)

- [ ] UEFN project setup, map blockout (greybox)
- [ ] `game_state_manager` with full state machine
- [ ] `player_manager` and `team_manager`
- [ ] Basic health system (take damage, die, respawn)
- [ ] Basic HUD (health bar, team score, timer)

### Milestone 2 — Ability Framework (Week 3–4)

- [ ] Ability system architecture (input → cooldown check → execute)
- [ ] Cooldown tracker with HUD integration
- [ ] Implement Titan's full kit (Seismic Slam, Barrier Charge, Earthshatter)
- [ ] Damage pipeline with modifiers
- [ ] Knockback system with vector math

### Milestone 3 — Full Hero Roster (Week 5–6)

- [ ] Implement Specter's kit (teleport, invisibility, mark)
- [ ] Implement Sage's kit (projectile heal, purify, sanctuary zone)
- [ ] Implement Blaster's kit (rocket, gravity snare, orbital barrage)
- [ ] Status effect system (slow, stun, invisible, marked, invulnerable)
- [ ] Hero select phase

### Milestone 4 — Multiplayer & Scoring (Week 7)

- [ ] Score system with assists
- [ ] Kill feed
- [ ] Match timer with sudden-death tiebreaker
- [ ] Player join/leave handling with backfill logic
- [ ] Spawn point selection algorithm

### Milestone 5 — Polish & Publish (Week 8–9)

- [ ] Art pass on the arena (themed props, lighting, skybox)
- [ ] VFX for every ability and feedback event
- [ ] Audio pass (ability sounds, ambient, announcer)
- [ ] Balance tuning pass (HP, damage values, cooldowns)
- [ ] Playtesting, bug fixes, edge-case handling
- [ ] Publish to Fortnite as a discoverable Island

### Milestone 6 — Portfolio Assets (Week 10)

- [ ] Record gameplay video (1–3 min highlight reel)
- [ ] Write technical breakdown document
- [ ] Clean up and push Verse source code to GitHub
- [ ] Create portfolio page / README with visuals

---

## 15. Publishing & Portfolio Deliverables

### Published Island

- Title: **Multi-Ability Arena**
- Description highlighting hero combat, abilities, and team play.
- Island thumbnail and promotional screenshots.
- Target: **1,000+ plays** within the first month (promote via Discord communities, Reddit r/FortniteCreative, Twitter/X).

### GitHub Repository

Contents:
- All `.verse` source files, organized as described in the architecture section.
- `README.md` with project overview, screenshots, island code, and technical highlights.
- `TECHNICAL_BREAKDOWN.md` — deep-dive into systems architecture, data structures, and vector math usage.
- `GAME_OVERVIEW.md` — this document.

### Gameplay Video

- 1–3 minute edited video showing:
  - Hero selection.
  - Each hero's abilities in action.
  - A full match from start to finish (condensed).
  - Knockback physics near the hazard pit.
  - Team synergy moments (combo plays).

### Technical Writeup

A separate document covering:
- Architecture decisions and why they were made.
- How each custom Verse device works.
- Specific vector math applications with code samples.
- Data structure choices with performance justifications.
- Challenges encountered and how they were solved.

---

## Appendix A — Tunable Constants

All gameplay values live in `match_config.verse` so designers can adjust without touching system code.

| Constant | Default | Description |
|---|---|---|
| `ScoreLimit` | 20 | Eliminations needed to win |
| `MatchDuration` | 360 s | Total match time |
| `RespawnDelay` | 4 s | Time before respawn |
| `InvulnerabilityDuration` | 2 s | Post-respawn protection |
| `HeroSelectDuration` | 30 s | Hero pick phase length |
| `AssistWindow` | 10 s | Time window for assist credit |
| `MinPlayersToStart` | 4 | Required players to begin |

## Appendix B — Ability Quick Reference

| Hero | Primary (L1) | Secondary (L2) | Ultimate (R1+L1) |
|---|---|---|---|
| **Titan** | Seismic Slam (AoE + Slow) | Barrier Charge (Dash + Knockback) | Earthshatter (Cone + Stun) |
| **Specter** | Phantom Strike (Teleport + Burst) | Smoke Bomb (Invis) | Death Mark (Damage Amp) |
| **Sage** | Healing Orb (Projectile Heal/Damage) | Purify (Cleanse) | Sanctuary (Heal Zone + Block) |
| **Blaster** | Concussion Rocket (AoE + Knockback) | Gravity Snare (Pull) | Orbital Barrage (Multi-AoE) |

## Appendix C — Relevance to Disney Job Requirements

| Job Requirement | How This Project Demonstrates It |
|---|---|
| *"Directly writing Verse code"* | Entire project is Verse from the ground up — no blueprint-only shortcuts. |
| *"Custom devices using Verse"* | 5+ custom devices (Ability Executor, Projectile Simulator, Area Effect Zone, Knockback Applicator, Status Effect Tracker). |
| *"UEFN ecosystem"* | Built and published entirely in UEFN. Leverages Fortnite devices, props, and creative tools. |
| *"Fortnite devices and item capabilities"* | Uses native devices (HUD messages, player spawners, timers) alongside custom Verse devices. |
| *"Publishing successful Fortnite Islands"* | Published with a marketing push targeting 1,000+ plays. |
| *"Data structures"* | Hash maps, arrays, structs, enums, queues — each chosen with justification. |
| *"3D Vector Math"* | Knockback, cone checks, projectile sim, gravity pull, spawn weighting, LOS — all demonstrated. |
| *"Multiplayer logic"* | Full join/leave handling, team management, score sync, state machine. |
| *"Player experience / guest-first"* | Polished HUD, clear feedback, balanced gameplay, accessible design. |
| *"Find creative ways to overcome limitations"* | Custom projectile simulation, tick-based status effects, weighted spawn selection — all solve UEFN limitations creatively. |

---

*This document serves as both the development roadmap and portfolio reference for the Multi-Ability Arena project.*
