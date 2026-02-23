# Verse Compile-Safety Gate

Use this gate before marking any sprint report complete.

## Scope
- Run against: `MultiAbilityArena/Content`
- File filter: `*.verse`

## Required Checks

### 1) Invalid optional operator usage (`...?`)
- Command:
```powershell
rg -n "\?" MultiAbilityArena/Content -g "*.verse"
```
- Pass condition: no invalid optional syntax in changed files.

### 2) Function invocations inside `if` conditions
- Command:
```powershell
rg -n "if\s*\([^\)]*\w+\s*\(" MultiAbilityArena/Content -g "*.verse"
```
- Pass condition: no inline function calls in `if` conditions; use local vars first.

### 3) Unsupported string interpolation for complex types
- Command:
```powershell
rg -n "\$\{" MultiAbilityArena/Content -g "*.verse"
```
- Pass condition: no unsupported interpolation patterns.

### 4) Override signatures exist only where valid
- Command:
```powershell
rg -n "override" MultiAbilityArena/Content -g "*.verse"
```
- Pass condition: each override matches parent signature exactly.

### 5) Runtime harness module references
- File:
  - `MultiAbilityArena/Content/Match/runtime_harness_device.verse`
- Pass condition: references normalized to `Core.*` / `Match.*`.

### 6) Public cross-module visibility
- Command:
```powershell
rg -n "<public>" MultiAbilityArena/Content -g "*.verse"
```
- Pass condition: symbols required across modules are public and resolve correctly.

### 7) Source root placement
- Command:
```powershell
rg --files -g "*.verse"
```
- Pass condition: all new Verse files are under `MultiAbilityArena/Content/...`.

## Compile Verification
- Final step in UEFN: run Verse build/compile and record output in sprint report.
- Pass condition: no compile errors for sprint scope files.
