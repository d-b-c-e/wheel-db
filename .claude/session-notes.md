# Session Notes
<!-- Written by /wrapup. Read by /catchup at the start of the next session. -->
<!-- Overwritten each session — history preserved in git log of this file. -->

- **Date:** 2026-02-22
- **Branch:** main

## What Was Done
- v2.25.0: Upgraded 12 medium-confidence entries to high via targeted research
- v2.26.0: Added 10 new RPCS3/PS3 entries + 1 RPCS3 platform mapping to existing entry
  - NASCAR 08 (BLUS-30040): native wheel/FFB, 540°
  - NASCAR 09 (BLUS-30139): native wheel/FFB, 540°
  - NASCAR The Game 2011 (BLUS-30604): native wheel/FFB, 540°
  - NASCAR Inside Line (BLUS-30932): native wheel/FFB, 540°
  - NASCAR '14 (BLUS-31378): native wheel/FFB, 540°
  - NASCAR '15: added RPCS3 serial BLUS-31560 to existing Steam entry
  - Test Drive Unlimited 2 (BLUS-30527): native wheel, partial FFB, 200°
  - Superstars V8 Racing (BLES-00529): native wheel/FFB, 900°
  - Baja: Edge of Control (BLUS-30191): native wheel, partial FFB, 900°
  - Supercar Challenge (BLES-00581): EU-exclusive, native wheel/FFB, 900°
  - Stuntman: Ignition (BLUS-30073): partial wheel, no FFB, 270°
- Evaluated Cxbx-Reloaded/Chihiro platform: NOT recommended (emulation too immature, all 5 racing games already in DB via MAME)
- Checked Endurance Motorsport Series: not released yet, still "Coming Soon" targeting Q1 2026
- Docs updated: CHANGELOG, README, CLAUDE.md, session-notes — all stats bumped to v2.26.0

## Decisions Made
- Cxbx-Reloaded/Chihiro platform skipped: only 5 racing games exist, all already in DB via MAME. Emulation is too immature for wheel support.
- Juiced 2 skipped: no native wheel support on PS3
- Superstars V8 Racing: used EU disc serial BLES-00529 as primary (US version NPUB-30338 is PSN digital-only)
- Supercar Challenge: EU-exclusive title, used BLES-00581 (no US release)
- TDU2 rotation set to 200° per community consensus (arcade handling feels wrong at higher values)
- NASCAR PS3 series all set to 540° matching real NASCAR stock car steering

## Open Items
- [ ] 3 medium-confidence entries remain: Harley-Davidson KotR, Crazy Speed, Frenzy Express
- [ ] Harley-Davidson KotR needs Sega Lindbergh Red EX cabinet documentation for medium→high
- [ ] Shox (PCSX2) still needs hands-on wheel verification
- [ ] Endurance Motorsport Series — add when released (expected Q1 2026)

## Next Steps
1. Research Harley-Davidson KotR for medium→high (Sega Lindbergh cabinet docs or BYOAC owner reports)
2. Consider additional PS3 games if community identifies more candidates
3. Monitor Endurance Motorsport Series release for addition
4. Consider expanding to other platforms or enriching existing entries

## Context for Next Session
v2.26.0 committed. Database at 722 games (+10 new RPCS3 entries). RPCS3 coverage now at 54 entries (was 43). Only 3 medium-confidence entries remain (all obscure arcade games). PC wheel support: native=192, partial=95, none=84. PC FFB: native=145, partial=76, none=141. Confidence: verified=60, high=659, medium=3, low=0.
