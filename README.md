# Multiplayer Ability Combat Arena

A 3v3 multiplayer hero combat experience built in UEFN with Verse.

## Project Status
- Current phase: Sprint 2 complete (implementation)
- Runtime status: single-client smoke test complete, multi-client verification pending

## Core Features
- Match state machine (`WaitingForPlayers -> HeroSelect -> Countdown -> InProgress -> MatchEnd`)
- Team assignment and player lifecycle management
- Hero select flow with timeout + default fallback
- Match population handling with pause/backfill scaffolding
- Runtime join/leave coordinator for session wiring

## Repository Structure
- `Core/` - core match and player systems
- `Match/` - hero select, population, runtime coordination
- `docs/` - design, planning, curriculum, and test reports
- `docs/tests/` - sprint test reports

## Key Docs
- `docs/GAME_OVERVIEW.md`
- `docs/SPRINT_PLAN.md`
- `docs/PRODUCT_BACKLOG.md`
- `docs/tests/SPRINT_1_TEST_REPORT.md`
- `docs/tests/SPRINT_2_TEST_REPORT.md`

## Local Setup
1. Open project in UEFN.
2. Compile Verse.
3. Launch Session.
4. Use `TestArena_Smoke` map for sprint smoke tests.

## Next Steps
- Sprint 3 implementation:
  - `health_manager`
  - `damage_pipeline`
  - `elimination_handler`
  - `respawn_manager`
- Complete multi-client runtime checks for Sprint 2.
