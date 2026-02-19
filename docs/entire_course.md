# Multi-Ability Arena - Entire Course (Lectures, Labs, Quizzes, Tests)

## Course Operating Rules
- Every week produces one implementation artifact and one assessment artifact.
- Labs are repository-grounded and tied to sprint outcomes.
- Quizzes check both design reasoning and low-level implementation details.
- Tests are cumulative; earlier systems can be re-tested in later weeks.

## Week 1 - Architecture and Match State Machine
### Lecture 1: Product Vision to Technical Architecture
- Convert experience pillars into technical requirements.
- Define system boundaries: Core, Combat, Heroes, Match, UI, Map, Utility.
- Understand ownership and dependencies.

### Lecture 2: State-Driven Match Orchestration in Verse
- Model states: WaitingForPlayers, HeroSelect, Countdown, InProgress, MatchEnd.
- Transition guards and invalid path rejection.
- State events and subsystem coordination.

### Lab 1: Foundation Scaffold
- Deliverable:
  - Create folder architecture and base core managers.
  - Implement `match_config`, `game_state_manager`, `player_manager`, `team_manager` shells.
- Verification:
  - Sprint 1 test report completed.

### Week 1 Quiz (10 questions)
1. Why should game state transitions be explicitly guarded?
2. Which manager owns the authoritative match phase?
3. What risk appears when state transitions are implicit?
4. Why centralize constants in `match_config`?
5. Which state should block ability usage by default?
6. Why is event-driven transition broadcasting preferred?
7. What is the minimum player gate used in this project?
8. Why should transition failures be logged?
9. Which system should own join/leave lifecycle?
10. What makes this architecture maintainable for future heroes?

## Week 2 - Team Systems and Hero Select
### Lecture 1: Multiplayer Join/Leave Lifecycle
- Join flow and late join routing.
- Leave cleanup and stale state risks.
- Backfill and minimum-player handling.

### Lecture 2: Hero Select as a Controlled Phase
- Countdown control and lock-in behavior.
- Default hero fallback for non-selection.
- Edge cases: disconnect during select, duplicate picks, timeout.

### Lab 2: Match Core Completion
- Deliverable:
  - Complete join/leave cleanup, team removal logic, hero select timer, default assignment.
  - Add low-player pause/backfill timer behavior.
- Verification:
  - Sprint 2 test report completed and exit criteria met.

### Week 2 Quiz (10 questions)
1. How should late joiners be assigned for fairness?
2. Why can stale player maps break later systems?
3. What happens if no hero is selected before timer ends?
4. Why is backfill logic important in live multiplayer?
5. Which system should trigger hero select finalization?
6. Why should team assignment avoid randomness when sizes differ?
7. What data needs cleanup on player leave?
8. What phase should resume after hero select?
9. Why should hero select disable combat inputs?
10. What failure mode appears without minimum-player enforcement?

## Week 3 - Combat Foundation
### Lecture 1: Health, Damage Types, and Modifier Pipelines
### Lecture 2: Elimination, Assist Attribution, and Respawn Safety
### Lab 3: Implement combat core managers and assist window logic
### Week 3 Quiz (10 questions)
- Focus: damage pipeline order, modifier chaining, assist windows, respawn invulnerability.

### Phase 1 Test (end of Week 3)
- Format: 20-question written + implementation check.
- Must pass:
  - Match flow works end to end.
  - Core combat loop is stable.
  - Join/leave does not corrupt team state.

## Week 4 - Ability Framework
### Lecture 1: Ability Definitions and Data Modeling
### Lecture 2: Cooldown Tracking and HUD Integration
### Lab 4: Implement ability executor flow and cooldown map
### Week 4 Quiz (10 questions)
- Focus: per-agent cooldown maps, slot routing, event contracts.

## Week 5 - Titan and Specter
### Lecture 1: Tank and Flanker kit engineering
### Lecture 2: Cone checks, teleport targeting, invisibility rules
### Lab 5: Implement Titan and Specter complete kits
### Week 5 Quiz (10 questions)
- Focus: cone math, collision checks, mark amplification behavior.

## Week 6 - Sage and Blaster + Status Effects
### Lecture 1: Support and ranged role implementation
### Lecture 2: Status lifecycle and stacking policy
### Lab 6: Implement Sage and Blaster, complete status tracker
### Week 6 Quiz (10 questions)
- Focus: cleanse rules, area effects, pull behavior, per-target stacks.

### Midterm Practical (end of Week 6)
- Build task: full 4-hero playable match.
- Oral defense: explain one custom device and one vector math operation.
- Required evidence: updated test report and short demo capture.

## Week 7 - Match Scoring and Timer Systems
### Lecture 1: Team score computation and assist edge cases
### Lecture 2: Sudden death logic and deterministic match ending
### Lab 7: Implement score manager, assist windows, tiebreak behavior
### Week 7 Quiz (10 questions)
- Focus: scoring correctness and tie resolution.

## Week 8 - HUD and Player Feedback
### Lecture 1: Combat readability model
### Lecture 2: HUD architecture and update cadence
### Lab 8: Implement kill feed, ability bar updates, status icon display
### Week 8 Quiz (10 questions)
- Focus: signal clarity, UI update timing, feedback conflict resolution.

## Week 9 - Arena Fairness and Spawn Safety
### Lecture 1: Symmetry and lane control in ability arenas
### Lecture 2: Weighted spawn selection by enemy distance
### Lab 9: Implement hazard manager and spawn selector weighting
### Week 9 Quiz (10 questions)
- Focus: fairness, spawn-camping prevention, map risk-reward.

### Phase 3 Integration Test (end of Week 9)
- Format: 15-question system integration quiz + runtime verification matrix.
- Must pass:
  - No major gameplay loop blockers.
  - Spawn fairness and hazards validated.
  - HUD reflects critical combat events.

## Week 10 - VFX, SFX, and Game Feel
### Lecture 1: Responsiveness and impact design
### Lecture 2: Priority tuning for readability under chaos
### Lab 10: Implement event-aligned VFX/SFX and low-health signaling
### Week 10 Quiz (8 questions)
- Focus: feedback hierarchy and player perception.

## Week 11 - Balance and Regression Strategy
### Lecture 1: Role identity and balancing loops
### Lecture 2: Regression checklists and defect triage methods
### Lab 11: Run structured playtests and produce tuning proposals
### Week 11 Quiz (8 questions)
- Focus: balancing decisions, evidence-based tuning.

## Week 12 - Publishing and Professional Defense
### Lecture 1: Release checklist and island metadata strategy
### Lecture 2: Portfolio narrative and interview response structure
### Lab 12: Build final portfolio package and technical walkthrough
### Week 12 Quiz (8 questions)
- Focus: publishing workflow and professional communication.

### Final Exam and Capstone Defense
- Written: 30-question comprehensive exam.
- Practical: live walkthrough of architecture, one hero kit, one custom device.
- Deliverables:
  - Updated backlog and sprint reports
  - Technical breakdown document
  - Gameplay reel outline and speaking script

## Question Bank Samples
### Sample MCQ 1
Which expression is used for cone checks?
- A. Dot(toTarget, forward) > cos(halfAngle)
- B. Cross(toTarget, forward) < halfAngle
- C. Distance(target, forward) < angle
- D. Normalize(forward) == target
- Answer: A

### Sample MCQ 2
What data structure best fits per-player cooldown timestamps?
- A. Queue
- B. Hash map keyed by agent and slot
- C. Stack
- D. Linked list
- Answer: B

### Sample Short Answer Prompt
Explain why weighted spawn selection should bias toward greater enemy distance and one downside if over-weighted.

## Lab Report Template
- Objective
- Environment
- Steps executed
- Verification results
- Defects found
- Fixes applied
- Remaining risks

## Instructor Review Checklist
- Architecture coherence
- Correctness of gameplay rules
- Reliability under multiplayer events
- Readability of combat feedback
- Professional quality of explanation
