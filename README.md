# wheel-db

A community database of steering wheel metadata for racing/driving games across arcade emulators and PC platforms. Helps users configure their USB racing wheels with correct rotation degrees, identify games with native wheel support, and check force feedback compatibility.

## Why This Exists

Modern USB racing wheels support 270-1080 degrees of rotation, but original arcade cabinets varied widely -- 270 degrees was common for arcade racers, some used 360 degrees, early games used infinite-rotation optical encoders, and motorcycle games used as little as 45 degrees. PC racing games also have widely varying recommended rotation settings. Without this data, players must guess or manually research each game.

## Database

The primary database is `data/wheel-db.json` -- a unified, game-centric JSON file where each entry represents a unique game. Platform-specific identifiers (MAME ROM names, TeknoParrot profiles, Steam app IDs, etc.) are stored in a `platforms` map so a game's data is never duplicated across platforms.

### Current Stats (v2.13.0)

| Metric | Count |
|--------|-------|
| Total game entries | 613 |
| With MAME mapping | 291 |
| With TeknoParrot mapping | 81 |
| With Steam mapping | 259 |
| With Supermodel mapping | 9 |
| With Flycast mapping | 9 |
| With Model 2 Emulator mapping | 6 |
| With Dolphin mapping | 4 |
| With known rotation value | 573 |
| Rotation N/A | 9 |
| Infinite rotation (encoders) | 31 |

**Confidence:** verified (57), high (537), medium (17), low (2)

**Rotation values:** 270 (295 games), 540 (81), 360 (57), 900 (54), 45 (27), 180 (16), 56 (10), 60 (8), 1080 (4), 450 (4), 200 (3), 240 (3), 390 (3), 150 (2), 90 (2), 300 (1), 480 (1), 720 (1), 800 (1)

**PC wheel support:** native (137 games), partial (58), none (61)

**PC force feedback:** native (101), partial (40), none (112)

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

## Repository Structure

```
wheel-db/
  data/
    wheel-db.json                # Primary database (613 games)
    schema/
      wheel-db.schema.json       # JSON Schema for validation
  scripts/
    Setup-Dependencies.ps1       # Download/copy data dependencies
    Get-MameGames.ps1            # MAME wheel game inventory
    Get-TeknoparrotGames.ps1     # TeknoParrot wheel game inventory
    Get-SteamRacingGames.ps1     # Steam racing game discovery
    Export-Formats.ps1           # Generate CSV/XML exports into dist/
    Validate-Database.ps1        # Schema validation and data checks
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
| `wheel-db.csv` | CSV | Unified flat CSV of all 613 games across all platforms |

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
