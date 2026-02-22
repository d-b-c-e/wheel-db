# Session Notes
<!-- Written by /wrapup. Read by /catchup at the start of the next session. -->
<!-- Overwritten each session — history preserved in git log of this file. -->

- **Date:** 2026-02-22
- **Branch:** main

## What Was Done
- v2.24.0: Ran Steam discovery pass via `Get-SteamRacingGames.ps1 -Force -SkipEnrich`
- Cross-referenced 500 SteamSpy results against 276 existing Steam entries — confirmed excellent coverage
- Added 3 new Steam entries: On The Road - Truck Simulator (285380, partial wheel/FFB, 900°), RIDE 6 (2815070, no wheel), NASCAR Arcade Rush (2192060, no wheel)
- Migration script: `scripts/archive/Add-SteamDiscovery-2024.ps1`
- Docs updated: README, CLAUDE.md, CHANGELOG, INTEGRATION.md — all stats bumped to v2.24.0

## Decisions Made
- On The Road rated partial/partial: FFB implementation inconsistent across wheel models, developer provides dedicated FFB Test App as workaround
- RIDE 6 added despite no wheel support: series completeness (RIDE 3-5 already in DB with `wheel_support: "none"`)
- NASCAR Arcade Rush added despite no wheel support: legitimate racing game in DB scope, follows pattern of other arcade racers
- Endurance Motorsport Series (KT Racing, appid 2228250) NOT added: unreleased, wait for actual release

## Open Items
- [ ] 14 medium-confidence entries remain
- [ ] Shox (PCSX2) still needs hands-on wheel verification
- [ ] Some RPCS3 serials may need verification against GameTDB/RPCS3 wiki
- [ ] Endurance Motorsport Series — add when released (expected early 2026)

## Next Steps
1. Consider Cxbx-Reloaded/Chihiro platform (OutRun 2 SP)
2. Consider adding more PS3 games: NASCAR 08-09, Superstars V8, TDU2, Juiced 2
3. Harley-Davidson research via Playwright for medium→high upgrade
4. Monitor Endurance Motorsport Series release for addition

## Context for Next Session
v2.24.0 committed and pushed. Database at 712 games, Steam=279. Steam discovery pass confirmed near-complete coverage — most "missing" SteamSpy results are false positives (non-racing games tagged Racing/Driving). Only 3 genuine gaps found and added. Next major expansion opportunity is Cxbx-Reloaded platform or additional PS3 games.
