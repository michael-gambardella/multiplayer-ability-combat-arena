# Multi-Ability Arena - Sprint Plan

## Sprint Cadence
- Sprint length: 1 week
- Total planned sprints: 10
- Development style: Build -> Test -> Balance -> Document
- Definition of Done (global): Feature implemented, tested in multiplayer conditions, documented in backlog and sprint notes.

## Sprint Timeline
| Sprint | Focus | Primary Outcome |
|---|---|---|
| Sprint 1 | Foundation | Project architecture, state machine, base managers |
| Sprint 2 | Match Core | Team assignment, join/leave handling, hero select flow |
| Sprint 3 | Combat Core | Health, damage pipeline, elimination, respawn |
| Sprint 4 | Ability Framework + Titan | Ability system, cooldowns, Titan full kit |
| Sprint 5 | Status Effects + Specter | Status effect tracker and Specter full kit |
| Sprint 6 | Sage + Devices | Sage full kit, projectile and area effect systems |
| Sprint 7 | Blaster + Knockback | Blaster full kit and knockback finalization |
| Sprint 8 | Scoring + HUD | Score/assist systems, kill feed, timer, UI completeness |
| Sprint 9 | Arena Polish + QA | Map hazards, VFX/SFX pass, tuning, test regression |
| Sprint 10 | Release + Portfolio | Publish-ready package and professional documentation |

## Sprint-by-Sprint Execution

### Sprint 1 - Foundation
- Goals:
  - Create Verse module structure from architecture.
  - Implement `game_state_manager` state graph.
  - Implement `match_config`, `player_manager`, and `team_manager` shells.
- Exit Criteria:
  - Valid transition flow: `WaitingForPlayers -> HeroSelect -> Countdown -> InProgress -> MatchEnd`.
  - State transitions fire events that other systems can subscribe to.
  - Minimum players gate is enforced.

### Sprint 2 - Match Core
- Goals:
  - Auto-balance teams Alpha/Bravo.
  - Implement join/leave lifecycle and cleanup.
  - Build hero select timer and default fallback selection.
- Exit Criteria:
  - Late joiners are assigned correctly.
  - Match pause/backfill behavior works when team size drops below minimum.

### Sprint 3 - Combat Core
- Goals:
  - Implement `health_manager`, `damage_pipeline`, `elimination_handler`, and `respawn_manager`.
  - Add invulnerability checks and post-spawn invulnerability.
- Exit Criteria:
  - Damage, healing, elimination, and respawn loop runs consistently.
  - Overkill protection and event broadcasts are validated.

### Sprint 4 - Ability Framework + Titan
- Goals:
  - Build ability activation flow and cooldown tracker.
  - Implement Titan: Seismic Slam, Barrier Charge, Earthshatter, Fortified passive.
- Exit Criteria:
  - Cooldowns tracked per-agent/per-slot.
  - Titan kit is fully playable with status and knockback integration.

### Sprint 5 - Status Effects + Specter
- Goals:
  - Build status effect manager with stacking and expiration rules.
  - Implement Specter full kit.
- Exit Criteria:
  - Invisibility, mark, slow, and stun states behave correctly.
  - Purge rules and source-based stacking are deterministic.

### Sprint 6 - Sage + Devices
- Goals:
  - Implement Sage full kit.
  - Build custom `Projectile Simulator` and `Area Effect Zone` devices.
- Exit Criteria:
  - Healing Orb friend-or-foe behavior works.
  - Sanctuary heals allies and blocks projectiles for the intended duration.

### Sprint 7 - Blaster + Knockback
- Goals:
  - Implement Blaster full kit.
  - Finalize `Knockback Applicator` behavior with easing.
- Exit Criteria:
  - Gravity Snare pull logic and Orbital Barrage area sequencing are stable.
  - Knockback feels readable and fair in hazard zones.

### Sprint 8 - Scoring + HUD
- Goals:
  - Implement score and assist windows.
  - Finalize scoreboard, timer, ability bar, kill feed, status icons.
- Exit Criteria:
  - Sudden death tie-breaker works.
  - HUD updates correctly under stress conditions.

### Sprint 9 - Arena Polish + QA
- Goals:
  - Complete art, VFX, SFX, and readability pass.
  - Run regression tests and balance tuning.
- Exit Criteria:
  - Full feature regression passed.
  - Core hero balance table updated from playtest data.

### Sprint 10 - Release + Portfolio
- Goals:
  - Publish island package and promotional assets.
  - Finalize technical breakdown and demonstration material.
- Exit Criteria:
  - Publish checklist complete.
  - Portfolio package includes README, technical breakdown, video plan, and screenshots.

## Sprint Execution Log
- Current Status Date: 2026-02-19
- Active Sprint: Sprint 3 (In Progress)
- Today Execution Tasks:
  - [x] Implement `health_manager` with HP registration, damage, healing, and overkill protection.
  - [x] Implement `damage_pipeline` with invulnerability gating and damage modifier support.
  - [x] Implement `elimination_handler` to detect lethal outcomes and handoff to respawn.
  - [x] Implement `respawn_manager` with respawn delay and post-spawn invulnerability.
  - [ ] Complete live UEFN runtime validation for full damage/elimination/respawn loop.
- Blockers:
  - Multi-client runtime coverage still limited by available test accounts.

## Weekly Rituals
- Sprint Planning: Monday
- Mid-sprint Review: Wednesday
- Playtest + Retrospective: Friday
- Backlog Grooming: End of sprint



