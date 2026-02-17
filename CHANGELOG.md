# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Changed
- Updated CLAUDE.md for v2.7.0: corrected Battle Gear rotation (270° → 540°), expanded Konami/Taito appendix, marked MAME cleanup as complete

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
