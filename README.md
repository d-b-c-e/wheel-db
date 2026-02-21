# wheel-db

A community database of steering wheel metadata for racing/driving games across arcade emulators and PC platforms. Helps users configure their USB racing wheels with correct rotation degrees, identify games with native wheel support, and check force feedback compatibility.

## Why This Exists

Modern USB racing wheels support 270-1080 degrees of rotation, but original arcade cabinets varied widely -- 270 degrees was common for arcade racers, some used 360 degrees, early games used infinite-rotation optical encoders, and motorcycle games used as little as 45 degrees. PC racing games also have widely varying recommended rotation settings. Without this data, players must guess or manually research each game.

## Database

The primary database is `data/wheel-db.json` -- a unified, game-centric JSON file where each entry represents a unique game. Platform-specific identifiers (MAME ROM names, TeknoParrot profiles, Steam app IDs, etc.) are stored in a `platforms` map so a game's data is never duplicated across platforms.

### Current Stats (v2.19.0)

| Metric | Count |
|--------|-------|
| Total game entries | 659 |
| With MAME mapping | 294 |
| With TeknoParrot mapping | 81 |
| With Steam mapping | 276 |
| With Supermodel mapping | 9 |
| With Flycast mapping | 9 |
| With Model 2 Emulator mapping | 6 |
| With Dolphin mapping | 4 |
| With PCSX2 mapping | 35 |
| With known rotation value | 603 |
| Rotation N/A | 25 |
| Infinite rotation (encoders) | 31 |

**Confidence:** verified (58), high (592), medium (9), low (0)

**Rotation values:** 270 (305 games), 540 (89), 360 (57), 900 (58), 45 (19), 180 (16), 200 (13), 60 (14), 56 (10), 1080 (4), 450 (4), 240 (3), 390 (3), 150 (2), 90 (2), 300 (1), 480 (1), 720 (1), 800 (1)

**PC wheel support:** native (142 games), partial (84), none (79)

**PC force feedback:** native (107), partial (64), none (137)

### Special Values

- **`-1`** = Infinite rotation (optical encoder / spinner, no physical stops)
- **`null`** = Not applicable (anti-gravity racers, drag racing, motorcycle games where wheels aren't the intended input)

### Platform Coverage

The database covers games across multiple platforms in a single entry:

| Platform | Key | ID Field | Coverage |
|----------|-----|----------|----------|
| MAME | `mame` | `romname`/`romnames` | Arcade games emulated by MAME |
| TeknoParrot | `teknoparrot` | `profile`/`profiles` | Modern arcade games |
| Steam | `steam` | `appid` | PC games on Steam |
| Supermodel | `supermodel` | `romname` | Sega Model 3 |
| Model 2 Emulator | `m2emulator` | `romname` | Sega Model 2 |
| Flycast | `flycast` | `romname` | Naomi/Atomiswave |
| Dolphin | `dolphin` | `game_id` | Triforce/GameCube |
| PCSX2 | `pcsx2` | `serial` | PS2 games via emulation |

Games that exist on multiple platforms (e.g., Crazy Taxi on both MAME and Steam) have a single entry with all platform mappings.

## Scripts

All scripts are PowerShell 7+ and located in `scripts/`.

| Script | Description |
|--------|-------------|
| `Setup-Dependencies.ps1` | Downloads catver.ini, controls.xml, nplayers.ini; generates MAME listxml |
| `Get-MameGames.ps1` | Parses MAME data sources to inventory all racing/driving games with wheel controls |
| `Get-TeknoparrotGames.ps1` | Scans local TeknoParrot installation for wheel-equipped games |
| `Get-SteamRacingGames.ps1` | Fetches top racing/driving games from SteamSpy and Steam Store APIs |
| `Export-Formats.ps1` | Generates CSV and XML exports from JSON master into `dist/` |
| `Validate-Database.ps1` | Validates database structure, enums, ranges, and uniqueness constraints |
| `Audit-Database.ps1` | Comprehensive data quality report (rotation_type gaps, consistency, completeness) |

## Repository Structure

```
wheel-db/
  data/
    wheel-db.json                # Primary database (659 games)
    schema/
      wheel-db.schema.json       # JSON Schema for validation
  scripts/
    Setup-Dependencies.ps1       # Download/copy data dependencies
    Get-MameGames.ps1            # MAME wheel game inventory
    Get-TeknoparrotGames.ps1     # TeknoParrot wheel game inventory
    Get-SteamRacingGames.ps1     # Steam racing game discovery
    Export-Formats.ps1           # Generate CSV/XML exports into dist/
    Validate-Database.ps1        # Schema validation and data checks
    Audit-Database.ps1           # Data quality audit and consistency report
    archive/                     # One-time migration scripts
  .github/
    workflows/
      release.yml                # Auto-release on database version change
  sources/
    downloads/                   # catver.ini, controls.xml, etc. (gitignored)
    cache/                       # Generated inventories (gitignored)
  dist/                          # Build artifacts (gitignored, attached to releases)
```

## Consuming the Data

Each [GitHub Release](../../releases) includes these artifacts:

| File | Format | Description |
|------|--------|-------------|
| `wheel-db.json` | JSON | Full unified database with all metadata and multi-platform mappings |
| `mame-wheel-rotation.csv` | CSV | Flat MAME ROM-to-rotation lookup (known values only) |
| `mame-wheel-rotation.xml` | XML | Same MAME data in XML format |
| `steam-wheel-support.csv` | CSV | Steam games with wheel support, FFB, and rotation info |
| `wheel-db.csv` | CSV | Unified flat CSV of all 659 games across all platforms |

For detailed parsing instructions and code examples, see **[docs/INTEGRATION.md](docs/INTEGRATION.md)**.

## Contributing

If you have verified information about a game's wheel rotation or support:

1. Fork the repository
2. Edit `data/wheel-db.json`
3. Add your entry following the schema (see `data/schema/wheel-db.schema.json`)
4. Include at least one source documenting where the data came from
5. Submit a pull request

## License

[MIT](LICENSE)
