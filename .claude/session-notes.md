# Session Notes
<!-- Written by /wrapup. Read by /catchup at the start of the next session. -->
<!-- Overwritten each session — history preserved in git log of this file. -->

- **Date:** 2026-02-22
- **Branch:** main

## What Was Done
- v2.25.0: Upgraded 12 medium-confidence entries to high via targeted research
- Crazy Ride: SuzoHapp 270° confirmed via Cruis'n Blast platform parts catalog
- Nash Racing: ws unknown→none (dead G-27 thread, no wheel evidence)
- Project Drift: ws=none confirmed (unanswered wheel support thread)
- Drifto: Infinite Touge: ws none→partial (Steam review confirms wheel works with menu bugs)
- Rally Evolution 2025: ws=none confirmed (arcade MMO design)
- Rally Fusion: Race of Champions: ws unknown→native (GTPlanet Driving Force compatibility list)
- Lotus Challenge: ws unknown→native (3 independent PS2 wheel compatibility lists)
- Knight Rider: The Game: ws unknown→native (4 sources including Amazon)
- Formula One 2003 (Studio Liverpool): ffb unknown→native (F1 2001 series lineage)
- Formula One 04 (Studio Liverpool): ffb unknown→native (Wikipedia + PCSX2 Wiki)
- MotorStorm: Apocalypse: ffb unknown→native (PlayStation Blog Monster Update announcement)
- Blur: ws partial→none (no native wheel support, intentionally gamepad-only)
- 3 entries enriched but staying medium: Harley-Davidson KotR, Crazy Speed, Frenzy Express
- Docs updated: CHANGELOG, README, CLAUDE.md, session-notes — all stats bumped to v2.25.0

## Decisions Made
- Blur downgraded from partial→none: research confirmed no platform (PS3, 360, PC) had native wheel support; designed as gamepad-only arcade racer
- Drifto upgraded from none→partial: Steam review provided first-hand evidence of working wheel input despite menu navigation bugs
- Formula One 2003/04 FFB upgraded via series lineage: Studio Liverpool F1 2001 confirmed native FFB, 2003/04 are direct successors on same engine
- MotorStorm Apocalypse FFB confirmed via official PlayStation Blog post announcing Monster Update with wheel/FFB support
- Corrected v2.24.0 medium count discrepancy: was listed as 14 but actual count was 15; v2.25.0 now at 3 medium

## Open Items
- [ ] 3 medium-confidence entries remain: Harley-Davidson KotR, Crazy Speed, Frenzy Express
- [ ] Harley-Davidson KotR needs Sega Lindbergh Red EX cabinet documentation for medium→high
- [ ] Shox (PCSX2) still needs hands-on wheel verification
- [ ] Some RPCS3 serials may need verification against GameTDB/RPCS3 wiki
- [ ] Endurance Motorsport Series — add when released (expected early 2026)

## Next Steps
1. Research Harley-Davidson KotR for medium→high (Sega Lindbergh cabinet docs or BYOAC owner reports)
2. Consider Cxbx-Reloaded/Chihiro platform (OutRun 2 SP)
3. Consider adding more PS3 games: NASCAR 08-09, Superstars V8, TDU2, Juiced 2
4. Monitor Endurance Motorsport Series release for addition

## Context for Next Session
v2.25.0 committed. Database at 712 games (unchanged count). Major quality milestone: only 3 medium-confidence entries remain in entire database (Harley-Davidson KotR, Crazy Speed, Frenzy Express). All three are obscure arcade games needing cabinet-specific documentation. Zero low-confidence entries. PC wheel support stats shifted slightly due to corrections (native=183, partial=94, none=84). PC FFB stats: native=138 (+3 from Formula One 2003/04 and MotorStorm), partial=74, none=140.
