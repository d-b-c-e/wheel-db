Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json

$updatedCount = 0

# Round 2: Manual mappings for the remaining ~46 Steam entries without PCGW URLs
# Format: appid -> PCGW wiki slug (the part after /wiki/)
$manualMappings = @{
    # Well-known games
    320140  = 'Absolute_Drift'
    550320  = 'Art_of_Rally'
    1114150 = 'CarX_Street'
    233610  = 'Distance_(video_game)'
    520950  = 'DRIFT_CE'
    21780   = 'Driver:_Parallel_Lines'
    678900  = "Farmer%27s_Dynasty"
    658570  = 'FURIDASHI:_Drift_Cyber_Sport'
    362930  = 'Garfield_Kart'
    243800  = 'Gas_Guzzlers_Extreme'
    1480560 = 'Lawn_Mowing_Simulator'
    1520370 = 'Mon_Bazou'
    1369670 = 'Motor_Town:_Behind_The_Wheel'
    287310  = 'Re-Volt'
    2077750 = 'RENNSPORT'
    589760  = 'Revhead'
    297860  = 'Split/Second:_Velocity'
    497180  = 'Street_Legal_Racing:_Redline'
    292410  = 'Street_Racing_Syndicate'
    375900  = 'Trackmania_Turbo'
    # Niche but likely on PCGW
    2102520 = 'Apex_Point'
    1097130 = 'Circuit_Superstars'
    514970  = 'Drive_Megapolis'
    2494780 = '%23DRIVE_Rally'
    1640630 = 'Heading_Out'
    1456200 = 'Initial_Drift_Online'
    2073470 = 'Kanjozoku_Game:_Taxi_Driver'
    2217580 = 'New_Star_GP'
    547410  = 'Peak_Angle:_Drift_Online'
    1112400 = 'Project_Torque'
    2020860 = 'Rush_Rally_3'
    264120  = 'Victory:_The_Age_of_Racing'
    1230800 = 'Beach_Buggy_Racing_2:_Island_Adventure'
    108700  = 'Death_Rally_(2012)'
    358270  = 'Death_Rally'
    609920  = 'Hotshot_Racing'
    1271700 = 'Hot_Wheels_Unleashed'
    389140  = 'Horizon_Chase_Turbo'
    505170  = 'Carmageddon:_Max_Damage'
    287260  = 'Toybox_Turbos'
    1664220 = 'TRAIL_OUT'
    785260  = 'Team_Sonic_Racing'
    # Very niche - may or may not have PCGW pages
    4164420 = 'My_Winter_Car'
    2824660 = 'Old_School_Rally'
    2737300 = 'Parking_Garage_Rally_Circuit'
    2305520 = 'Project_Drift_2.0'
    # Probably no PCGW pages (very niche)
    # 447920  = 'Drift_(Over)_Drive'       # Unlikely
    # 1975860 = 'Drift_Type_C'             # Unlikely
    # 1070580 = 'Drift86'                  # Unlikely
    # 2949020 = 'Drifto:_Infinite_Touge'   # Unlikely
    # 2625420 = 'Drive_Beyond_Horizons'    # Unlikely
    # 581200  = 'Nash_Racing'              # Unlikely
    # 1222040 = 'Offroad_Mania'            # Unlikely
    # 450670  = 'Table_Top_Racing:_World_Tour' # Check separately
    # 732810  = 'Slipstream_(2018)'        # Already in round 1 mappings?
}

$db.games.PSObject.Properties | Where-Object {
    $_.Value.platforms.PSObject.Properties['steam']
} | ForEach-Object {
    $steam = $_.Value.platforms.steam
    $appid = $steam.appid

    # Skip if already has a PCGW URL
    if ($steam.PSObject.Properties['pcgamingwiki_url'] -and $steam.pcgamingwiki_url) {
        return
    }

    $pcgwSlug = $null
    if ($manualMappings.ContainsKey([int]$appid)) {
        $pcgwSlug = $manualMappings[[int]$appid]
    }

    if ($pcgwSlug) {
        $pcgwUrl = "https://www.pcgamingwiki.com/wiki/$pcgwSlug"
        $steam.pcgamingwiki_url = $pcgwUrl
        Write-Host "  Set: $($_.Name) -> $pcgwUrl"
        $script:updatedCount++
    }
    else {
        Write-Host "  SKIP: $($_.Name) (appid $appid) - no mapping"
    }
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host "Updated: $updatedCount"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding UTF8
Write-Host "Database saved."
