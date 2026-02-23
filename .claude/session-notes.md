# Session Notes
<!-- Written by /wrapup. Read by /catchup at the start of the next session. -->
<!-- Overwritten each session — history preserved in git log of this file. -->

- **Date:** 2026-02-22
- **Branch:** main

## What Was Done
- v2.25.0: Upgraded 12 medium-confidence entries to high via targeted research
- v2.26.0: Added 10 new RPCS3/PS3 entries + 1 RPCS3 platform mapping (NASCAR 08-14, TDU2, Superstars V8, Baja, Supercar Challenge, Stuntman Ignition, NASCAR '15 mapping)
- v2.27.0: Added 4 new RPCS3 entries + 3 platform mappings + 9 FFB upgrades
  - New: Gran Turismo HD Concept, Superstars V8: Next Challenge, Ferrari: The Race Experience, Absolute Supercars
  - Platform mappings: Daytona USA PSN (NPUB-30493), OutRun Online Arcade (NPEB-00073), SEGA Rally Online Arcade (NPUB-30375)
  - FFB unknown→native: WRC PS2, Rally Fusion RoC, Lotus Challenge, Knight Rider, WRC II Extreme, F1 05, F1 06, Initial D Special Stage, F1 Career Challenge
- Re-researched 3 medium entries (Harley-Davidson, Crazy Speed, Frenzy Express) — all stay medium, no new evidence found
- Evaluated Cxbx-Reloaded/Chihiro: NOT recommended (emulation too immature)
- Endurance Motorsport Series: not released yet (Q1 2026 target)

## Decisions Made
- All 9 PS2 FFB upgrades based on Logitech DFGT official compatibility list — being on an FFB wheel's compatibility list inherently confirms FFB support
- Absolute Supercars kept as separate entry from Supercar Challenge (different game content despite shared lineage)
- Daytona USA PSN, OutRun Online Arcade, SEGA Rally Online Arcade mapped to existing arcade entries (same game content)
- Medium entries definitively stuck: Harley-Davidson manual exists online but PDF inaccessible, Crazy Speed has no manufacturer specs, Frenzy Express too rare

## Open Items
- [ ] 3 medium-confidence entries remain: Harley-Davidson KotR, Crazy Speed, Frenzy Express (effectively permanent)
- [ ] 76 entries have null controller_support in pc sub-object (batch-enrichable from Steam API)
- [ ] 16 RPCS3-only entries could get Steam appids (delisted Codemasters/EA titles)
- [ ] 25 null rotation_degrees entries (~6 need research, rest are N/A by design)
- [ ] Shox (PCSX2) still needs hands-on wheel verification
- [ ] Endurance Motorsport Series — add when released

## Next Steps
1. Batch-enrich controller_support for 76 entries (Steam Store API or PCGamingWiki)
2. Add Steam appids to RPCS3-only entries that had PC releases (DiRT 1-3, GRID 1-2, F1 2010-2013, etc.)
3. Research null rotation for ~6 applicable entries (Screamer, MX vs ATV Legends, etc.)
4. Monitor Endurance Motorsport Series release

## Context for Next Session
v2.27.0 committed. Database at 726 games, RPCS3 at 61 entries. Zero unknown FFB entries remain. Only 3 medium-confidence entries (all effectively permanent — obscure arcade games with inaccessible documentation). Major quality gaps: 76 null controller_support, 16 RPCS3-only entries missing Steam appids. PC stats: ws native=195/partial=96/none=84, ffb native=157/partial=77/none=141.
