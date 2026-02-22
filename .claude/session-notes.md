# Session Notes
<!-- Written by /wrapup. Read by /catchup at the start of the next session. -->
<!-- Overwritten each session — history preserved in git log of this file. -->

- **Date:** 2026-02-21
- **Branch:** main

## What Was Done
- v2.23.0: Added RPCS3/PS3 platform support — ninth emulator platform in the database
- 24 new PS3 game entries: GT5 (verified), GT6 (verified), GT5 Prologue, DiRT 1-3, DiRT Showdown, Race Driver: GRID, GRID 2, F1 2010/2011/2013, NFS The Run, WRC 1-3 (Milestone), Midnight Club LA, MotorStorm Apocalypse, Initial D Extreme Stage, Sega Rally Revo, Ferrari Challenge, Blur, Formula One Championship Edition
- RPCS3 platform added to 19 existing entries: NFS Carbon/HP/MW/Rivals/Shift/Shift2/Undercover/ProStreet, F1 2012/2014, GRID Autosport, WRC 4-5, Burnout Paradise, Split/Second, RR Unbounded, Sonic Racing 1-2, Test Drive Ferrari
- Schema updated with platformRpcs3 definition (serial field, same pattern as PCSX2)
- Validator updated: rpcs3 counted in stats, recognized as PC-playable platform in Check 10
- All docs updated: CHANGELOG, README, CLAUDE.md

## Decisions Made
- PS3 serials use NTSC-U (BLUS/BCUS) when available, PAL (BLES/BCES) for PAL-only releases (WRC 1-3, Formula One CE)
- RPCS3 wheel emulation is beta (emulated G27 via USB) — database tracks the PS3 game's native wheel support, not RPCS3 compat status
- MotorStorm 1-2 excluded (no wheel support at all); only Apocalypse included (partial, patched in)
- Initial D Extreme Stage included despite broken RPCS3 wheel input — works on real hardware, RPCS3 bug will be fixed
- DiRT Rally NOT added (PS4/PC only, not PS3)
- F1 2015 NOT added (PS4/PC only, not PS3)

## Open Items
- [ ] 14 medium-confidence entries remain (13 from before + motorstorm_apocalypse + blur)
- [ ] Shox (PCSX2) still needs hands-on wheel verification
- [ ] Some RPCS3 serials may need verification against GameTDB/RPCS3 wiki (used research agent data)
- [ ] Commit and push v2.23.0, create GitHub release

## Next Steps
1. Commit and push v2.23.0, create GitHub release with dist/ artifacts
2. Run Steam discovery pass (`Get-SteamRacingGames.ps1`) for newly released racing games
3. Consider Cxbx-Reloaded/Chihiro platform (OutRun 2 SP)
4. Consider adding more PS3 games: NASCAR 08-09, Superstars V8, TDU2, Juiced 2
5. Harley-Davidson research — operator manual on Manualzz may need Playwright

## Context for Next Session
v2.23.0 ready to commit. Database at 709 games, RPCS3=43 (24 new + 19 linked), PCSX2=61. All validation passes, exports generated. The RPCS3 G27 emulation is still beta — some games like Initial D Extreme Stage and F1 2010 have known issues with the virtual G27. GT5 is the best-tested RPCS3 wheel game. Milestone WRC 1-3 are PAL-only (BLES serials). Next major expansion opportunities: Steam discovery pass, Cxbx-Reloaded platform, or additional PS3 niche titles.
