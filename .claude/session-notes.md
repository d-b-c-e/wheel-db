# Session Notes
<!-- Written by /wrapup. Read by /catchup at the start of the next session. -->
<!-- Overwritten each session — history preserved in git log of this file. -->

- **Date:** 2026-02-21
- **Branch:** main

## What Was Done
- v2.23.0: Added RPCS3/PS3 platform support — ninth emulator platform in the database
- 24 new PS3 entries: GT5 (verified), GT6 (verified), GT5 Prologue, DiRT 1-3 + Showdown, Race Driver: GRID, GRID 2, F1 2010/2011/2013, NFS The Run, WRC 1-3 (Milestone), Midnight Club LA, MotorStorm Apocalypse, Initial D Extreme Stage, Sega Rally Revo, Ferrari Challenge, Blur, Formula One Championship Edition
- RPCS3 platform added to 19 existing entries: NFS Carbon/HP/MW/Rivals/Shift/Shift2/Undercover/ProStreet, F1 2012/2014, GRID Autosport, WRC 4-5, Burnout Paradise, Split/Second, RR Unbounded, Sonic Racing 1-2, Test Drive Ferrari
- Schema: `platformRpcs3` definition with PS3 disc serial identifiers (scripts/archive/Add-Rpcs3Platform.ps1)
- Validator: rpcs3 stats tracking, recognized as PC-playable platform in Check 10
- Docs updated: CHANGELOG, README, CLAUDE.md, INTEGRATION.md (added rpcs3 to platform tables and code examples)

## Decisions Made
- PS3 serials use NTSC-U (BLUS/BCUS) when available, PAL (BLES/BCES) for PAL-only releases: WRC 1-3, Formula One CE
- Database tracks PS3 game's native wheel support, not RPCS3 emulation compat status (emulator bugs are transient)
- MotorStorm 1-2 excluded (no wheel support); only Apocalypse included (partial, patched in)
- Initial D Extreme Stage included despite broken RPCS3 virtual G27 input — works on real hardware
- DiRT Rally and F1 2015 NOT added (PS4/PC only, not PS3)

## Open Items
- [ ] 14 medium-confidence entries remain (13 prior + motorstorm_apocalypse)
- [ ] Shox (PCSX2) still needs hands-on wheel verification
- [ ] Some RPCS3 serials may need verification against GameTDB/RPCS3 wiki
- [ ] Harley-Davidson operator manual on Manualzz returned 403

## Next Steps
1. Run Steam discovery pass (`Get-SteamRacingGames.ps1`) for newly released racing games
2. Consider Cxbx-Reloaded/Chihiro platform (OutRun 2 SP)
3. Consider adding more PS3 games: NASCAR 08-09, Superstars V8, TDU2, Juiced 2
4. Harley-Davidson research via Playwright for medium→high upgrade

## Context for Next Session
v2.23.0 committed and pushed. Database at 709 games, RPCS3=43, PCSX2=61. RPCS3 G27 emulation is beta — GT5 best-tested, some games (Initial D Extreme Stage, F1 2010) have known virtual G27 issues. Milestone WRC 1-3 are PAL-only. PS3 research sources largely exhausted (Logitech compat list, GTPlanet, RPCS3 wiki). Next expansion: Steam discovery pass or Cxbx-Reloaded.
