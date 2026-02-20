# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [2.15.0] - 2026-02-20

### Added
- New `Audit-Database.ps1` script: comprehensive data quality report covering rotation_type gaps, cross-field consistency, completeness metrics, and source coverage
- Enhanced `Validate-Database.ps1` with 3 new cross-field checks (8-10): infinite rotation type consistency, Steam/pc metadata alignment
- Enriched 13 Steam entries with PCGamingWiki URLs (90% → 95% coverage)

### Fixed
- Classified rotation_type for all 80 remaining "unknown" arcade entries:
  - 7 optical_encoder (TTL-era infinite rotation games)
  - 15 potentiometer (Namco VG75-07050-00 standard + Gaelco + Race Drivin')
  - 58 mechanical_stop (Sega SPG-2002, Konami, Taito, Midway SuzoHapp Active 270, Atari Games, Global VR, Video System, others)
- Zero "unknown" rotation_type entries remaining in the database

### Changed
- rotation_type distribution: mechanical_stop=239, potentiometer=87, optical_encoder=31, null=256 (was unknown=80)

## [2.14.0] - 2026-02-20

### Fixed
- Corrected 7 Namco motorcycle MAME entries from 45° to 60° (500 GP, Cyber Cycles, Downhill Bikers, Moto GP, Motocross Go!, Suzuka 8 Hours 1 & 2) based on confirmed VG75-03824-00 potentiometer spec (1K ohm, 60-degree)
- Corrected Screamer (2026): ws=none, ffb=none, rotation=null (twin-stick architecture incompatible with wheels)

### Changed
- Screamer upgraded from medium to high confidence based on developer and preview evidence of twin-stick controls
- Confidence distribution: verified=57, high=538, medium=16, low=2

## [2.13.0] - 2026-02-20

### Changed
- Upgraded 92 entries from medium to high confidence:
  - 32 MAME motorcycle/watercraft/specialty entries with 3+ manufacturer hardware doc sources
  - 13 well-documented ws=none Steam entries with 4+ independent sources
  - 21 Milestone/KT Racing motorcycle Steam entries (developer pattern + PCGamingWiki)
  - 15 v2.12.0 Steam entries with detailed research agent findings (MX vs ATV, anti-gravity, kart/arcade)
  - 4 MAME weak-source entries with added manufacturer pattern references
  - 3 TeknoParrot entries with SuzoHapp parts documentation (Batman, Nicktoons Nitro, Wasteland Racers)
  - 3 Steam entries with community/developer research (Torque Drift 2, MX vs ATV Legends, Pacer)
  - 1 manual fix (A.B. Cop added manufacturer reference)
- Downgraded 2 entries from medium to low (Crazy Ride, Crazy Speed - no UNIS cabinet documentation)
- Confidence distribution: verified=57, high=537, medium=17, low=2 (was high=445, medium=111)

### Fixed
- Corrected MX vs ATV Legends: wheel_support partial→none, force_feedback unknown→none, rotation 270→null (developer confirmed wheels not supported)
- Corrected Frenzy Express year 2015→2001 (confirmed by Arcade Museum)
- Corrected Harley-Davidson King of the Road year 2006→2009 (Sega Lindbergh Red EX international release)

### Added
- Enriched 6 TeknoParrot motorcycle entries with hardware documentation sources (Dead Heat Riders, MotoGP Namco, Nirin, Radikal Bikers, Frenzy Express, Harley-Davidson KotR)
- Updated 9 null-rotation entries with N/A explanation notes (anti-gravity racers, drag racing, top-down games)

## [2.12.0] - 2026-02-20

### Added
- 39 new Steam games from discovery research:
  - Drift/street racing: Drift Reign, Clutch: The Drift Simulation, Drift (tafheet), Underground Garage, NIGHT-RUNNERS Prologue
  - Motorcycle series: RIDE 2-4, MotoGP 25, MXGP 1-3/Pro/2019/2020/24, TT Isle of Man 1-2, RiMS Racing
  - Off-road: MX vs ATV All Out/Reflex/Unleashed
  - Monster Energy Supercross 1-3, 6
  - Drag racing: NHRA Speed For All, Street Outlaws: The List
  - Anti-gravity: Redout 1-2, BallisticNG, Antigraviator, Pacer, Aero GPX
  - Kart/arcade: GT Racing 1980, Nightmare Kart, Super Indie Karts, Karting Superstars
  - Rally: Rally Evolution 2025

### Changed
- Confidence distribution: verified=57, high=445, medium=111, low=0 (was high=444, medium=73)
- Database now at 613 entries with 259 Steam games

## [2.11.0] - 2026-02-20

### Added
- 8 new Steam games: WRC 6, NASCAR 21: Ignition, NASCAR Heat 5, Torque Drift 2, RIDE 5, MotoGP 24, MX vs ATV Legends, TT Isle of Man: Ride on the Edge 3
- Upgraded 11 Steam entries from medium to high confidence with community-verified wheel support classifications

### Fixed
- Corrected Trackmania (2020) wheel support from native to partial (binary inputs, no FFB, not designed for wheels)
- Corrected Gear.Club Unlimited 3 wheel support from unknown to none (developer confirmed no wheel support for franchise)

### Changed
- Confidence distribution: verified=57, high=444, medium=73, low=0 (was high=430, medium=79)
- Database now at 574 entries with 220 Steam games

## [2.10.0] - 2026-02-19

### Changed
- **Zero low-confidence entries remaining** -- every entry is now at least medium confidence
- Confidence distribution: verified=57, high=430, medium=79, low=0 (was high=332, medium=114, low=57)
- Upgraded 98 entries from medium to high confidence:
  - 47 arcade batch upgrades: TTL/optical encoder games (28), well-documented 3-source arcade games (19)
  - 51 PC/Steam batch upgrades: native wheel+FFB racing sims (18), documented wheel support games (6), arcade-style PC racers with confirmed classification (27)
- Upgraded 59 entries from low to medium confidence:
  - 32 arcade motorcycle/watercraft/specialty entries with confirmed handlebar ranges
  - 27 PC/Steam games with PCGamingWiki-confirmed wheel support classification

## [2.9.0] - 2026-02-19

### Added
- 6 new Steam games: Kart Racing Pro, Trackmania (2020), Forza Horizon 6, iRacing Arcade, Screamer (2026), Gear.Club Unlimited 3
- Upgraded 74 entries from medium to high confidence:
  - PC game families: SimBin/ISIMotor (6), TrackMania/Nadeo (5), Farming Simulator/GIANTS (4), Bus simulators (6), Truck simulators (3), FlatOut/Bugbear (2), Need for Speed/EA (5), Monster Jam (2), plus 8 individual well-documented PC games
  - Arcade near-misses: Sega ALLS (3), Taito (5), Konami (2), Midway/Bally (4), Jaleco (2), Video System (3), Sammy (2), Data East (3), Tatsumi (3), Global VR (3), plus misc manufacturers (5)

### Fixed
- Corrected NASCAR Racing notes: Sega Hikaru hardware (was incorrectly listed as Chihiro)

### Changed
- Confidence distribution: verified=57, high=332, medium=114, low=57 (was high=258, medium=188)
- Database now at 566 entries with 212 Steam games
- Cross-platform emulator research completed: Cxbx-Reloaded, PCSX2, RPCS3 platform keys not practical (Chihiro emulation too limited, PCSX2 can't do System 246, no System 357 racing games exist)

## [2.8.0] - 2026-02-19

### Added
- 20 new Steam games from discovery research
- 198 PCGamingWiki URLs enriched on Steam entries (96% coverage)
- Upgraded 88 arcade entries from medium to high confidence using manufacturer hardware documentation:
  - Namco 270° potentiometer (20 games, part VG75-07050-00)
  - Sega SPG-2002 steering assembly (18 games)
  - Midway SuzoHapp Active 270 (8 games)
  - Taito Z System (15 games, MAME source code confirmation)
  - Konami racing cabinet standard (14 games)
  - Battle Gear 540° via TeknoParrot metadata (4 games)
  - Initial D 540° via TeknoParrot metadata (3 games)
  - Gaelco 270° standard (6 games)
- Upgraded 59 arcade entries from low to medium confidence using manufacturer steering standards
- Upgraded 12 Steam entries from low to medium confidence with researched sources

### Fixed
- **Hard Drivin' rotation corrected 270° → 1080°** (10-turn potentiometer with 3-rotation mechanical stop)
- Corrected 33 motorcycle/watercraft/specialty games from 270° (car default) to correct handlebar ranges:
  - Sega motorcycles (Hang-On, Super Hang-On, GP Rider, etc.): 45° body-lean
  - Sega Model 2/3 motorcycles (Manx TT, Motor Raid, Harley-Davidson): 56° enhanced tilt
  - Namco motorcycles (Suzuka 8 Hours, 500 GP, Motocross Go, etc.): 45°
  - Watercraft (Wave Runner, Aqua Jet, Jet Wave, Rapid River): 60° handlebar
  - Specialty vehicles (S.T.U.N. Runner, Star Rider, Vapor TRX, Power Sled): 45°
- A.B. Cop corrected from 270° → 45° (motorcycle, not car)
- Corrected GTR 2 Steam appid, GRIP rotation, Drift Type C/Offroad Mania wheel support
- Fixed Split/Second and RENNSPORT PCGamingWiki URLs

### Removed
- 30 entries: 29 non-wheel Steam games + Cycle Warriors (uses 8-way joystick, not wheel)

### Changed
- Confidence distribution: verified=57, high=258, medium=188, low=57 (was high=169, medium=277)
- Database now at 560 entries with 0 unknowns remaining
- All motorcycle/watercraft games now use `potentiometer` rotation type instead of `mechanical_stop`

## [2.7.0] - 2026-02-17

### Added
- Set rotation values for 70 additional arcade games: Sega motorcycle series (Hang-On, Manx TT, Harley-Davidson), Namco motorcycle games (Suzuka 8 Hours, 500 GP), Taito (Chase H.Q. 2, Super Dead Heat), Konami (Hot Chase, Jet Wave), and misc driving games (TX-1, Tokyo Bus Guide, F-1 Super Battle)
- Set 18 TTL-era games as optical encoders (-1): Crash'n Score, Le Mans, Indy 800, Death Race, 280-ZZZAP, and others

### Removed
- 94 non-driving MAME entries: tanks (Battle Zone, Vindicators), shooters (Moon Patrol, Galactic Storm), flight sims (Top Landing), console ports (PlayChoice-10, NSS), Neo Geo joystick racers (Rally X, Thrash Rally), fitness equipment, and prototypes

### Changed
- All MAME entries now have rotation values -- 56 remaining unknowns are Steam-only
- Database reduced from 664 to 570 entries (non-driving cleanup)

## [2.6.0] - 2026-02-17

### Added
- Set rotation values for 85 arcade games using manufacturer documentation: Sega (F355, OutRun 2, Club Kart), Namco (Ridge Racer 2, Final Lap, WMMT 1&2), Konami (GTI Club, Chase H.Q., Thrill Drive, Racing Jam), Atari/Midway (SF Rush series, Race Drivin' 1080°, Cruis'n, Hydro Thunder), Gaelco (Speed Up, World Rally 2), and TTL-era optical encoders
- Upgraded 13 TeknoParrot entries to high confidence with enriched sources from SuzoHapp catalogs, BYOAC forum, and service manuals

### Removed
- 126 MAME clone entries (inherit rotation from parent ROM)
- 33 non-driving games (shooters, flight sims, kiddie rides)
- 17 duplicate entries merged into existing cross-platform entries

### Changed
- Unknown rotation count reduced from 500 to 238
- Database reduced from 841 to 664 entries
- Consolidated 6 Club Kart MAME variants into single entry with `romnames` array

## [2.5.0] - 2026-02-16

### Added
- Emulator platform keys for 22 games across 4 emulators:
  - Supermodel: 9 Sega Model 3 games (Daytona USA 2, Scud Race, Sega Rally 2, etc.)
  - Model 2 Emulator: 4 Sega Model 2 games (Manx TT, Motor Raid, Over Rev, Super GT)
  - Flycast: 6 NAOMI games (18 Wheeler, Crazy Taxi, Jambo Safari, F355 Challenge x3)
  - Dolphin: 3 Triforce games (F-Zero AX Monster, Mario Kart GP 1&2)
- Paddle/dial triage: categorized ~107 MAME games as driving vs non-driving

### Removed
- 2 duplicate Mario Kart entries (merged MAME data into existing TeknoParrot entries)

### Changed
- Updated CLAUDE.md documentation for v2.4.0 schema changes

## [2.4.0] - 2026-02-15

### Added
- `romnames` array support in MAME platform entries for games with multiple ROM sets
- 8 new Steam racing games from discovery research
- Upgraded 13 TeknoParrot entries to high confidence, corrected Raw Thrills motorcycle rotation

### Changed
- Merged 6 cross-platform duplicate entries (MAME + TeknoParrot/Steam variants consolidated)
- Export scripts handle both `romname` (singular) and `romnames` (array), expanding arrays into one row per ROM
- Validation script checks uniqueness across both `romname` and `romnames` fields

## [2.3.0] - 2026-02-15

### Added
- 11 new Steam racing games from discovery research
- Upgraded 16 arcade entries to medium confidence with additional sources

### Fixed
- Corrected rotation values for Re-Volt and SRS
- Fixed rotation values and force feedback status for 6 Steam games

## [2.2.0] - 2026-02-15

### Added
- Rotation recommendations for 40 Steam games

### Changed
- Merged steam-wheel-support-db into unified wheel-db (v2.1.0), creating a single game-centric database
- Schema upgraded to v2.0: `emulators` renamed to `platforms`, added `pc` sub-object for wheel support and force feedback

## [1.5.0] - 2026-02-02

### Added
- `profiles` array support for TeknoParrot entries with multiple game profiles
- Migrated 9 TeknoParrot entries to use `profiles` array
- Integration guide for data consumers (`docs/INTEGRATION.md`)

## [1.4.0] - 2026-02-01

### Added
- 444 driving/racing games from MAME catver.ini import, bringing total to 636
- Export script generating CSV and XML formats from JSON master
- GitHub Actions release workflow for automated releases on version changes
- 63 MAME games with researched wheel rotation values (v1.3.0)
- Initial database with 129 games, inventory scripts for MAME and TeknoParrot, and project documentation
