# Session Notes
<!-- Written by /wrapup. Read by /catchup at the start of the next session. -->
<!-- Overwritten each session — history preserved in git log of this file. -->

- **Date:** 2026-02-21
- **Branch:** main

## What Was Done
- Added 15 new PCSX2 entries (v2.20.0): NASCAR Thunder 2003/2004, NASCAR 2005, Ford Mustang, V-Rally 3, WRC PS2, Rally Fusion, CMR 04/2005, Richard Burns Rally (900°), Lotus Challenge, Knight Rider, F1 2003/04 (Studio Liverpool), Sega Rally 2006
- Enriched 36 single-source entries with second sources (manufacturer inference for 26 controls.xml MAME entries + 5 MAME manual + 5 Steam research)
- Upgraded Crazy Ride and Crazy Speed from medium→high confidence (SuzoHapp Active 270 hardware evidence)
- Fixed validator: Check 10 now recognizes PCSX2 as PC-playable platform, added `$hasPcsx2` init and PCSX2 stats
- Updated all docs (README, CLAUDE.md, CHANGELOG, INTEGRATION.md) for v2.20.0
- Fixed CLAUDE.md structure tree: added missing `docs/STEAM-API-RESEARCH.md` and `.github/workflows/release.yml`

## Decisions Made
- PAL/NTSC-J games included in PCSX2 coverage: database is emulator-focused, not region-locked. Used SLES/SCES/SLPM serials for PAL/Japan exclusives.
- Shox (SLUS-20533) excluded: absent from GTPlanet DF list despite being EA, wheel support uncertain. Could add later with unknown wheel_support.
- Harley-Davidson and Frenzy Express kept at medium: no definitive rotation specs found (90° and 45° respectively are inference-based)

## Open Items
- [ ] 2 arcade medium entries still need research: `harley_davidson` (90° unverified), `frenzy_express` (45° unverified)
- [ ] 5 Steam medium entries can't be upgraded: `nash_racing`, `project_drift`, `drifto_infinite_touge`, `rally_evolution_2025`, `interstate_drifter_1999`
- [ ] ~8 single-source entries remain (down from 44→8 this session)
- [ ] Shox (SLUS-20533) needs hands-on wheel verification before adding

## Next Steps
1. Research remaining 2 arcade mediums (Harley-Davidson operator manual, Frenzy Express scooter specs)
2. Resolve last ~8 single-source entries
3. Consider adding more PAL-only PS2 games (WRC II-IV, F1 05/06, more Studio Liverpool titles)

## Context for Next Session
v2.20.0 committed and pushed. PCSX2 coverage at 50 games (from 11 at start of v2.18.0). Database at 674 games total. The GTPlanet Logitech Driving Force compatibility thread and PCSX2 Wiki steering wheel category are exhausted as sources for new PS2 games. Next PCSX2 expansion would need new sources or PAL-only deep-dives. Single-source entries nearly eliminated (8 remain). The Harley-Davidson King of the Road operator manual exists on Manualzz but returned 403 — may need Playwright to access.
