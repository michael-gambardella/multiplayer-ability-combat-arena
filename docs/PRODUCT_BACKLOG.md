# Multi-Ability Arena - Product Backlog

## Priority Model
- P0: Required for playable and publishable core loop
- P1: Required for quality and differentiation
- P2: Polish and growth improvements

## Epic List
| Epic ID | Epic Name | Priority | Description |
|---|---|---|---|
| E1 | Match State & Core Architecture | P0 | Authoritative game flow and orchestration systems |
| E2 | Player, Team, and Hero Select | P0 | Join/leave, team balancing, and selection flow |
| E3 | Combat Foundation | P0 | Health, damage, elimination, respawn |
| E4 | Ability Framework | P0 | Ability definitions, routing, cooldowns |
| E5 | Titan Hero Kit | P0 | Tank kit with knockback and cone stun |
| E6 | Status Effect System | P0 | Status application, stacking, expiration, cleansing |
| E7 | Specter Hero Kit | P0 | Flanker kit with teleport/invisibility/mark |
| E8 | Sage Hero Kit | P0 | Support kit with healing and utility zone |
| E9 | Blaster Hero Kit | P0 | Ranged kit with AoE and pull mechanics |
| E10 | Custom Verse Devices | P1 | Ability executor, projectile sim, area zone, knockback, tracker |
| E11 | Match Scoring & UI | P1 | Scoreboard, timer, kill feed, ability HUD |
| E12 | Arena, Hazards, and Spawn Logic | P1 | Symmetric arena functionality and anti-spawn-camp logic |
| E13 | Polish, QA, and Balance | P1 | Feedback readability, balancing, bug fixing |
| E14 | Release and Portfolio | P2 | Publishing assets and professional documentation |

## User Stories

### E1 - Match State & Core Architecture
- US-001 (P0): As a player, I need the match to move through clear phases so gameplay is predictable.
  - Acceptance Criteria:
    - State machine supports all planned states.
    - Invalid transitions are blocked.
- US-002 (P0): As a system developer, I need state events so dependent systems can synchronize.
  - Acceptance Criteria:
    - OnStateChanged event exposes previous/current state.

### E2 - Player, Team, and Hero Select
- US-003 (P0): As a player, I want automatic team assignment for fair matches.
  - Acceptance Criteria:
    - Late joins are assigned to the smaller team.
- US-004 (P0): As a player, I want a hero select phase with fallback behavior.
  - Acceptance Criteria:
    - 30-second selection timer enforced.
    - Default hero assigned if no pick.

### E3 - Combat Foundation
- US-005 (P0): As a player, I need reliable damage/healing calculations.
  - Acceptance Criteria:
    - Damage pipeline applies invulnerability and modifiers.
- US-006 (P0): As a player, I need fast respawns to keep action continuous.
  - Acceptance Criteria:
    - 4-second respawn timer and 2-second spawn invulnerability.

### E4 - Ability Framework
- US-007 (P0): As a player, ability activations should execute only when available.
  - Acceptance Criteria:
    - Cooldown gate per ability slot per player.
- US-008 (P0): As a player, I need readable cooldown feedback on HUD.
  - Acceptance Criteria:
    - Cooldown value and ready state update in UI.

### E5 - Titan Hero Kit
- US-009 (P0): As a Titan player, I want a high-impact frontline kit.
  - Acceptance Criteria:
    - Seismic Slam applies AoE + slow.
    - Barrier Charge applies movement + collision damage + knockback.
    - Earthshatter applies cone damage + stun.

### E6 - Status Effect System
- US-010 (P0): As a player, statuses should be consistent and predictable.
  - Acceptance Criteria:
    - Duration expiration per tick.
    - Same-source refresh rules and cross-source strongest-magnitude rule.

### E7 - Specter Hero Kit
- US-011 (P0): As a Specter player, I want flank tools and burst windows.
  - Acceptance Criteria:
    - Teleport strike and smoke invisibility function correctly.
    - Death Mark amplifies team damage for duration.

### E8 - Sage Hero Kit
- US-012 (P0): As a Sage player, I want clear support impact.
  - Acceptance Criteria:
    - Healing Orb heals ally or damages enemy on first hit.
    - Purify removes negative effects only.
    - Sanctuary heals allies and blocks enemy projectiles.

### E9 - Blaster Hero Kit
- US-013 (P0): As a Blaster player, I want zone control and area damage.
  - Acceptance Criteria:
    - Concussion Rocket AoE + knockback.
    - Gravity Snare pull-over-time in radius.
    - Orbital Barrage executes timed multi-explosions.

### E10 - Custom Verse Devices
- US-014 (P1): As a developer, I need reusable custom devices to overcome UEFN limitations.
  - Acceptance Criteria:
    - Ability Executor routes input and emits activation events.
    - Projectile Simulator supports speed, range, and collision checks.
    - Area Zone applies periodic effects and expires cleanly.
    - Knockback Applicator supports eased impulse.
    - Status Tracker manages lifecycle events.

### E11 - Match Scoring & UI
- US-015 (P1): As a player, I need transparent match outcome rules.
  - Acceptance Criteria:
    - +1 elimination, +0.5 assist with 10-second assist window.
    - Timer and sudden death work in ties.
- US-016 (P1): As a player, I need readable combat feedback.
  - Acceptance Criteria:
    - Kill feed, hit markers, damage numbers, status icons, respawn timer all function.

### E12 - Arena, Hazards, and Spawn Logic
- US-017 (P1): As a player, I need fair spawn behavior after elimination.
  - Acceptance Criteria:
    - Weighted spawn selection favors points farthest from enemies.
- US-018 (P1): As a player, I need map hazards to reward tactical ability usage.
  - Acceptance Criteria:
    - Hazard interactions are intentional and clearly telegraphed.

### E13 - Polish, QA, and Balance
- US-019 (P1): As a player, combat should feel responsive and readable.
  - Acceptance Criteria:
    - Ability feedback near-immediate.
    - Distinct VFX/SFX per key event.
- US-020 (P1): As a team, we need confidence before publish.
  - Acceptance Criteria:
    - Regression test checklist completed.
    - Balance values tuned and documented.

### E14 - Release and Portfolio
- US-021 (P2): As a creator, I need professional release assets.
  - Acceptance Criteria:
    - Island metadata, promo visuals, and description finalized.
- US-022 (P2): As a candidate, I need a clear technical narrative.
  - Acceptance Criteria:
    - Technical breakdown and portfolio README complete.

## Backlog Status Snapshot (2026-02-19)
- In Progress: US-005, US-006 (implementation complete, runtime validation pending)
- Ready Next: US-007, US-008, US-009
- Blocked: None

## Story Template for Execution
Use this template for each active story:
- Story ID:
- Sprint:
- Owner:
- Implementation Notes:
- Test Cases:
- Risks:
- Status: Not Started | In Progress | In Review | Done

