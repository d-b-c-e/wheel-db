<#
.SYNOPSIS
    Add PCGamingWiki URLs to 13 Steam entries missing them (v2.15.0)
.DESCRIPTION
    Research found 13 of 25 missing Steam entries have PCGamingWiki pages.
    The remaining 12 are too niche or new to have PCGW coverage.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$dbPath = Join-Path $PSScriptRoot '..\..\data\wheel-db.json'
$db = Get-Content $dbPath -Raw | ConvertFrom-Json

$enriched = 0

$mappings = @{
    'table_top_racing_world_tour'  = 'https://www.pcgamingwiki.com/wiki/Table_Top_Racing:_World_Tour'
    'drift_over_drive'             = 'https://www.pcgamingwiki.com/wiki/Drift_(Over)_Drive'
    'drift86'                      = 'https://www.pcgamingwiki.com/wiki/Drift86'
    'nash_racing'                  = 'https://www.pcgamingwiki.com/wiki/Nash_Racing'
    'offroad_mania'                = 'https://www.pcgamingwiki.com/wiki/Offroad_Mania'
    'kart_racing_pro'              = 'https://www.pcgamingwiki.com/wiki/Kart_Racing_Pro'
    'trackmania'                   = 'https://www.pcgamingwiki.com/wiki/Trackmania_(2020)'
    'forza_horizon_6'              = 'https://www.pcgamingwiki.com/wiki/Forza_Horizon_6'
    'iracing_arcade'               = 'https://www.pcgamingwiki.com/wiki/IRacing_Arcade'
    'screamer_2026'                = 'https://www.pcgamingwiki.com/wiki/Screamer_(2026)'
    'ride_5'                       = 'https://www.pcgamingwiki.com/wiki/Ride_5'
    'mx_vs_atv_legends'            = 'https://www.pcgamingwiki.com/wiki/MX_vs._ATV_Legends'
    'tt_isle_of_man_3'             = 'https://www.pcgamingwiki.com/wiki/TT_Isle_of_Man:_Ride_on_the_Edge_3'
}

# Not found (12): drift_type_c, drive_beyond_horizons, drifto_infinite_touge,
# gear_club_unlimited_3, torque_drift_2, drift_reign, clutch_drift_simulation,
# drift_tafheet, underground_garage, rally_evolution_2025, gt_racing_1980, karting_superstars

foreach ($slug in $mappings.Keys) {
    $game = $db.games.$slug
    if (-not $game) { Write-Host "  SKIP: $slug not found"; continue }
    if (-not $game.platforms.PSObject.Properties['steam']) { Write-Host "  SKIP: $slug no Steam platform"; continue }

    $steam = $game.platforms.steam
    if ($steam.PSObject.Properties['pcgamingwiki_url'] -and -not [string]::IsNullOrWhiteSpace($steam.pcgamingwiki_url)) {
        Write-Host "  SKIP: $slug already has PCGW URL"
        continue
    }

    if (-not $steam.PSObject.Properties['pcgamingwiki_url']) {
        $steam | Add-Member -NotePropertyName 'pcgamingwiki_url' -NotePropertyValue $mappings[$slug]
    } else {
        $steam.pcgamingwiki_url = $mappings[$slug]
    }
    $enriched++
    Write-Host "  ENRICHED: $slug → $($mappings[$slug])"
}

Write-Host "`n=== SUMMARY ==="
Write-Host "Enriched: $enriched"
Write-Host "Not found on PCGW: 12 (too niche or new)"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding utf8
Write-Host "Database saved."
