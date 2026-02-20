# CLAUDE.md - wheel-db

## Project Overview

**wheel-db** is a unified database of steering wheel metadata for racing/driving games across arcade emulators and PC platforms. It tracks rotation degrees, wheel support quality, force feedback compatibility, and platform-specific identifiers for MAME, TeknoParrot, Steam, and other platforms.

### Why This Matters

Modern racing wheels typically support 270°, 540°, 900°, or 1080° rotation. Original arcade cabinets varied widely, and PC racing games each have their own recommended settings. Without this metadata, players must guess or manually research each game.

### Primary Goals

1. Create a comprehensive, machine-readable database of wheel metadata for all racing/driving games
2. Cover arcade emulators (MAME, TeknoParrot, etc.) AND PC platforms (Steam, etc.)
3. Track rotation degrees, wheel support quality, and force feedback for PC games
4. Document data sources and confidence levels for each entry
5. Provide tooling to help frontends and emulators auto-configure wheel settings

### Special Values

- **`-1`** = Infinite rotation / optical encoder (no physical stops). Used for spinners, dial controls, and early steering wheels that rotate continuously. These games need special handling in emulators (map to mouse/spinner input rather than a fixed-range wheel).
- **`null`** = Rotation value not yet determined. The game is in the inventory but needs research.

### Unified Game-Centric Model

A single game may exist on multiple platforms (MAME, TeknoParrot, Steam, Supermodel, etc.). The database has **one entry per game** with platform-specific identifiers in a `platforms` map. Games that exist on both arcade and PC (e.g., Crazy Taxi) have a single entry with both `platforms.mame` and `platforms.steam`.

PC-specific metadata (wheel support quality, force feedback) is stored in a `pc` sub-object that only applies to games playable on PC.

### Other Emulators to Consider

Beyond MAME and TeknoParrot, many arcade racing games are emulated by standalone or specialized emulators:

| Emulator | Hardware Covered | Notes |
|----------|-----------------|-------|
| **Supermodel** | Sega Model 3 (Daytona USA 2, Scud Race, Sega Rally 2, etc.) | 9 entries linked |
| **Model 2 Emulator** | Sega Model 2 (Daytona USA, Sega Rally, etc.) | 6 entries linked |
| **Flycast / Demul** | Sega Naomi/Naomi 2, Atomiswave | 9 entries linked (Initial D 1-3, F355 x3, etc.) |
| **Cxbx-Reloaded** | Sega Chihiro (Xbox-based) | OutRun 2, House of the Dead III |
| **Dolphin** | Triforce (GameCube-based) | 4 entries linked (F-Zero AX, Mario Kart GP 1&2) |
| **RPCS3** | Namco System 357 (PS3-based) | Some newer arcade titles |
| **PCSX2** | Namco System 246/256 (PS2-based) | Ridge Racer V, Wangan Midnight |

A game like Daytona USA could be run on MAME, Model 2 Emulator, or even Supermodel (for the Model 3 sequel) - the physical cabinet's wheel rotation is the same regardless of which emulator runs it. The unified model captures this correctly. As of v2.5.0, cross-platform linking is implemented for Supermodel, Model 2 Emulator, Flycast, and Dolphin.

---

## Repository Structure

```
wheel-db/
├── CLAUDE.md                    # This file - AI assistant instructions
├── README.md                    # Project documentation for humans
├── LICENSE                      # MIT License
├── data/
│   ├── wheel-db.json            # Unified database (613 games)
│   └── schema/
│       └── wheel-db.schema.json # JSON Schema for validation
├── scripts/
│   ├── Setup-Dependencies.ps1   # Downloads MAME data dependencies
│   ├── Get-MameGames.ps1        # MAME wheel game inventory
│   ├── Get-TeknoparrotGames.ps1 # TeknoParrot wheel game inventory
│   ├── Get-SteamRacingGames.ps1 # Steam racing game discovery via APIs
│   ├── Export-Formats.ps1       # Generates CSV, XML from JSON master
│   ├── Validate-Database.ps1    # Validates against schema
│   └── archive/                 # One-time migration scripts
├── sources/
│   ├── downloads/               # Downloaded dependencies (gitignored)
│   └── cache/                   # Cached inventories (gitignored)
├── dist/                        # Build artifacts (gitignored, in releases)
└── docs/
    └── INTEGRATION.md           # How to use this data in frontends/emulators
```

---

## Data Schema

### Primary Database Format (JSON)

The database uses a **unified game-centric model** with 613 entries as of v2.13.0. Each entry represents a unique game (arcade or PC). Platform-specific identifiers are stored in a `platforms` map. PC-specific metadata (wheel support, force feedback) is in a `pc` sub-object.

```json
{
  "version": "2.10.0",
  "generated": "2026-02-19T00:00:00Z",
  "games": {
    "outrun": {
      "title": "Out Run",
      "manufacturer": "Sega",
      "developer": null,
      "publisher": null,
      "year": "1986",
      "rotation_degrees": 270,
      "rotation_type": "mechanical_stop",
      "confidence": "high",
      "sources": [{ "type": "manual", "description": "Sega Out Run Operator's Manual", "url": null, "date_accessed": "2026-01-31" }],
      "notes": "Uses mechanical stops at 135 degrees each direction from center.",
      "pc": null,
      "platforms": {
        "mame": { "romname": "outrun", "clones_inherit": true }
      }
    },
    "power_drift": {
      "...": "...",
      "platforms": {
        "mame": { "romnames": ["pdrift", "pdriftl"], "clones_inherit": true }
      }
    },
    "assetto_corsa": {
      "title": "Assetto Corsa",
      "manufacturer": null,
      "developer": "Kunos Simulazioni",
      "publisher": "505 Games",
      "year": "2014",
      "rotation_degrees": 900,
      "rotation_type": null,
      "confidence": "verified",
      "sources": [{ "type": "pcgamingwiki", "description": "PCGamingWiki confirms full wheel and FFB support", "url": "https://www.pcgamingwiki.com/wiki/Assetto_Corsa", "date_accessed": "2026-02-14" }],
      "notes": "Gold standard for PC sim racing.",
      "pc": {
        "wheel_support": "native",
        "force_feedback": "native",
        "controller_support": "full"
      },
      "platforms": {
        "steam": { "appid": 244210, "tags": ["Racing", "Simulation"], "store_url": "https://store.steampowered.com/app/244210", "pcgamingwiki_url": "https://www.pcgamingwiki.com/wiki/Assetto_Corsa", "popularity_rank": 10, "owners_estimate": null }
      }
    }
  }
}
```

### Game Entry Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes | Full display title of the game |
| `manufacturer` | string/null | No | Arcade cabinet manufacturer. Null for PC-only games. |
| `developer` | string/null | No | Game developer. Primarily for PC games. |
| `publisher` | string/null | No | Game publisher. Primarily for PC games. |
| `year` | string/null | No | Release year (YYYY) |
| `rotation_degrees` | number/null | Yes | For arcade: exact cabinet spec. For PC: community recommended. `-1` = infinite. `null` = unknown. |
| `rotation_type` | enum/null | No | `mechanical_stop`, `optical_encoder`, `potentiometer`, `unknown`, or `null` (PC-only). Non-null = arcade cabinet spec. |
| `confidence` | enum | Yes | `verified`, `high`, `medium`, `low`, `unknown` |
| `sources` | array | Yes | At least one source documenting where the data came from |
| `notes` | string/null | No | Additional context |
| `pc` | object/null | No | PC-specific: `wheel_support`, `force_feedback`, `controller_support`. Null for arcade-only. |
| `platforms` | object | Yes | Map of platform keys to platform-specific metadata |

### PC Sub-Object Fields

Present only for games playable on PC.

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `wheel_support` | enum | Yes | `native`, `partial`, `none`, `unknown` |
| `force_feedback` | enum | Yes | `native`, `partial`, `none`, `unknown` |
| `controller_support` | enum/null | No | `full`, `partial`, `none` |

### Platform Sub-Entry Fields

Each key in `platforms` is a platform identifier. Known platforms:

| Platform Key | Platform | Identifier Field | Description |
|-------------|----------|-----------------|-------------|
| `mame` | MAME | `romname`/`romnames` | MAME ROM set name (singular) or array of ROM names (for multi-region/variant games). `clones_inherit`: whether clone ROMs share this value. |
| `teknoparrot` | TeknoParrot | `profile`/`profiles` | GameProfile XML filename(s) (without `.xml`) |
| `steam` | Steam | `appid` | Steam app ID. Also: `tags`, `store_url`, `pcgamingwiki_url`, `popularity_rank`, `owners_estimate` |
| `supermodel` | Supermodel | `romname` | Sega Model 3 ROM name |
| `m2emulator` | Model 2 Emulator | `romname` | Sega Model 2 ROM name |
| `flycast` | Flycast/Demul | `romname` | Naomi/Atomiswave ROM name |
| `dolphin` | Dolphin | `game_id` | Triforce/GameCube game ID |

Additional platform keys can be added as needed. The `platforms` map allows a single game to be linked to multiple emulation platforms.

### Rotation Types Explained

- **mechanical_stop**: Wheel has physical stops limiting rotation (most common)
- **optical_encoder**: Infinite rotation, relative positioning (like Pole Position)
- **potentiometer**: Absolute position sensing with physical limits
- **unknown**: Rotation type not determined

---

## Dependencies

### Required Downloads

The setup script should download and cache these:

1. **MAME Executable** (for `-listxml` output)
   - Source: https://www.mamedev.org/release.html
   - We only need the executable, not ROMs

2. **controls.dat / controls.xml**
   - Source: http://controls.arcadecontrols.com or GitHub mirrors
   - Provides control type information per game

3. **catver.ini**
   - Source: https://www.progettosnaps.net/catver/
   - Provides game categories to filter racing/driving games

4. **Category.ini**
   - Source: https://www.progettosnaps.net/renameset/
   - Alternative categorization

5. **nplayers.ini** (optional)
   - Source: http://nplayers.arcadebelgium.be/
   - Player count information

### PowerShell Requirements

- PowerShell 7+ recommended (cross-platform)
- Modules: None required (use native cmdlets)

---

## Script Specifications

### Implemented Scripts

#### Setup-Dependencies.ps1
Downloads/copies MAME data dependencies. Checks local LaunchBox installations first (R:\LaunchBox), falls back to GitHub downloads. Outputs to `sources/downloads/`.
- **catver.ini** - From local LaunchBox or [GitHub (AntoPISA/MAME_SupportFiles)](https://github.com/AntoPISA/MAME_SupportFiles)
- **controls.xml** - From [GitHub (benbaker76/ControlsDat)](https://github.com/benbaker76/ControlsDat)
- **nplayers.ini** - From local LaunchBox (optional)
- **mame-listxml.xml** - Generated from local MAME executable (~237MB)

Parameters: `-DownloadPath`, `-MameExePath`, `-Force`, `-SkipListXml`

#### Get-MameGames.ps1
Parses three MAME data sources to inventory all racing/driving games with wheel controls. Uses streaming XmlReader for the large listxml file. Outputs to `sources/cache/mame-games.json`.
- Phase 1: Parse catver.ini for Driving/Racing categories
- Phase 2: Stream-parse MAME listxml for paddle/dial/ad_stick controls
- Phase 3: Parse controls.xml for wheel/steering/paddle mentions (note: uses capitalized XML tags like `<Game RomName="...">`)
- Phase 4-6: Merge sources, cross-reference database, output JSON

Results: 1,488 total games, 484 with wheel controls, 1,040 parent ROMs, 63 from controls.xml with verified rotation values. After cleanup, 291 MAME entries remain in the database.

**MAME Research Progress**: MAME inventory cleanup is complete as of v2.7.0. All 291 MAME entries now have rotation values. The cleanup involved: removing ~271 non-driving entries (clones, tanks, shooters, flight sims, console ports, Neo Geo joystick games, fitness equipment), setting ~173 rotation values using manufacturer documentation (SuzoHapp catalogs, service manuals, TwistedQuarter parts lists, BYOAC forum, Arcade-Projects), and merging ~23 duplicate entries. In v2.8.0, 33 motorcycle/watercraft entries were corrected from 270° (car default) to proper handlebar ranges (45-60°), Hard Drivin' was corrected to 1080°, and Cycle Warriors was removed (joystick game). **The database currently has 0 unknown rotation values**. Confidence distribution: verified=57, high=537, medium=17, low=2. All low-confidence entries were eliminated in v2.10.0; v2.13.0 upgraded 92 medium→high entries using manufacturer hardware docs, developer patterns, and research agent findings.

#### Get-TeknoparrotGames.ps1
Scans local TeknoParrot installation for wheel-equipped games. Reads GameProfiles XML for `<AnalogType>Wheel</AnalogType>`, enriches from Metadata JSON. Outputs to `sources/cache/teknoparrot-games.json`.

Results: 487 profiles scanned, 98 wheel-equipped, 25 with metadata rotation values.

#### Export-Formats.ps1
Generates multiple export formats from the JSON master database. Handles both `romname` (singular) and `romnames` (array) for MAME entries, expanding arrays into one row per ROM name in flat exports.
- `dist/wheel-db.json` - Full database copy for releases
- `dist/mame-wheel-rotation.csv` - Flat MAME ROM-to-rotation lookup (one row per ROM name)
- `dist/mame-wheel-rotation.xml` - MAME data in XML format (one element per ROM name)
- `dist/steam-wheel-support.csv` - Steam games with wheel support info
- `dist/wheel-db.csv` - Unified flat CSV of all games (romnames joined with `;`)

#### Validate-Database.ps1
Validates database against v2.0+ schema:
- Required fields present on every entry
- Enum values valid (rotation_type, confidence, source types, wheel_support, force_feedback)
- Rotation values in range (45-1080, -1, or null)
- No duplicate Steam appids or MAME romnames (handles both `romname` and `romnames` array)
- Sources array non-empty
- PC sub-object validity

#### Get-SteamRacingGames.ps1
Fetches top racing/driving games from SteamSpy and Steam Store APIs.
- Queries SteamSpy for "Racing" and "Driving" tags
- Enriches with Steam Store API details (release year, controller support)
- Outputs ranked list to `sources/cache/steam-racing-games.json`

---

## Research Guidelines for Claude

When researching wheel rotation values, follow these guidelines:

### Reliable Sources (High Confidence)

1. **Official Operator/Service Manuals** - Definitive source
2. **Arcade Museum (KLOV)** - Community-verified specifications
3. **Original cabinet photos showing wheel mechanism** - Physical evidence
4. **BYOAC forum posts from cabinet owners** - First-hand experience

### Moderate Sources (Medium Confidence)

1. **Forum discussions with consensus** - Multiple agreeing users
2. **YouTube cabinet tours** - Visual confirmation
3. **Game-specific wikis** - May be accurate but verify

### Weak Sources (Low Confidence)

1. **Single forum post without verification**
2. **Blog posts without cited sources**
3. **Reddit comments**

### Inference Rules

When no direct information is available:

1. **Same hardware platform** - Games on same arcade board often share controls
   - Example: All Sega Super Scaler games likely share similar wheel specs
   
2. **Same manufacturer/era** - Manufacturers reused cabinet designs
   - Example: Sega Model 2 racing games likely similar
   
3. **Game series** - Sequels usually maintain control schemes
   - Example: OutRun → Turbo OutRun → OutRunners

4. **Control type hints** - 
   - "Spinner" or "dial" = likely optical encoder (infinite rotation)
   - "Paddle" = likely potentiometer with stops (180-270°)
   - "Steering wheel" = could be either, need more info

### Search Strategies

```
# Primary searches
"{game_title}" arcade steering wheel rotation degrees
"{game_title}" cabinet specifications steering
"{game_title}" MAME analog wheel setup

# Platform-specific
site:forum.arcadecontrols.com "{game_title}" wheel
site:forums.arcade-museum.com "{game_title}" steering
site:shmups.system11.org "{game_title}" wheel

# Manual searches
"{game_title}" operator manual PDF
"{game_title}" service manual steering

# Video evidence
"{game_title}" arcade cabinet tour
"{game_title}" original arcade gameplay
```

---

## Workflow for Autonomous Research Session

When starting a research session, Claude should:

1. **Setup Check**
   ```powershell
   .\scripts\Setup-Dependencies.ps1       # Download/copy MAME data files
   .\scripts\Get-MameGames.ps1            # Generate MAME inventory
   .\scripts\Get-TeknoparrotGames.ps1     # Generate TeknoParrot inventory
   ```

2. **Identify Research Targets**
   ```powershell
   # Load inventories
   $mame = Get-Content ./sources/cache/mame-games.json | ConvertFrom-Json
   $tp = Get-Content ./sources/cache/teknoparrot-games.json | ConvertFrom-Json

   # MAME: prioritize parent ROMs with wheel controls not yet in database
   $mamePending = $mame.games | Where-Object { -not $_.is_clone -and $_.input_types.Count -gt 0 -and -not $_.already_in_database }

   # TeknoParrot: games with wheel axis but no rotation data
   $tpPending = $tp.games | Where-Object { $_.has_wheel -and -not $_.in_database }
   ```

3. **Research Loop**
   - Group games by manufacturer/platform for batch research
   - For each game, perform web searches for rotation specs
   - Extract and validate rotation values against known manufacturer patterns
   - Document sources thoroughly with confidence levels
   - Update `data/wheel-db.json` directly (no intermediate merge step needed)

4. **Validate & Export**
   ```powershell
   .\scripts\Validate-Database.ps1        # Verify integrity
   .\scripts\Export-Formats.ps1           # Generate CSV/XML
   ```

5. **Commit Changes**
   - Stage updated data files
   - Write descriptive commit message listing games added
   - Note any games that couldn't be researched

---

## Known Wheel Rotation Values (Seed Data)

To bootstrap the database, here are some verified/commonly cited values:

| Game | Rotation | Type | Confidence | Notes |
|------|----------|------|------------|-------|
| Out Run | 270° | mechanical_stop | high | ±135° from center |
| Pole Position | -1 | optical_encoder | high | Infinite rotation spinner |
| Hard Drivin' | 1080° | potentiometer | high | 10-turn pot with 3-rotation mechanical stop |
| Daytona USA | 270° | mechanical_stop | high | Sega SPG-2002 assembly |
| Ridge Racer | 270° | mechanical_stop | high | Namco 270° potentiometer |
| Cruis'n USA | 270° | mechanical_stop | high | Midway SuzoHapp 270 |
| Virtua Racing | 270° | mechanical_stop | high | Sega Model 1 |
| Sega Rally | 270° | mechanical_stop | high | Sega Model 2 |
| F-Zero AX | 150° | mechanical_stop | medium | Triforce hardware, community-measured ~150° |

---

## Teknoparrot Integration

### Local Installation

A local TeknoParrot installation is available at:
```
R:\LaunchBox\Launchbox-Racing\LaunchBox\LaunchBox\Emulators\Coinops NEXT - TeknoParrot\emulators\TeknoParrot
```

### Data Sources in TeknoParrot

TeknoParrot has **two** relevant directories:

1. **`GameProfiles/*.xml`** (~487 files, ~98 with `<AnalogType>Wheel</AnalogType>`)
   - Defines axis mappings (which analog input is wheel, gas, brake)
   - Raw axis ranges (byte values like 0-255, not physical degrees)
   - Keyboard sensitivity sliders
   - Used to **identify which games have wheel controls** (inventory source)

2. **`Metadata/*.json`** (~485 files, **25 with `wheel_rotation` values**)
   - Contains `game_name`, `game_genre`, `platform`, `release_year`, `wheel_rotation`
   - **This is the primary source for rotation degree data**
   - All 25 games with rotation values are genre "Racing"
   - Two values observed: **270** (19 games) and **540** (6 games)

The remaining ~73 wheel-equipped games (from GameProfiles) that lack Metadata rotation values need research.

### Key Fields in GameProfiles XML

- `<EmulationProfile>` - Identifies the emulation backend (e.g., `SegaInitialD`, `Outrun2SPX`)
- `<EmulatorType>` - The emulation type (`TeknoParrot`, `Lindbergh`, `Dolphin`)
- Filename itself serves as the game identifier (e.g., `ID8.xml`, `WMMT6.xml`)
- `<AnalogType>Wheel</AnalogType>` in `<JoystickButtons>` indicates steering wheel input

### Metadata JSON Format

```json
{
  "game_name": "Initial D: Arcade Stage 8 Infinity",
  "game_genre": "Racing",
  "icon_name": "ID8.png",
  "platform": "SEGA RingEdge",
  "release_year": "2014",
  "wheel_rotation": "540"
}
```

### Known TeknoParrot Wheel Rotation Values (from Metadata)

| Profile | Game | Rotation | Platform | Year |
|---------|------|----------|----------|------|
| BattleGear4 | Battle Gear 4 | 540 | Taito Type X+ | 2005 |
| BattleGear4Tuned | Battle Gear 4 Tuned | 540 | Taito Type X+ | 2006 |
| ID4Exp / ID4Jap | Initial D: Arcade Stage 4 | 540 | SEGA Lindbergh Yellow | 2007 |
| ID5 | Initial D: Arcade Stage 5 | 540 | SEGA Lindbergh Yellow | 2009 |
| ID6 | Initial D: Arcade Stage 6 | 540 | SEGA RingEdge | 2011 |
| ID7 | Initial D: Arcade Stage 7 | 540 | SEGA RingEdge | 2012 |
| ID8 | Initial D: Arcade Stage 8 Infinity | 540 | SEGA RingEdge | 2014 |
| IDZ / IDZv2 (+TP variants) | Initial D: Arcade Stage Zero | 270 | SEGA Nu | 2017 |
| IDTA / IDTAS5 | Initial D: The Arcade | 270 | SEGA ALLS | 2021-2025 |
| or2spdlx | OutRun 2 SP SDX | 270 | SEGA Lindbergh Yellow | 2006 |
| SR3 | SEGA Rally 3 | 270 | SEGA Europa-R | 2008 |
| SWDC | Sega World Drivers Championship | 270 | SEGA ALLS | 2018 |
| WackyRaces | Wacky Races | 270 | Taito Type X2 | 2009 |
| WMMT3-6RR | Wangan Midnight Maximum Tune 3-6RR | 270 | Namco N2/ES3B | 2007-2021 |

Note: Initial D series switched from 540 to 270 starting with Arcade Stage Zero (2017).

### Script: Get-TeknoparrotGames.ps1

Parses the local TeknoParrot installation to extract all wheel-equipped games:
```powershell
param(
    [string]$TeknoParrotPath = "R:\LaunchBox\Launchbox-Racing\LaunchBox\LaunchBox\Emulators\Coinops NEXT - TeknoParrot\emulators\TeknoParrot",
    [string]$OutputPath = "./sources/cache/teknoparrot-games.json"
)

# For each XML in GameProfiles/:
#   1. Check if any JoystickButton has <AnalogType>Wheel</AnalogType>
#   2. Extract EmulationProfile, EmulatorType, filename
# For each matching game, load Metadata/{filename}.json:
#   3. Extract game_name, game_genre, platform, release_year, wheel_rotation
#   4. Output combined inventory list
```

### Notable Teknoparrot Racing Game Families

| Series | Profiles | Notes |
|--------|----------|-------|
| Initial D | ID4Exp, ID4Jap, ID5, ID6, ID7, ID8, IDZ, IDZv2, IDTA, IDTAS5 | Sega ring-edge hardware |
| Wangan Midnight MT | WMMT3, WMMT3DXP, WMMT5, WMMT5DX, WMMT5DXPlus, WMMT6, WMMT6R, WMMT6RR | Namco System ES series |
| Mario Kart GP | MarioKartGP, MarioKartGP2, MKDX (+variants) | Triforce/Namco BNA |
| Fast & Furious | FNF, FNFDrift, FNFSB, FNFSB2, FNFSC | Raw Thrills |
| Sega Rally | SR3, SRC, SRG | Sega Europa-R/Lindbergh |
| Daytona | Daytona3, Daytona3NSE | Sega RingEdge 2 |
| Battle Gear | batlgr3, batlgr3t, BattleGear4, BattleGear4Tuned | Taito Type X |
| OutRun 2 | or2spdlx | Sega Lindbergh |
| Cruis'n | CruisnBlast | Raw Thrills |

---

## Contributing

### Manual Contributions Welcome!

If you have verified information about a game's wheel rotation:

1. Fork the repository
2. Edit `data/wheel-db.json`
3. Add your entry with source documentation
4. Submit a pull request

### Entry Template

```json
"romname": {
  "title": "Game Title",
  "rotation_degrees": 270,
  "rotation_type": "mechanical_stop",
  "confidence": "verified",
  "sources": [
    {
      "type": "manual",
      "description": "Your source description",
      "url": "https://...",
      "date_accessed": "2025-01-31"
    }
  ],
  "notes": "Any additional context"
}
```

---

## License

This project should use a permissive license (MIT or CC0) to encourage:
- Integration into emulator frontends
- Community contributions
- Derivative works

---

## Contact & Community

- GitHub Issues: Bug reports and feature requests
- GitHub Discussions: General questions and research coordination
- Pull Requests: Data contributions and corrections

---

## Appendix: Common Manufacturer Patterns

### Sega
- **Super Scaler car games** (Out Run, etc.): 270° typical (mechanical_stop)
- **Super Scaler motorcycles** (Hang-On, Super Hang-On, Enduro Racer): 45° body-lean (potentiometer)
- **Model 1/2/3 car games**: 270° standard (SPG-2002 steering assembly, 5K ohm potentiometer)
- **Model 2/3 motorcycles** (Manx TT, Motor Raid, Harley-Davidson): 56° enhanced tilt (potentiometer)
- **Naomi/Chihiro**: 270° typical
- **Watercraft** (Wave Runner, Wave Runner GP): 60° handlebar (potentiometer)

### Namco
- **System 21/22**: 270° typical (Ridge Racer, Rave Racer)
- **System 246/256**: 270° typical

### Atari/Midway
- **Hard Drivin' series**: 1080° (10-turn potentiometer with 3-rotation mechanical stop) -- unique among arcade racers
- **Cruis'n series**: 270° typical (SuzoHapp Active 270 assembly)
- **San Francisco Rush**: 270° typical (SuzoHapp 270)
- **18 Wheeler (Sega on NAOMI)**: 360° -- notable exception to the 270° norm

### Sega Model 3 Specifics
- All Model 3 racers share the **SPG-2002 steering assembly** with 5K ohm potentiometer
- 500W servo motor force feedback (no spring centering)
- Games: Daytona USA 2, Scud Race, Sega Rally 2, Dirt Devils, Le Mans 24, Emergency Call Ambulance
- Supermodel emulator community confirms 270° gives 1:1 ratio with arcade

### Namco Potentiometer Standard
- Standard part: 1K ohm 270-degree potentiometer (VG75-07050-00, replaced by DE475-15417-00)
- Used across System 2, System 21, System 22, Super System 22, System 11, System 12
- Confirmed by Final Lap 3 operator manual (center wipe on pin A21, 0-5V range)

### Taito
- **Chase H.Q. series**: 270° typical (Chase H.Q., SCI, Super Chase, Chase H.Q. 2)
- **Battle Gear series**: 540° (confirmed by TeknoParrot metadata for BG3/BG4)

### Konami
- **GTI Club / Corso Italiano**: 270° typical
- **Winding Heat / Midnight Run**: 270° typical
- **Thrill Drive series**: 270° typical
- **Racing Jam series**: 270° typical

### Motorcycle/Watercraft Games
- **Sega body-lean motorcycles** (Hang-On, Super Hang-On, GP Rider): 45° (potentiometer measuring lean angle)
- **Sega Model 2/3 motorcycles** (Manx TT, Motor Raid, Harley-Davidson): 56° (enhanced tilt mechanism)
- **Namco motorcycles** (Suzuka 8 Hours, 500 GP, Motocross Go, Moto GP): 45° (potentiometer)
- **Watercraft** (Wave Runner, Aqua Jet, Jet Wave, Rapid River): 60° (handlebar potentiometer)
- **Specialty vehicles** (S.T.U.N. Runner, Star Rider, Vapor TRX, Power Sled): 45° (yoke/handlebar)
- Note: All motorcycle/watercraft games use `potentiometer` rotation_type, not `mechanical_stop`

### Early Games (Pre-1985)
- Often used optical encoders (infinite rotation)
- Examples: Pole Position, Turbo, Monaco GP
- These map better to spinner/mouse input than modern wheel
