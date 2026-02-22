# Session Notes
<!-- Written by /wrapup. Read by /catchup at the start of the next session. -->
<!-- Overwritten each session — history preserved in git log of this file. -->

- **Date:** 2026-02-21
- **Branch:** main

## What Was Done
- v2.21.0: Added 5 PCSX2 entries (Burnout 1-2, WRC II Extreme, Formula One 05-06), eliminated all single-source entries (11→0), upgraded interstate_drifter_1999 medium→high, fixed frenzy_express rotation_type to potentiometer, changed drifto/project_drift wheel_support to none
- v2.22.0: Added 6 PCSX2 entries (WRC 3-4 PS2, WRC Rally Evolved, Initial D Special Stage, F355 Challenge PS2, F1 Career Challenge), fixed Burnout 1-2 rotation 270°→200° and wheel_support native→partial
- Enriched all remaining single-source entries: 7 MAME/TP high entries + 4 PCSX2/Steam entries = 0 single-source remaining
- Research agents completed for arcade mediums (harley_davidson, frenzy_express) and Steam mediums (nash_racing, project_drift, drifto_infinite_touge, rally_evolution_2025, interstate_drifter_1999)

## Decisions Made
- Burnout 1-2 set to 200° not 270°: pre-DFP era wheels maxed at 200°, matches Burnout 3/Revenge already in DB
- Burnout 1-2 wheel_support set to partial not native: basic support, not full integration like GT/NFS
- WRC Rally Evolved set to 540°: later Evolution Studios title supports DFGT, 540° recommended for rally
- Initial D Special Stage set to 540°: matches arcade cabinet specs (ID4-ID8 all 540° per TeknoParrot metadata)
- Excluded Twisted Metal Black and Ridge Racer V from PCSX2: borderline/limited wheel support, not worth adding
- 13 medium-confidence entries stay medium: no additional sources found to upgrade them

## Open Items
- [ ] 13 medium-confidence entries remain (harley_davidson, frenzy_express, nash_racing, project_drift, drifto_infinite_touge, rally_evolution_2025, + 7 others)
- [ ] Shox (SLUS-20533) still needs hands-on wheel verification

## Next Steps
1. Add RPCS3/PS3 platform (GT5/6, NFS titles — large untapped platform)
2. Run Steam discovery pass (`Get-SteamRacingGames.ps1`) for newly released racing games
3. Consider Cxbx-Reloaded/Chihiro platform (OutRun 2)
4. Generate dist/ artifacts and create GitHub release for v2.22.0

## Context for Next Session
v2.22.0 committed and pushed. Database at 685 games, PCSX2=61, zero single-source entries, 13 mediums remaining. The Evolution Studios WRC series on PS2 is fully covered (WRC 1-4 + II Extreme + Rally Evolved). GTPlanet DF compatibility list and PCSX2 Wiki are exhausted for PS2 games. Next major expansion opportunity is PS3/RPCS3 or fresh Steam discovery. The Harley-Davidson operator manual on Manualzz returned 403 — may need Playwright to access.
