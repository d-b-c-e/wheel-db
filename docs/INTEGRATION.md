# Integration Guide

How to consume the wheel-db data in your application, frontend, or emulator configuration tool.

## Quick Start

Download the latest release assets from GitHub:

```
https://github.com/d-b-c-e/wheel-db/releases/latest/download/wheel-db.json
https://github.com/d-b-c-e/wheel-db/releases/latest/download/mame-wheel-rotation.csv
https://github.com/d-b-c-e/wheel-db/releases/latest/download/steam-wheel-support.csv
https://github.com/d-b-c-e/wheel-db/releases/latest/download/wheel-db.csv
```

Choose the format that fits your use case:

| Format | Best For |
|--------|----------|
| **JSON** (`wheel-db.json`) | Full database with all metadata, sources, multi-platform mappings |
| **MAME CSV** (`mame-wheel-rotation.csv`) | Simple MAME ROM-to-rotation lookup (known values only) |
| **MAME XML** (`mame-wheel-rotation.xml`) | Same as MAME CSV in XML format |
| **Steam CSV** (`steam-wheel-support.csv`) | Steam games with wheel support, FFB, and rotation info |
| **Unified CSV** (`wheel-db.csv`) | All 674 games in one flat CSV across all platforms |

---

## Formats

### JSON (Primary Database)

The full database. Structure:

```json
{
  "version": "2.19.0",
  "generated": "2026-02-21T00:00:00Z",
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
      "pc": { "wheel_support": "native", "force_feedback": "native", "controller_support": "full" },
      "platforms": {
        "steam": { "appid": 244210, "tags": ["Racing", "Simulation"], "store_url": "https://store.steampowered.com/app/244210" }
      }
    }
  }
}
```

The `games` object is keyed by a unique slug (human-readable game ID). Each entry contains the fields described below. Arcade-only entries have `pc: null`; PC games have a `pc` sub-object with wheel support and force feedback info.

### CSV (MAME Lookup)

A flat file with one row per MAME parent ROM. Only games with known rotation values are included.

```csv
romname,title,manufacturer,year,rotation_degrees,rotation_type,confidence
"outrun","Out Run","Sega","1986",270,"mechanical_stop","high"
"polepos","Pole Position","Namco","1982",-1,"optical_encoder","high"
```

### XML (MAME Lookup)

Same data as CSV in XML attribute format:

```xml
<?xml version="1.0" encoding="utf-8"?>
<wheelRotationDb version="2.19.0" generated="2026-02-21T00:00:00Z" gameCount="294">
  <game romname="outrun" title="Out Run" manufacturer="Sega" year="1986"
        rotation="270" type="mechanical_stop" confidence="high" />
</wheelRotationDb>
```

---

## Field Reference

### rotation_degrees

The total physical rotation range of the original arcade cabinet's steering wheel, in degrees.

| Value | Meaning | Action |
|-------|---------|--------|
| `270` | 270 degrees total (±135° from center) | Set wheel rotation to 270° |
| `360` | Full turn | Set wheel rotation to 360° |
| `-1` | Infinite rotation (optical encoder / spinner) | Special handling needed -- see below |
| `null` | Unknown / not yet researched | Fall back to a default or prompt the user |

Common values in the database: 270 (most common), 360, 540, 45, 60, 90, 150, 1080.

**Infinite rotation (`-1`)**: These games used optical encoders or spinners with no physical stops. They measure relative movement, not absolute position. A modern racing wheel is a poor match -- these games work better with a mouse or spinner controller. If you must use a wheel, a high sensitivity setting with a small rotation range (e.g., 180°-270°) is a reasonable approximation, but the experience won't be authentic.

**Unknown (`null`)**: The game is in the database but its rotation hasn't been researched or is not applicable (anti-gravity racers, drag racing, motorcycle games where wheels aren't the intended input). Only 24 entries have null rotation. A safe default for unknown wheel games is 270°, as this was the most common arcade standard.

### rotation_type

How the original cabinet's steering mechanism works.

| Value | Description | Notes |
|-------|-------------|-------|
| `mechanical_stop` | Physical stops limit rotation | Most common. Wheel hits a hard stop at each end. |
| `optical_encoder` | Infinite rotation, relative positioning | No stops. Measures direction/speed of rotation. Usually paired with `rotation_degrees: -1`. |
| `potentiometer` | Absolute position sensor with physical limits | Similar to mechanical_stop for configuration purposes. May have slightly soft/imprecise endpoints. |
| `unknown` | Mechanism not determined | Treat as mechanical_stop for configuration. |

For wheel configuration purposes, `mechanical_stop`, `potentiometer`, and `unknown` can all be treated the same way -- set the wheel's rotation range to match `rotation_degrees`. Only `optical_encoder` requires special handling.

### confidence

How reliable the rotation value is.

| Level | Meaning | Recommended Use |
|-------|---------|-----------------|
| `verified` | Confirmed from official operator/service manual | Auto-apply without prompting |
| `high` | Multiple agreeing sources or manufacturer pattern | Auto-apply without prompting |
| `medium` | Single reliable source or strong inference | Auto-apply, optionally note the source |
| `low` | Single unverified source or weak inference | Apply as default but let user override easily |
| `unknown` | No rotation data (rotation_degrees is null) | Prompt user or use 270° default |

For most applications, `verified`, `high`, and `medium` are all reliable enough to auto-configure. `low` entries are still better than guessing.

### sources

An array of objects documenting where the rotation data came from. Each source has:

- `type`: One of `manual`, `forum`, `wiki`, `video`, `measurement`, `inference`, `other`
- `description`: Human-readable description
- `url`: Link to the source (may be `null` for offline sources like physical manuals)
- `date_accessed`: Date the source was consulted (may be `null`)

You generally don't need to process sources programmatically -- they exist for transparency and to help contributors verify/update entries.

### platforms

A map of platform keys to platform-specific identifiers. Possible keys:

| Key | Identifier Field | Description |
|-----|-----------------|-------------|
| `mame` | `romname` | MAME parent ROM set name. Also has `clones_inherit` (boolean). |
| `teknoparrot` | `profile`/`profiles` | TeknoParrot GameProfile filename(s) (without `.xml`) |
| `steam` | `appid` | Steam app ID. Also: `tags`, `store_url`, `pcgamingwiki_url`, `popularity_rank`, `owners_estimate` |
| `dolphin` | `game_id` | Triforce/GameCube game ID |
| `supermodel` | `romname` | Supermodel ROM identifier |
| `m2emulator` | `romname` | Model 2 Emulator ROM identifier |
| `flycast` | `romname` | Flycast ROM identifier |
| `pcsx2` | `serial` | PS2 disc serial number (e.g., SCUS-97328) |

A game may have entries under multiple platforms. For example, Crazy Taxi has `mame` and `steam` mappings.

### pc

PC-specific metadata, present only for games playable on PC. `null` for arcade-only games.

| Field | Values | Description |
|-------|--------|-------------|
| `wheel_support` | `native`, `partial`, `none`, `unknown` | Quality of steering wheel support |
| `force_feedback` | `native`, `partial`, `none`, `unknown` | Force feedback support level |
| `controller_support` | `full`, `partial`, `none`, `null` | Generic controller support flag |

---

## Looking Up a Game

### By MAME ROM Name

To find the rotation for a MAME ROM:

1. **Using CSV/XML**: Look up the `romname` column/attribute directly. These only contain parent ROMs with known values.

2. **Using JSON**: Iterate `games` and check `platforms.mame.romname`:

```python
# Python example
import json

with open("wheel-db.json") as f:
    db = json.load(f)

# Build a romname -> game lookup
mame_lookup = {}
for game_id, game in db["games"].items():
    mame = game.get("platforms", {}).get("mame")
    if mame:
        # Handle both singular "romname" and "romnames" array
        if "romnames" in mame:
            for rn in mame["romnames"]:
                mame_lookup[rn] = game
        else:
            mame_lookup[mame["romname"]] = game

# Look up a game
game = mame_lookup.get("outrun")
if game and game["rotation_degrees"] is not None:
    print(f"Set wheel to {game['rotation_degrees']}°")
```

```csharp
// C# example using System.Text.Json
var json = File.ReadAllText("wheel-db.json");
var db = JsonDocument.Parse(json);
var games = db.RootElement.GetProperty("games");

foreach (var game in games.EnumerateObject())
{
    if (game.Value.TryGetProperty("platforms", out var platforms) &&
        platforms.TryGetProperty("mame", out var mame))
    {
        // Handle both singular "romname" and "romnames" array
        var romnames = new List<string>();
        if (mame.TryGetProperty("romnames", out var rns))
            foreach (var rn in rns.EnumerateArray())
                romnames.Add(rn.GetString()!);
        else
            romnames.Add(mame.GetProperty("romname").GetString()!);

        if (romnames.Contains("outrun"))
        {
            var rotation = game.Value.GetProperty("rotation_degrees");
            if (rotation.ValueKind != JsonValueKind.Null)
                Console.WriteLine($"Set wheel to {rotation.GetInt32()}°");
        }
    }
}
```

### Handling MAME Clones

The CSV/XML exports only list parent ROMs. MAME clones (e.g., `outrunj`, `outrundx`) share their parent's wheel hardware.

If you need clone resolution, query MAME for the parent ROM:
```bash
mame -listclones | grep "your_clone_rom"
```

Or parse MAME's `-listxml` output where `<machine cloneof="parent">` indicates the parent.

When `clones_inherit` is `true` (the default and most common case), apply the parent's rotation to all clones.

### By TeknoParrot Profile

```python
tp_lookup = {}
for game_id, game in db["games"].items():
    tp = game.get("platforms", {}).get("teknoparrot")
    if tp:
        tp_lookup[tp["profile"]] = game

game = tp_lookup.get("or2spdlx")  # OutRun 2 SP SDX
```

---

## Applying Wheel Rotation

Once you have a `rotation_degrees` value, how to use it depends on your wheel and software:

### USB Wheel Configuration

Most modern racing wheels allow setting rotation range via their driver software:

- **Logitech (G27, G29, G920, G923)**: Set in Logitech G HUB or LGS. Range: 40°-900°.
- **Thrustmaster (T300, T500, TX)**: Set in Thrustmaster Control Panel. Range: 40°-1080°.
- **Fanatec**: Set in Fanatec Control Panel or on-wheel display. Range varies by model.

Set the wheel's rotation to match the game's `rotation_degrees` value before launching.

### Emulator Analog Sensitivity

If you can't change the physical wheel rotation (e.g., it's shared across games in a frontend), you can adjust the emulator's analog sensitivity instead:

**Sensitivity formula**: `sensitivity = (wheel_physical_degrees / game_expected_degrees) * base_sensitivity`

For example, if your wheel is locked at 900° and the game expects 270°:
`sensitivity = (900 / 270) * 100 = 333%`

This is less ideal than matching the physical rotation (you lose resolution in the center), but it works.

### MAME Specifics

MAME stores analog sensitivity in per-game `.cfg` files (not in ctrlr files -- ctrlr files cannot store analog settings). The relevant settings in MAME's UI are:

- **Paddle Sensitivity** (or Dial/AD Stick depending on the game's input type)
- Found in: Tab Menu → Analog Controls → Sensitivity

MAME's default sensitivity is 50. Adjusting this value changes how much of the physical wheel range maps to the game's full steering range.

---

## Recommended Defaults

When a game is not in the database or has `null` rotation:

| Scenario | Recommended Default |
|----------|-------------------|
| Unknown driving/racing game | 270° (most common arcade standard) |
| Motorcycle/bike game | 45°-60° |
| Truck/bus game | 360°-540° |
| Optical encoder / spinner game | 270° with high sensitivity (compromise) |

---

## Schema Validation

The JSON schema is available at `data/schema/wheel-db.schema.json` in the repository. Use it to validate entries or to understand the exact type constraints for each field.

Key constraints:
- `rotation_degrees`: integer 45-1080, or `-1` (infinite), or `null` (unknown)
- `rotation_type`: enum `mechanical_stop | optical_encoder | potentiometer | unknown | null` (null for PC-only games)
- `confidence`: enum `verified | high | medium | low | unknown`
- `sources`: array with at least 1 entry (each has `type` and `description` required)
- `platforms`: object with platform-specific sub-entries (mame, steam, teknoparrot, etc.)
- `pc`: object with `wheel_support` and `force_feedback` enums, or `null` for arcade-only

---

## Versioning

The database uses semantic versioning (`major.minor.patch`):
- **Major**: Breaking schema changes
- **Minor**: New games added or rotation values updated
- **Patch**: Corrections to existing entries, metadata fixes

The `version` field in the JSON and the GitHub release tag (e.g., `v1.4.0`) always match.

---

## Example: Building a Lookup Cache

For applications that need fast lookups across multiple platforms:

```python
import json

with open("wheel-db.json") as f:
    db = json.load(f)

# Build multi-emulator lookup: { (platform, id): game_entry }
lookup = {}
for game_id, game in db["games"].items():
    for platform, info in game.get("platforms", {}).items():
        if platform == "mame":
            # Handle both singular "romname" and "romnames" array
            if "romnames" in info:
                for rn in info["romnames"]:
                    lookup[("mame", rn)] = game
            else:
                lookup[("mame", info["romname"])] = game
        elif platform == "teknoparrot":
            if "profiles" in info:
                for p in info["profiles"]:
                    lookup[("teknoparrot", p)] = game
            else:
                lookup[("teknoparrot", info["profile"])] = game
        elif platform == "dolphin":
            lookup[("dolphin", info["game_id"])] = game
        elif platform == "pcsx2":
            lookup[("pcsx2", info["serial"])] = game
        else:
            lookup[(platform, info.get("romname", ""))] = game

# Usage
game = lookup.get(("mame", "daytona"))
if game:
    rotation = game["rotation_degrees"]  # 270, -1, or None
    confidence = game["confidence"]       # "verified", "high", etc.
```
