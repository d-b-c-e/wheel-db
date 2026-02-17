# Steam API Research for Racing Games Database

**Research Date:** 2026-02-14
**Objective:** Identify programmatic approaches to build a database of the top 500 racing/driving games on Steam with steering wheel support metadata.

---

## Executive Summary

Building a comprehensive database of Steam racing games with wheel support requires combining multiple data sources:

1. **Steam Store API** (`appdetails`) - For game details and controller support flags
2. **SteamSpy API** - For popularity metrics (owners, players, rankings)
3. **Steam Tags** - For filtering racing/driving games
4. **PCGamingWiki** - For community-verified wheel support (manual/curated)
5. **Existing datasets** - Kaggle/GitHub Steam datasets as starting points

**Key Challenge:** Steam's API exposes generic "controller support" (full/partial) but does NOT differentiate steering wheel support from gamepad support. Wheel-specific metadata must come from community sources or manual research.

---

## 1. Steam Store API

### Endpoints

#### A. Get All Games List
**Deprecated:** `ISteamApps/GetAppList/v2/`
- No longer scales to Steam's catalog size
- Recommendation: Use `IStoreService/GetAppList` instead

**Endpoint:**
```
https://api.steampowered.com/ISteamApps/GetAppList/v0001/
```

**Returns:** List of all Steam app IDs and names (basic inventory)

#### B. Get Game Details (Primary Data Source)
**Endpoint:**
```
https://store.steampowered.com/api/appdetails?appids={appid}
```

**Multiple apps:**
```
https://store.steampowered.com/api/appdetails?appids={appid1},{appid2},{appid3}
```

**Available Fields:**
- `name` - Game title
- `type` - Game, DLC, etc.
- `is_free` - Free-to-play status
- `categories` - Array of category IDs (includes controller support)
- `genres` - Array of genre objects
- `release_date` - Release information
- `controller_support` - `"full"` or `"partial"` (string field)
- `platforms` - Windows, Mac, Linux support
- `price_overview` - Pricing data
- `developers` - Developer list
- `publishers` - Publisher list
- `metacritic` - Review scores

**Rate Limits:** ~200 requests per 5 minutes. Cache aggressively.

**Controller Support Caveat:**
The `controller_support` field only indicates generic gamepad support ("Full Controller Support" / "Partial Controller Support"). It does NOT distinguish steering wheels from Xbox/PlayStation controllers. This field tells you the game *might* support wheels, but not definitively.

#### C. Search/Browse Games by Tag
**Endpoint:**
```
https://store.steampowered.com/search/results/?json=1&tags={tag_id}
```

**Example (Racing tag):**
```
https://store.steampowered.com/search/results/?json=1&tags=699
```

**Parameters:**
- `json=1` - Return JSON instead of HTML
- `tags={id}` - Tag ID (can use multiple comma-separated)
- `category1={id}` - Category filter
- `sort_by=` - Sort order (e.g., `Reviews_DESC`, `Released_DESC`)
- `os=` - Platform filter

**Returns:** Search results with app IDs, names, thumbnails, prices. Limited pagination.

---

## 2. Steam Tags for Racing/Driving Games

### Relevant Tag IDs

| Tag ID | Tag Name | Notes |
|--------|----------|-------|
| **699** | **Racing** | Primary racing game tag (~1,000+ games) |
| **1644** | **Driving** | Broader driving/vehicle simulation |
| **1100687** | **Automobile Sim** | Serious car simulators (smaller subset) |
| **791774** | **Automobile Sim** | (Alternative/duplicate?) |
| **19** | **Simulation** | Generic simulation tag |
| **4182** | **Singleplayer** | Useful for filtering |
| **3859** | **Multiplayer** | Useful for filtering |
| **3798** | **Free to Play** | May want to exclude |

**Source:** [SteamDB Tag Browser](https://steamdb.info/tags/)

**Strategy:**
Query all games with tag ID 699 (Racing) OR 1644 (Driving), then filter/deduplicate.

---

## 3. SteamSpy API (Popularity & Rankings)

### Overview
SteamSpy provides player counts, ownership estimates, and rankings. Updated daily.

**Base URL:** `https://steamspy.com/api.php`

### Request Types

#### A. Top Games (Top 100 by various metrics)
```
https://steamspy.com/api.php?request=top100in2weeks
https://steamspy.com/api.php?request=top100forever
https://steamspy.com/api.php?request=top100owned
```

**Returns:** Top 100 games with full stats (owners, playtime, CCU, tags, etc.)

#### B. Games by Tag
```
https://steamspy.com/api.php?request=tag&tag=Racing
```

**Returns:** All games tagged "Racing" with stats.

**Response Fields:**
- `appid` - Steam app ID
- `name` - Game name
- `developer` - Developer
- `publisher` - Publisher
- `score_rank` - Quality score ranking
- `owners` - Ownership range (e.g., "20,000 - 50,000")
- `average_forever` - Average playtime (minutes)
- `average_2weeks` - Recent average playtime
- `median_forever` - Median playtime
- `ccu` - Peak concurrent users
- `price` - Price (cents)
- `discount` - Current discount percentage
- `tags` - Object with tag names and vote counts

#### C. Games by Genre
```
https://steamspy.com/api.php?request=genre&genre=Racing
```

**Note:** SteamSpy distinguishes "tags" (user-applied) from "genres" (developer-set). Both are useful.

#### D. Individual Game Details
```
https://steamspy.com/api.php?request=appdetails&appid={appid}
```

**Returns:** Full stats for a single game.

### Rate Limits
- **Standard requests:** 1 request per second
- **Bulk requests (`all`):** 1 request per 60 seconds
- Data refreshed once per day (no need to poll more than daily)

### Use Case
Use SteamSpy to:
1. Get initial list of racing games by tag/genre
2. Rank games by owners/players to prioritize top 500
3. Enrich Steam Store data with popularity metrics

---

## 4. SteamDB (Community Database)

### Overview
SteamDB is a **website**, not a public API. It scrapes and indexes Steam data.

**Features:**
- Tag-based charts (e.g., [Most Played Racing Games](https://steamdb.info/charts/?tagid=699))
- Price history
- Player count charts
- App update history

**Programmatic Access:**
No official API. Would require scraping HTML (not recommended due to rate limits and ToS concerns).

**Alternative:** Use SteamDB manually to validate/cross-reference data.

---

## 5. PCGamingWiki (Steering Wheel Support)

### Overview
PCGamingWiki is a MediaWiki-based wiki with detailed game configuration info, including input device support.

**API:** MediaWiki API + Cargo extension (structured data tables)

### Cargo Tables
PCGamingWiki uses the Cargo extension to store structured game data.

**Relevant Tables:**
- `Infobox_game` - Main game metadata
- `Input` - Controller/input device support

**API Endpoint:**
```
https://www.pcgamingwiki.com/w/api.php?action=cargoquery
```

**Example Query (pseudocode):**
```
action=cargoquery
&tables=Infobox_game,Input
&fields=Infobox_game.Steam_AppID,Infobox_game.Title,Input.Racing_wheel
&where=Input.Racing_wheel='true'
&format=json
```

**Documentation:** [PCGamingWiki API](https://www.pcgamingwiki.com/wiki/PCGamingWiki:API)

### Manual Lists
PCGamingWiki maintains curated lists:
- [List of games that support Logitech racing wheels](https://www.pcgamingwiki.com/wiki/List_of_games_that_support_Logitech_racing_wheels)
- [Category: Steering wheels](https://www.pcgamingwiki.com/wiki/Category:Steering_wheels) (51 wheel hardware pages)

**Use Case:**
Query PCGamingWiki for games with confirmed wheel support, then cross-reference with Steam app IDs.

**Limitation:**
Coverage is incomplete (community-maintained). Many games lack wheel support info.

---

## 6. IGDB (Internet Game Database)

### Overview
IGDB is a comprehensive game database API (now owned by Twitch). Supports advanced queries.

**Base URL:** `https://api.igdb.com/v4/`

**Authentication:** Requires Twitch Client ID and OAuth token (free for non-commercial use).

### Endpoints

#### Games
```
POST https://api.igdb.com/v4/games
```

**Body (Apicalypse query language):**
```
fields name, genres.name, platforms.name, release_dates.date, rating;
where genres.name = "Racing" & platforms.name = "PC (Microsoft Windows)";
sort rating desc;
limit 500;
```

**Features:**
- Rich metadata (genres, themes, game modes, etc.)
- Cross-platform support (not Steam-specific)
- Rating/popularity scores

**Limitations:**
- Does NOT include Steam app IDs by default (need to query external links)
- Does NOT track controller/wheel support metadata
- Focused on general game data, not input device compatibility

**Use Case:**
Use IGDB to get a canonical list of racing games, then match to Steam via title or external website links.

---

## 7. Existing Datasets (Kaggle/GitHub)

### Recommended Datasets

#### A. Steam Dataset 2025 (GitHub)
**Repo:** [vintagedon/steam-dataset-2025](https://github.com/vintagedon/steam-dataset-2025)
**Description:** Modernized Steam catalog built from current APIs (2025). Includes vector embeddings and graph analysis.
**Contents:** Complete catalog, metadata from Steam Store API, tags, categories.

#### B. Steam Games Dataset (Kaggle)
**Link:** [Steam Games Dataset (110k+ games)](https://www.kaggle.com/datasets/fronkongames/steam-games-dataset)
**Contents:** Game metadata, pricing, tags, categories, reviews.

#### C. Steam Games Dataset 2021-2025 (Kaggle)
**Link:** [65k+ games](https://www.kaggle.com/datasets/jypenpen54534/steam-games-dataset-2021-2025-65k)
**Contents:** Historical Steam data with trends.

**Use Case:**
Download an existing dataset as a starting point, then filter for racing games by tag/genre. Enriched with SteamSpy popularity data and manual wheel support research.

---

## Recommended Workflow

### Step 1: Enumerate Racing Games
**Option A: Steam Store Search API**
```bash
curl "https://store.steampowered.com/search/results/?json=1&tags=699&category1=998" > racing_games.json
# category1=998 = Full Controller Support
```

**Option B: SteamSpy Tag Request**
```bash
curl "https://steamspy.com/api.php?request=tag&tag=Racing" > steamspy_racing.json
```

**Output:** List of app IDs for racing games (~1,000-2,000 games).

### Step 2: Enrich with Game Details
For each app ID, fetch details:
```bash
curl "https://store.steampowered.com/api/appdetails?appids=244210" > game_244210.json
# F1 2013 example
```

**Extract:**
- Title, developer, publisher
- `controller_support` field (full/partial)
- Tags, categories, genres
- Release date, price

**Rate Limit:** Space requests 300ms apart (200/5min = ~1 per 1.5 seconds, add margin).

### Step 3: Add Popularity Rankings
Use SteamSpy data to rank games by:
- Owners (total sales estimate)
- Average playtime (engagement)
- Peak CCU (active playerbase)

```bash
# Get all racing games from SteamSpy
curl "https://steamspy.com/api.php?request=tag&tag=Racing" > steamspy_data.json

# Extract owners, sort descending, take top 500
```

### Step 4: Manual Wheel Support Research
For top 500 games, research wheel support:

**Sources (in priority order):**
1. **PCGamingWiki** - Query Cargo API or check manual lists
2. **Steam Community Hubs** - Search discussions for "[game] steering wheel"
3. **Reddit** - Search r/simracing, r/racing for "[game] wheel support"
4. **YouTube** - Search "[game] steering wheel gameplay"
5. **Developer forums/Discord** - Official confirmation

**Classification:**
- **Verified** - Official documentation or widespread confirmation
- **Confirmed** - Multiple reliable community reports
- **Likely** - Full controller support + racing genre, but unverified
- **Partial** - Works but issues (poor FFB, limited rotation, etc.)
- **None** - Gamepad/keyboard only

### Step 5: Structure Database
```json
{
  "version": "1.0.0",
  "generated": "2026-02-14T00:00:00Z",
  "source": "Steam Store API + SteamSpy + PCGamingWiki + Manual Research",
  "games": [
    {
      "steam_appid": 244210,
      "title": "F1 2013",
      "developer": "Codemasters Birmingham",
      "publisher": "Codemasters",
      "release_date": "2013-10-04",
      "genres": ["Racing", "Sports", "Simulation"],
      "controller_support": "full",
      "wheel_support": "verified",
      "wheel_notes": "Supports all major wheels with FFB. Confirmed via PCGamingWiki and Steam community.",
      "popularity_rank": 42,
      "owners": "1,000,000 - 2,000,000",
      "average_playtime_hours": 12.5,
      "metacritic_score": 82,
      "sources": [
        {
          "type": "api",
          "source": "Steam Store API",
          "date": "2026-02-14"
        },
        {
          "type": "community",
          "source": "PCGamingWiki",
          "url": "https://www.pcgamingwiki.com/wiki/F1_2013",
          "date": "2026-02-14"
        }
      ]
    }
  ]
}
```

---

## API Rate Limits Summary

| API | Rate Limit | Caching Strategy |
|-----|------------|------------------|
| Steam Store API | ~200 requests / 5 minutes | Cache all responses, update weekly |
| SteamSpy | 1 req/sec (standard)<br>1 req/60sec (bulk) | Daily update sufficient |
| PCGamingWiki | MediaWiki standard (~100 req/min) | Cache heavily, update monthly |
| IGDB | Varies (check docs) | Cache responses |

---

## Limitations & Challenges

### 1. Wheel Support Not in APIs
- **Problem:** No API directly exposes "steering wheel support"
- **Solution:** Manual research + community data (PCGamingWiki, Reddit, forums)

### 2. "Controller Support" is Ambiguous
- **Problem:** Steam's `controller_support: "full"` includes gamepads AND wheels
- **Solution:** Assume racing games with full controller support *likely* support wheels, verify manually

### 3. Partial Support Gray Area
- **Problem:** Many games "work" with wheels but have poor implementation (no FFB, limited rotation)
- **Solution:** Classify support levels (Verified, Confirmed, Partial, None) with notes

### 4. Rate Limits
- **Problem:** Fetching 2,000+ game details takes hours
- **Solution:**
  - Download existing datasets as baseline
  - Prioritize top 500 by popularity
  - Use batch requests where possible

### 5. Data Freshness
- **Problem:** New games release daily, support improves via patches
- **Solution:**
  - Timestamp all data
  - Re-run scraper monthly
  - Accept community contributions via GitHub

---

## Recommended Tooling

### PowerShell Script Structure
```powershell
# Get-SteamRacingGames.ps1

# Step 1: Enumerate racing games (SteamSpy tag request)
$racingGames = Invoke-RestMethod "https://steamspy.com/api.php?request=tag&tag=Racing"

# Step 2: Rank by owners, take top 500
$top500 = $racingGames.PSObject.Properties.Value |
    Sort-Object {[int]$_.ccu} -Descending |
    Select-Object -First 500

# Step 3: Enrich with Steam Store details
foreach ($game in $top500) {
    Start-Sleep -Milliseconds 300  # Rate limit
    $details = Invoke-RestMethod "https://store.steampowered.com/api/appdetails?appids=$($game.appid)"
    # Process and store...
}

# Step 4: Query PCGamingWiki for wheel support
# (Use MediaWiki API cargoquery)

# Step 5: Output JSON database
```

### Python Alternative
```python
import requests
import time
import json

# SteamSpy racing games
spy_data = requests.get("https://steamspy.com/api.php?request=tag&tag=Racing").json()

# Rank and filter
games = sorted(spy_data.values(), key=lambda x: x.get('ccu', 0), reverse=True)[:500]

# Fetch Steam details
for game in games:
    time.sleep(0.3)
    appid = game['appid']
    details = requests.get(f"https://store.steampowered.com/api/appdetails?appids={appid}").json()
    # Process...

# Save to JSON
with open('steam_racing_games.json', 'w') as f:
    json.dump(games, f, indent=2)
```

---

## Additional Resources

### Communities for Wheel Support Research
- **r/simracing** - Reddit community for racing sim enthusiasts
- **SimRacing.GP** - Forums with hardware compatibility discussions
- **Sim Racing Garage** - YouTube channel with wheel reviews/tests
- **Inside Sim Racing** - Podcast/website covering sim racing gear

### Manufacturers' Game Support Lists
- **Logitech G Hub** - Lists supported games for G920/G29/G923
- **Thrustmaster** - Game compatibility database
- **Fanatec** - Forum discussions on game support

### Steam Community Resources
- **Steam Community Hubs** - Per-game discussions often mention wheel support
- **Steam Guides** - User-created wheel setup guides
- **Steam Curators** - [Best of driving games](https://store.steampowered.com/curator/9174759-Best-of-driving-games/)

---

## Next Steps

1. **Set up API access**
   - Test Steam Store API with sample racing games
   - Verify SteamSpy response format
   - Register for IGDB API key (if needed)

2. **Download baseline dataset**
   - Use Kaggle Steam dataset as starting inventory
   - Filter to racing/driving genres

3. **Develop PowerShell scraper**
   - Enumerate racing games via SteamSpy
   - Fetch details from Steam Store API
   - Respect rate limits (300ms delays)

4. **Manual research phase**
   - Top 100: Full manual verification (PCGamingWiki + forums)
   - Top 500: Community sources + Steam reviews
   - Remaining: Infer from controller support flag

5. **Database structure**
   - JSON master file (like `wheel-rotation.json`)
   - CSV export for easy viewing
   - Version control in Git

6. **Community integration**
   - GitHub repo with data + scraper scripts
   - Accept pull requests for corrections
   - Link to PCGamingWiki for ongoing updates

---

## Conclusion

**Most Promising Approach:**

1. **SteamSpy Tag API** → Get all racing games with popularity stats
2. **Steam Store API** → Enrich with details (`controller_support` flag)
3. **Rank by owners/playtime** → Prioritize top 500
4. **PCGamingWiki Cargo API** → Cross-reference for wheel support
5. **Manual research** → Verify/fill gaps for top games
6. **Community contributions** → Ongoing updates via GitHub

**Timeline Estimate:**
- API scraping: 2-4 hours (rate-limited)
- Manual verification (top 100): 8-12 hours
- Community research (top 500): 20-30 hours
- Total: ~40 hours for initial database

**Confidence:**
- **High** - Top 100 games (active communities, well-documented)
- **Medium** - Top 500 games (less community info, more inference)
- **Low** - Remaining games (rely on controller support flag + genre)

This approach balances automation (APIs for initial data) with manual curation (wheel support verification), similar to the arcade database workflow but leveraging Steam's richer metadata ecosystem.
