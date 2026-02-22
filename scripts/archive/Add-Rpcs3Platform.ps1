Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$dbPath = "$PSScriptRoot\..\data\wheel-db.json"
$db = Get-Content -Raw $dbPath | ConvertFrom-Json

# Update version and timestamp
$db.version = "2.23.0"
$db.generated = "2026-02-21T00:00:00Z"

$today = "2026-02-21"

# ============================================================
# PART 1: Add rpcs3 platform to existing entries
# ============================================================
Write-Host "=== Adding rpcs3 to existing entries ===" -ForegroundColor Cyan

$rpcs3Additions = @{
    "need_for_speed_carbon"    = "BLUS-30016"
    "need_for_speed_hot_pursuit" = "BLUS-30566"
    "need_for_speed_most_wanted" = "BLUS-31010"
    "need_for_speed_rivals"    = "BLUS-31201"
    "need_for_speed_shift"     = "BLUS-30391"
    "shift_2_unleashed"        = "BLUS-30580"
    "need_for_speed_undercover" = "BLUS-30248"
    "grid_autosport"           = "BLUS-31452"
    "f1_2012"                  = "BLUS-31014"
    "f1_2014"                  = "BLUS-31471"
    "burnout_paradise_the_ultimate_box" = "BLUS-30061"
    "sonic_allstars_racing"    = "BLUS-30342"
    "sonic_and_allstars_racing_transformed" = "BLUS-30839"
    "splitsecond"              = "BLUS-30300"
    "test_drive_ferrari_racing_legends" = "BLUS-30842"
    "ridge_racer_unbounded"    = "BLUS-30877"
    "wrc_4_fia_world_rally_championship" = "BLUS-31509"
    "wrc_5_fia_world_rally_championship" = "BLES-02165"
    "nfs_prostreet_ps2"        = "BLUS-30066"
}

$addedCount = 0
foreach ($key in $rpcs3Additions.Keys) {
    $game = $db.games.PSObject.Properties[$key]
    if ($game) {
        $serial = $rpcs3Additions[$key]
        $rpcs3Obj = [PSCustomObject]@{ serial = $serial }
        $game.Value.platforms | Add-Member -NotePropertyName "rpcs3" -NotePropertyValue $rpcs3Obj -Force
        $addedCount++
        Write-Host "  Added rpcs3 ($serial) to: $key"
    } else {
        Write-Host "  WARNING: Entry '$key' not found!" -ForegroundColor Yellow
    }
}
Write-Host "Added rpcs3 to $addedCount existing entries`n"

# ============================================================
# PART 2: Add new PS3 game entries
# ============================================================
Write-Host "=== Adding new PS3 entries ===" -ForegroundColor Cyan

function New-Src {
    param([string]$Type, [string]$Desc, [string]$Url = $null)
    return [PSCustomObject]@{
        type = $Type
        description = $Desc
        url = $Url
        date_accessed = $today
    }
}

$newEntries = [ordered]@{}

# --- Gran Turismo Series ---
$newEntries["gran_turismo_5_prologue"] = [PSCustomObject]@{
    title = "Gran Turismo 5 Prologue"
    manufacturer = $null
    developer = "Polyphony Digital"
    publisher = "Sony Computer Entertainment"
    year = "2007"
    rotation_degrees = 900
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "developer" "Polyphony Digital GT series. Full Logitech G25/G27 support with 900-degree rotation, H-pattern shifter, and clutch."),
        (New-Src "wiki" "RPCS3 Wiki confirms Playable status. Full wheel support via emulated G27." "https://wiki.rpcs3.net/index.php?title=Gran_Turismo_5_Prologue")
    )
    notes = "PS3-exclusive GT prequel. Full 900-degree wheel support with FFB. Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BCUS-98158" } }
}

$newEntries["gran_turismo_5"] = [PSCustomObject]@{
    title = "Gran Turismo 5"
    manufacturer = $null
    developer = "Polyphony Digital"
    publisher = "Sony Computer Entertainment"
    year = "2010"
    rotation_degrees = 900
    rotation_type = $null
    confidence = "verified"
    sources = @(
        (New-Src "developer" "Polyphony Digital GT5. Full Logitech G25/G27/DFGT support with 900-degree rotation, H-pattern shifter, clutch, and shift LEDs."),
        (New-Src "wiki" "RPCS3 Wiki confirms Playable status with wheel support via emulated G27." "https://wiki.rpcs3.net/index.php?title=Gran_Turismo_5"),
        (New-Src "forum" "GTPlanet community extensively documents GT5 wheel compatibility. Gold standard for PS3 sim racing." "https://www.gtplanet.net/forum/")
    )
    notes = "PS3-exclusive flagship sim racer. Gold standard for PS3 wheel gaming. Full 900-degree support, H-shifter, clutch, shift LEDs. Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BCUS-98114" } }
}

$newEntries["gran_turismo_6"] = [PSCustomObject]@{
    title = "Gran Turismo 6"
    manufacturer = $null
    developer = "Polyphony Digital"
    publisher = "Sony Computer Entertainment"
    year = "2013"
    rotation_degrees = 900
    rotation_type = $null
    confidence = "verified"
    sources = @(
        (New-Src "developer" "Polyphony Digital GT6. Full Logitech/Thrustmaster/Fanatec wheel support with 900-degree rotation."),
        (New-Src "wiki" "RPCS3 Wiki lists as Ingame status. Wheel support works but game has stability issues beyond v1.05." "https://wiki.rpcs3.net/index.php?title=Gran_Turismo_6"),
        (New-Src "forum" "GTPlanet community confirms extensive wheel and FFB support." "https://www.gtplanet.net/forum/")
    )
    notes = "PS3-exclusive. Last GT title on PS3. Full 900-degree wheel support. RPCS3 status: Ingame (stability issues on newer patches)."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BCUS-98296" } }
}

# --- Ridge Racer 7 ---
$newEntries["ridge_racer_7"] = [PSCustomObject]@{
    title = "Ridge Racer 7"
    manufacturer = $null
    developer = "Namco Bandai"
    publisher = "Namco Bandai"
    year = "2006"
    rotation_degrees = 270
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "reference" "Logitech official PS3 compatibility list confirms 200-degree mode and FFB support for G25/G27." "https://support.logi.com/hc/en-150/articles/360023375653"),
        (New-Src "inference" "Ridge Racer series consistently uses 270-degree arcade-style steering. PS3 launch title.")
    )
    notes = "PS3-exclusive launch title. Arcade racer with partial wheel support. RPCS3 status: Ingame."
    pc = [PSCustomObject]@{ wheel_support = "partial"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30001" } }
}

# --- Codemasters DiRT Series ---
$newEntries["dirt"] = [PSCustomObject]@{
    title = "DiRT"
    manufacturer = $null
    developer = "Codemasters"
    publisher = "Codemasters"
    year = "2007"
    rotation_degrees = 540
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "reference" "Logitech official PS3 compatibility list confirms 200-degree mode and FFB for Colin McRae: DiRT." "https://support.logi.com/hc/en-150/articles/360023375653"),
        (New-Src "developer" "Codemasters rally series. Native wheel support across the DiRT franchise.")
    )
    notes = "Originally titled Colin McRae: DiRT. Native wheel and FFB. Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30064" } }
}

$newEntries["dirt_2"] = [PSCustomObject]@{
    title = "DiRT 2"
    manufacturer = $null
    developer = "Codemasters"
    publisher = "Codemasters"
    year = "2009"
    rotation_degrees = 540
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "reference" "Logitech official compatibility list confirms full 900-degree mode, H-pattern shifter, and FFB support." "https://support.logi.com/hc/en-150/articles/360023375653"),
        (New-Src "developer" "Codemasters DiRT series. Full wheel support with 540-degree recommended for rally.")
    )
    notes = "Rally racer with full wheel support. 900-degree capable but 540 recommended for rally. RPCS3: Playable but may crash after extended play."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30313" } }
}

$newEntries["dirt_3"] = [PSCustomObject]@{
    title = "DiRT 3"
    manufacturer = $null
    developer = "Codemasters"
    publisher = "Codemasters"
    year = "2011"
    rotation_degrees = 540
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "developer" "Codemasters DiRT series. Native wheel and FFB support. 540-degree recommended for rally."),
        (New-Src "wiki" "RPCS3 Wiki confirms Playable status." "https://wiki.rpcs3.net/index.php?title=DiRT_3")
    )
    notes = "Rally racer with native wheel and FFB. 540 degrees recommended. Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30724" } }
}

$newEntries["dirt_showdown"] = [PSCustomObject]@{
    title = "DiRT Showdown"
    manufacturer = $null
    developer = "Codemasters"
    publisher = "Codemasters"
    year = "2012"
    rotation_degrees = 540
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "developer" "Codemasters DiRT series. Native wheel and FFB. Demolition derby focus but supports standard wheel play."),
        (New-Src "wiki" "RPCS3 Wiki confirms Playable status." "https://wiki.rpcs3.net/index.php?title=DiRT_Showdown")
    )
    notes = "Demolition derby-focused DiRT spin-off. Native wheel and FFB. Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30938" } }
}

# --- Codemasters GRID Series ---
$newEntries["race_driver_grid"] = [PSCustomObject]@{
    title = "Race Driver: GRID"
    manufacturer = $null
    developer = "Codemasters"
    publisher = "Codemasters"
    year = "2008"
    rotation_degrees = 540
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "reference" "Logitech official compatibility list confirms 200 and 900-degree modes, H-pattern shifter, and FFB." "https://support.logi.com/hc/en-150/articles/360023375653"),
        (New-Src "developer" "Codemasters GRID series. Native wheel and FFB support.")
    )
    notes = "First GRID game. Full wheel support with 200 and 900-degree modes. Playable on RPCS3. 540 recommended."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30142" } }
}

$newEntries["grid_2"] = [PSCustomObject]@{
    title = "GRID 2"
    manufacturer = $null
    developer = "Codemasters"
    publisher = "Codemasters"
    year = "2013"
    rotation_degrees = 540
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "developer" "Codemasters GRID series. Native wheel and FFB support. Arcade-sim hybrid handling."),
        (New-Src "wiki" "RPCS3 Wiki confirms Playable status." "https://wiki.rpcs3.net/index.php?title=GRID_2")
    )
    notes = "Arcade-sim hybrid racer. Native wheel and FFB. Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-31055" } }
}

# --- Codemasters F1 Series ---
$newEntries["f1_2010"] = [PSCustomObject]@{
    title = "F1 2010"
    manufacturer = $null
    developer = "Codemasters"
    publisher = "Codemasters"
    year = "2010"
    rotation_degrees = 360
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "reference" "Logitech official compatibility list confirms 900-degree mode, H-pattern, clutch, shift LEDs, and FFB for G27." "https://support.logi.com/hc/en-150/articles/360023375653"),
        (New-Src "developer" "Codemasters F1 series. Native wheel and FFB. Game hardcodes ~220-360 degree lock for F1 car realism.")
    )
    notes = "First Codemasters F1 game. Native wheel and FFB. 360 degrees recommended. RPCS3: Playable but virtual G27 may show controller disconnected."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30379" } }
}

$newEntries["f1_2011"] = [PSCustomObject]@{
    title = "F1 2011"
    manufacturer = $null
    developer = "Codemasters"
    publisher = "Codemasters"
    year = "2011"
    rotation_degrees = 360
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "developer" "Codemasters F1 series. Consistent native wheel and FFB support. 360 degrees for F1 cars."),
        (New-Src "inference" "Same engine and wheel implementation as F1 2010/2012. Logitech G25/G27 confirmed compatible.")
    )
    notes = "Codemasters F1 series. Native wheel and FFB. 360 degrees for F1 cars. RPCS3 status: Ingame."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30772" } }
}

$newEntries["f1_2013"] = [PSCustomObject]@{
    title = "F1 2013"
    manufacturer = $null
    developer = "Codemasters"
    publisher = "Codemasters"
    year = "2013"
    rotation_degrees = 360
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "developer" "Codemasters F1 series. Native wheel and FFB. Includes classic F1 cars content."),
        (New-Src "wiki" "RPCS3 Wiki confirms Playable status. Almost 100% compatible with wheel." "https://wiki.rpcs3.net/index.php?title=F1_2013")
    )
    notes = "Codemasters F1 series with classic cars mode. Native wheel and FFB. 360 degrees. Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-31208" } }
}

# --- NFS: The Run ---
$newEntries["need_for_speed_the_run"] = [PSCustomObject]@{
    title = "Need for Speed: The Run"
    manufacturer = $null
    developer = "EA Black Box"
    publisher = "Electronic Arts"
    year = "2011"
    rotation_degrees = 270
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "research" "EA NFS series on PS3. Partial wheel support with FFB. Arcade-focused handling benefits from low rotation."),
        (New-Src "inference" "Same EA NFS era as Hot Pursuit 2010. Arcade handling with 270 degrees to minimize dead zone.")
    )
    notes = "Cross-country NFS on Frostbite 2. Partial wheel support with FFB. RPCS3 status: Ingame (freezing issues)."
    pc = [PSCustomObject]@{ wheel_support = "partial"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30757" } }
}

# --- Milestone WRC Series (PS3) ---
$newEntries["wrc_fia_world_rally_championship"] = [PSCustomObject]@{
    title = "WRC: FIA World Rally Championship"
    manufacturer = $null
    developer = "Milestone S.r.l."
    publisher = "Black Bean Games"
    year = "2010"
    rotation_degrees = 540
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "developer" "Milestone WRC series. Native Logitech wheel and FFB support. 540-degree recommended for rally."),
        (New-Src "wiki" "RPCS3 Wiki confirms Playable status." "https://wiki.rpcs3.net/index.php?title=WRC:_FIA_World_Rally_Championship")
    )
    notes = "First Milestone WRC game (distinct from Evolution Studios PS2 series). PAL-only release. Native wheel and FFB. Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLES-00992" } }
}

$newEntries["wrc_2_fia_world_rally_championship"] = [PSCustomObject]@{
    title = "WRC 2: FIA World Rally Championship"
    manufacturer = $null
    developer = "Milestone S.r.l."
    publisher = "Black Bean Games"
    year = "2011"
    rotation_degrees = 540
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "developer" "Milestone WRC series. Native wheel and FFB support. 540 degrees for rally."),
        (New-Src "wiki" "RPCS3 Wiki confirms Playable status." "https://wiki.rpcs3.net/index.php?title=WRC_2:_FIA_World_Rally_Championship")
    )
    notes = "Second Milestone WRC. PAL-only release. Native wheel and FFB. Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLES-01442" } }
}

$newEntries["wrc_3_fia_world_rally_championship"] = [PSCustomObject]@{
    title = "WRC 3: FIA World Rally Championship"
    manufacturer = $null
    developer = "Milestone S.r.l."
    publisher = "Black Bean Games"
    year = "2012"
    rotation_degrees = 540
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "developer" "Milestone WRC series. Native wheel and FFB support. 540 degrees for rally."),
        (New-Src "wiki" "RPCS3 Wiki confirms Playable status." "https://wiki.rpcs3.net/index.php?title=WRC_3:_FIA_World_Rally_Championship")
    )
    notes = "Third Milestone WRC. PAL-only release. Native wheel and FFB. Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLES-01721" } }
}

# --- Other PS3 Games ---
$newEntries["midnight_club_los_angeles"] = [PSCustomObject]@{
    title = "Midnight Club: Los Angeles"
    manufacturer = $null
    developer = "Rockstar San Diego"
    publisher = "Rockstar Games"
    year = "2008"
    rotation_degrees = 270
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "reference" "Logitech official PS3 compatibility list confirms FFB support for G25/G27." "https://support.logi.com/hc/en-150/articles/360023375653"),
        (New-Src "forum" "Community reports confirm wheel works with FFB but no advanced features (H-pattern, clutch).")
    )
    notes = "Open-world street racer. Partial wheel support with FFB. No H-pattern or clutch. PS3/360 exclusive (never on PC)."
    pc = [PSCustomObject]@{ wheel_support = "partial"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30180" } }
}

$newEntries["motorstorm_apocalypse"] = [PSCustomObject]@{
    title = "MotorStorm: Apocalypse"
    manufacturer = $null
    developer = "Evolution Studios"
    publisher = "Sony Computer Entertainment"
    year = "2011"
    rotation_degrees = 540
    rotation_type = $null
    confidence = "medium"
    sources = @(
        (New-Src "forum" "Community reports indicate wheel support added in a post-launch patch. MotorStorm 1 and Pacific Rift had no wheel support."),
        (New-Src "inference" "Evolution Studios added wheel support for Apocalypse unlike predecessors. Off-road racing benefits from 540 degrees.")
    )
    notes = "PS3-exclusive off-road racer. Partial wheel support added via patch (MotorStorm 1-2 had none). Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "partial"; force_feedback = "unknown"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BCUS-98242" } }
}

$newEntries["initial_d_extreme_stage"] = [PSCustomObject]@{
    title = "Initial D: Extreme Stage"
    manufacturer = $null
    developer = "Sega"
    publisher = "Sega"
    year = "2008"
    rotation_degrees = 540
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "developer" "Sega Initial D series. 540-degree rotation matches arcade cabinets (ID4-ID8). Japan/Asia-only PS3 release."),
        (New-Src "emulator" "RPCS3: Playable but virtual G27 does not register inputs (GitHub issue 17317). Works on real PS3 hardware." "https://github.com/RPCS3/rpcs3/issues/17317")
    )
    notes = "Japan/Asia-only PS3 port of arcade Initial D. Native wheel support on real hardware. 540 degrees matching arcade cabinets. RPCS3: wheel inputs currently broken."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLJM-60055" } }
}

$newEntries["sega_rally_revo"] = [PSCustomObject]@{
    title = "Sega Rally Revo"
    manufacturer = $null
    developer = "Sega Racing Studio"
    publisher = "Sega"
    year = "2007"
    rotation_degrees = 270
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "reference" "Logitech official PS3 compatibility list confirms FFB support for G25/G27." "https://support.logi.com/hc/en-150/articles/360023375653"),
        (New-Src "inference" "Sega Rally series uses 270-degree arcade-style steering. Console reboot.")
    )
    notes = "Console reboot of Sega Rally. Partial wheel support with FFB. 270-degree arcade handling. Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "partial"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30068" } }
}

$newEntries["ferrari_challenge_trofeo_pirelli"] = [PSCustomObject]@{
    title = "Ferrari Challenge: Trofeo Pirelli"
    manufacturer = $null
    developer = "Eutechnyx"
    publisher = "System 3"
    year = "2008"
    rotation_degrees = 270
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "reference" "Logitech official PS3 compatibility list confirms wheel and FFB support." "https://support.logi.com/hc/en-150/articles/360023375653"),
        (New-Src "forum" "Community describes FFB as functional but underwhelming. Basic wheel support works.")
    )
    notes = "Ferrari-licensed racer. Partial wheel support with weak FFB. Playable on RPCS3."
    pc = [PSCustomObject]@{ wheel_support = "partial"; force_feedback = "partial"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30162" } }
}

$newEntries["blur"] = [PSCustomObject]@{
    title = "Blur"
    manufacturer = $null
    developer = "Bizarre Creations"
    publisher = "Activision"
    year = "2010"
    rotation_degrees = 270
    rotation_type = $null
    confidence = "medium"
    sources = @(
        (New-Src "inference" "Power-up arcade racer. Basic wheel mapping likely works. 270 degrees for arcade handling."),
        (New-Src "forum" "Community reports mixed wheel compatibility. Delisted from all storefronts.")
    )
    notes = "Power-up arcade racer from Project Gotham Racing devs. Wheel support unconfirmed. Delisted everywhere. RPCS3 status: Ingame."
    pc = [PSCustomObject]@{ wheel_support = "partial"; force_feedback = "none"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BLUS-30295" } }
}

$newEntries["formula_one_championship_edition"] = [PSCustomObject]@{
    title = "Formula One Championship Edition"
    manufacturer = $null
    developer = "Studio Liverpool"
    publisher = "Sony Computer Entertainment"
    year = "2007"
    rotation_degrees = 360
    rotation_type = $null
    confidence = "high"
    sources = @(
        (New-Src "developer" "Studio Liverpool (ex-Psygnosis). PS3 launch F1 title. Full Logitech wheel support with FFB."),
        (New-Src "inference" "Sequel to PS2 Formula One 05/06 (both in database). F1 games use ~360-degree rotation for realism.")
    )
    notes = "PS3-exclusive F1 game by Studio Liverpool. Full wheel support with FFB. Successor to PS2 Formula One series."
    pc = [PSCustomObject]@{ wheel_support = "native"; force_feedback = "native"; controller_support = "full" }
    platforms = [PSCustomObject]@{ rpcs3 = [PSCustomObject]@{ serial = "BCES-00003" } }
}

# Add all new entries
$newCount = 0
foreach ($key in $newEntries.Keys) {
    if ($db.games.PSObject.Properties[$key]) {
        Write-Host "  WARNING: '$key' already exists - skipping" -ForegroundColor Yellow
    } else {
        $db.games | Add-Member -NotePropertyName $key -NotePropertyValue $newEntries[$key]
        $newCount++
        Write-Host "  Added new: $key"
    }
}
Write-Host "Added $newCount new entries`n"

# ============================================================
# PART 3: Save database
# ============================================================
Write-Host "=== Saving database ===" -ForegroundColor Cyan
$json = $db | ConvertTo-Json -Depth 10 -Compress:$false
$json = $json -replace '\\/', '/'
[System.IO.File]::WriteAllText($dbPath, $json, [System.Text.UTF8Encoding]::new($false))

$totalGames = @($db.games.PSObject.Properties).Count
Write-Host "Database saved: $totalGames total games (v$($db.version))"
