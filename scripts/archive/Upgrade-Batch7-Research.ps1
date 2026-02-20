<#
.SYNOPSIS
    Apply research agent findings - second upgrade pass (v2.13.0)
.DESCRIPTION
    Part A: Upgrade 3 Steam entries to high based on research agent findings
    Part B: Correct MX vs ATV Legends (ws→none, rotation→null)
    Part C: Fix year values for TP entries (Frenzy Express, Harley-Davidson KotR)
    Part D: Enrich TP motorcycle sources with hardware documentation
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$dbPath = Join-Path $PSScriptRoot '..\..\data\wheel-db.json'
$db = Get-Content $dbPath -Raw | ConvertFrom-Json

$upgraded = 0
$corrected = 0
$enriched = 0

# ============================================================
# PART A: Steam entries → high based on research
# ============================================================
Write-Host "`n=== PART A: Steam research upgrades ==="

# Torque Drift 2 - multiple sources confirm native ws/ffb
$game = $db.games.torque_drift_2
if ($game -and $game.confidence -eq 'medium') {
    $game.confidence = 'high'
    $game.sources += [PSCustomObject]@{
        type = 'developer'
        description = 'Official Formula DRIFT licensed game. Store page confirms sim rig support. Update 0.8.0 tweaked FFB feel; Update 0.6.0 added sim rig controller mapping. Active community wheel discussions (Moza R5, steering assist requests).'
        url = 'https://torquemotorsport.io/newsroom/torque-drift-2-update-0-8-0-release-notes'
        date_accessed = '2026-02-20'
    }
    $upgraded++
    Write-Host "  UPGRADED: torque_drift_2 → high (multiple sources: store page, update notes, community)"
}

# MX vs ATV Legends - developer denies wheel support
$game = $db.games.mx_vs_atv_legends
if ($game -and $game.confidence -eq 'medium') {
    $game.confidence = 'high'
    $game.pc.wheel_support = 'none'
    $game.pc.force_feedback = 'none'
    $game.rotation_degrees = $null
    $game.sources += [PSCustomObject]@{
        type = 'developer'
        description = 'Rainbow Studios developer confirmed: "We use the X input API and support X input gamepads. X input wheels may work but are not the target device. We do not have plans to add support." Previously added wheel support for Monster Jam but explicitly decided not to for MX vs ATV titles.'
        url = 'https://steamcommunity.com/app/1205970/discussions/0/4295942652152855881/'
        date_accessed = '2026-02-20'
    }
    $game.notes = 'Motorcycle/ATV game. Developer explicitly confirmed wheels are not target devices and no plans to add support. Same XInput-only policy as All Out, Reflex, and Supercross Encore.'
    $upgraded++
    $corrected++
    Write-Host "  UPGRADED: mx_vs_atv_legends → high + CORRECTED ws=none, ffb=none, rotation=null"
}

# Pacer - community discussion confirms ws=none + architectural incompatibility
$game = $db.games.pacer
if ($game -and $game.confidence -eq 'medium') {
    $game.confidence = 'high'
    $game.sources += [PSCustomObject]@{
        type = 'steam_community'
        description = 'Steam community discussion confirms wheels are not suitable: "A wheel is a bad idea for this game." Flight yoke tested and game does not detect non-standard controllers. WipEout-style anti-gravity racer with multi-axis controls fundamentally incompatible with single-axis wheel.'
        url = 'https://steamcommunity.com/app/389670/discussions/0/3109144584169502411/'
        date_accessed = '2026-02-20'
    }
    $upgraded++
    Write-Host "  UPGRADED: pacer → high (community + architectural confirmation)"
}

# ============================================================
# PART B: Year corrections from TP motorcycle research
# ============================================================
Write-Host "`n=== PART B: Year corrections ==="

# Frenzy Express: 2015 → 2001
$game = $db.games.frenzy_express
if ($game -and $game.year -eq '2015') {
    $game.year = '2001'
    $corrected++
    Write-Host "  CORRECTED: frenzy_express year 2015 → 2001 (confirmed by Arcade Museum, arcade-history)"
}

# Harley-Davidson KotR: 2006 → 2009
$game = $db.games.harley_davidson
if ($game -and $game.year -eq '2006') {
    $game.year = '2009'
    $corrected++
    Write-Host "  CORRECTED: harley_davidson year 2006 → 2009 (Sega Lindbergh Red EX, 2008 Japan/2009 international)"
}

# ============================================================
# PART C: Enrich TP motorcycle sources with hardware documentation
# ============================================================
Write-Host "`n=== PART C: TP motorcycle source enrichment ==="

# Dead Heat Riders - Namco ES1 motorcycle, VG75-03824-00 lineage
$game = $db.games.dead_heat_riders
if ($game) {
    $game.sources = @(
        [PSCustomObject]@{ type = 'inference'; description = 'Namco/Bandai Namco ES1 motorcycle cabinet with force feedback swivel bike seat and motorcycle handlebar controller.'; url = $null; date_accessed = '2026-02-20' },
        [PSCustomObject]@{ type = 'parts'; description = 'Namco motorcycle handlebar potentiometer VG75-03824-00 (1K ohm, 60-degree rotation) is the standard across Namco motorcycle cabinets (confirmed in Cybercycles handle assembly). Dead Heat Riders uses same Namco motorcycle cabinet lineage.'; url = 'https://na.suzohapp.com/products/driving_controls/VG75-03824-00'; date_accessed = '2026-02-20' },
        [PSCustomObject]@{ type = 'wiki'; description = 'PrimeTime Amusements: Dead Heat Riders features force feedback swivel bike seat with realistic motorcycle handlebar controller. Cabinet H:90.5" W:43.3" D:82", 665 lbs.'; url = 'https://primetimeamusements.com/product/dead-heat-riders/'; date_accessed = '2026-02-20' }
    )
    $enriched++
    Write-Host "  ENRICHED: dead_heat_riders sources (3 sources with Namco pot part number)"
}

# MotoGP (Namco TP) - same Namco motorcycle lineage
$game = $db.games.motogp_namco
if ($game) {
    $game.sources = @(
        [PSCustomObject]@{ type = 'inference'; description = 'Namco System 246 motorcycle arcade game with body-lean/handlebar steering.'; url = $null; date_accessed = '2026-02-20' },
        [PSCustomObject]@{ type = 'parts'; description = 'Namco motorcycle handlebar potentiometer VG75-03824-00 (1K ohm, 60-degree rotation) is the standard across Namco motorcycle cabinets. Confirmed in Cybercycles (System 22) handle and pivot assembly.'; url = 'https://na.suzohapp.com/products/driving_controls/VG75-03824-00'; date_accessed = '2026-02-20' }
    )
    $enriched++
    Write-Host "  ENRICHED: motogp_namco sources (2 sources with Namco pot part number)"
}

# Nirin - Namco ES1 motorcycle
$game = $db.games.nirin
if ($game) {
    $game.sources = @(
        [PSCustomObject]@{ type = 'inference'; description = 'Namco ES1 motorcycle cabinet with authentic motorcycle swivel controllers and handlebar controls.'; url = $null; date_accessed = '2026-02-20' },
        [PSCustomObject]@{ type = 'parts'; description = 'Namco motorcycle handlebar potentiometer VG75-03824-00 (1K ohm, 60-degree rotation) standard for Namco motorcycle cabinets. SuzoHapp has dedicated Nirin parts page.'; url = 'https://na.suzohapp.com/parts/arcade_parts/namco/nirin/'; date_accessed = '2026-02-20' },
        [PSCustomObject]@{ type = 'wiki'; description = 'PrimeTime Amusements: Nirin features authentic motorcycle swivel controllers with handle bar controls including brake, twist accelerator, shifter buttons. Cabinet H:74" W:41.5" D:76", 630 lbs.'; url = 'https://primetimeamusements.com/product/nirin-single/'; date_accessed = '2026-02-20' }
    )
    $enriched++
    Write-Host "  ENRICHED: nirin sources (3 sources with SuzoHapp parts page)"
}

# Radikal Bikers - operator manual documents 5K pot
$game = $db.games.radikal_bikers
if ($game) {
    $game.sources = @(
        [PSCustomObject]@{ type = 'manual'; description = 'Radikal Bikers Dedicated Game Operation Manual (Atari 16-30038-101) documents 5K OHM potentiometer for handlebar steering. Test mode HANDLE values: 000 full left, 256 full right, center 108-148.'; url = 'https://archive.org/stream/RadikalBikersDedicatedGameOperationManual16-30038-101_810/RadikalBikersDedicatedGameOperationManual16-30038-101_djvu.txt'; date_accessed = '2026-02-20' },
        [PSCustomObject]@{ type = 'reference'; description = 'Gaelco/Atari scooter (Italjet Dragster) cabinet with handlebar controls. Scooter handlebars have limited rotation range, approximately 45 degrees total.'; url = $null; date_accessed = '2026-02-20' }
    )
    $enriched++
    Write-Host "  ENRICHED: radikal_bikers sources (2 sources with operator manual)"
}

# Frenzy Express - kick scooter handlebar
$game = $db.games.frenzy_express
if ($game) {
    $game.sources = @(
        [PSCustomObject]@{ type = 'inference'; description = 'Uniana kick scooter simulator. Actual scooter (Razor-style) in cabinet with handlebar steering, rear brake, and grip wheel acceleration. Scooter handlebars have ~45-degree rotation range.'; url = $null; date_accessed = '2026-02-20' },
        [PSCustomObject]@{ type = 'wiki'; description = 'Highway Games product listing: Frenzy Express kick scooter arcade game. Cabinet 73cm W x 174cm D x 182cm H, 152kg. Released 2001 by Uniana.'; url = 'https://www.highwaygames.com/arcade-machines/frenzy-express-8636/'; date_accessed = '2026-02-20' }
    )
    $enriched++
    Write-Host "  ENRICHED: frenzy_express sources (2 sources with product listing)"
}

# Harley-Davidson KotR - Sega Lindbergh, cruiser-style motorcycle
$game = $db.games.harley_davidson
if ($game) {
    $game.sources = @(
        [PSCustomObject]@{ type = 'inference'; description = 'Sega Lindbergh Red EX hardware. Cruiser-style Harley Davidson replica motorcycle cabinet with handlebar steering and auto body lean. DX cabinet with 62" screen.'; url = $null; date_accessed = '2026-02-20' },
        [PSCustomObject]@{ type = 'manual'; description = 'Sega Retro has Harley-Davidson King of the Road Lindbergh Manual (Deluxe). Sega motorcycle cabinets use 5K ohm potentiometers. Cruiser handlebars have wider range than sportbike lean.'; url = 'https://segaretro.org/images/a/a0/HDKotR_Lindbergh_Manual_Deluxe.pdf'; date_accessed = '2026-02-20' },
        [PSCustomObject]@{ type = 'reference'; description = 'Real Harley-Davidson cruisers have approximately 52-66 degrees lock-to-lock. 90 degrees provides gameplay-appropriate exaggeration for arcade responsiveness.'; url = $null; date_accessed = '2026-02-20' }
    )
    $enriched++
    Write-Host "  ENRICHED: harley_davidson sources (3 sources with Sega manual reference)"
}

# ============================================================
# Summary & Save
# ============================================================
Write-Host "`n=== SUMMARY ==="
Write-Host "Upgraded to high: $upgraded"
Write-Host "Corrected: $corrected"
Write-Host "Sources enriched: $enriched"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding utf8
Write-Host "Database saved."
