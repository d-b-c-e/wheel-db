Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json

$updatedCount = 0

# Known title-to-PCGW-slug mappings for games where the title doesn't match the wiki page
# Format: appid -> PCGW wiki slug (the part after /wiki/)
$manualMappings = @{
    # GTA series
    271590 = 'Grand_Theft_Auto_V'
    3240220 = 'Grand_Theft_Auto_V'
    12120 = 'Grand_Theft_Auto:_San_Andreas'
    12220 = 'Grand_Theft_Auto:_Episodes_from_Liberty_City'
    # NFS series
    1222680 = 'Need_for_Speed_Heat'
    47870 = 'Need_for_Speed:_Hot_Pursuit'
    1262600 = 'Need_for_Speed_Rivals'
    1262560 = 'Need_for_Speed:_Most_Wanted_(2012)'
    1846380 = 'Need_for_Speed_Unbound'
    1262540 = 'Need_for_Speed_(2015)'
    17430 = 'Need_for_Speed:_Undercover'
    1328660 = 'Need_for_Speed:_Hot_Pursuit_Remastered'
    1262580 = 'Need_for_Speed_Payback'
    24870 = 'Need_for_Speed:_Shift'
    47920 = 'Need_for_Speed:_Shift_2_Unleashed'
    # F1 series
    286570 = 'F1_2015_(Codemasters)'
    226580 = 'F1_2014'
    391040 = 'F1_2016'
    515220 = 'F1_2017'
    737800 = 'F1_2018'
    928600 = 'F1_2019'
    1080110 = 'F1_2020'
    1134570 = 'F1_2021'
    1692250 = 'F1_22'
    2108330 = 'F1_23'
    2488620 = 'F1_24'
    208500 = 'F1_2012'
    3059520 = 'F1_25'
    # WRC series
    256330 = 'WRC_4:_FIA_World_Rally_Championship'
    354160 = 'WRC_5:_FIA_World_Rally_Championship'
    621830 = 'WRC_7:_FIA_World_Rally_Championship'
    1004750 = 'WRC_8:_FIA_World_Rally_Championship'
    1267540 = 'WRC_9:_FIA_World_Rally_Championship'
    1462810 = 'WRC_10:_FIA_World_Rally_Championship'
    1953520 = 'WRC_Generations'
    1849250 = 'EA_Sports_WRC'
    # DiRT/Colin McRae
    421020 = 'Dirt_4'
    1038250 = 'Dirt_5'
    287340 = 'Colin_McRae_Rally_(2014)'
    310560 = 'DiRT_Rally'
    690790 = 'DiRT_Rally_2.0'
    # GRID
    255220 = 'Grid_Autosport'
    703860 = 'Grid_(2019)'
    # Forza
    1551360 = 'Forza_Horizon_5'
    1293830 = 'Forza_Horizon_4'
    2440510 = 'Forza_Motorsport_(2023)'
    # Sim racing
    244210 = 'Assetto_Corsa'
    805550 = 'Assetto_Corsa_Competizione'
    3058630 = 'Assetto_Corsa_EVO'
    266410 = 'IRacing'
    365960 = 'RFactor_2'
    1066890 = 'Automobilista_2'
    431600 = 'Automobilista'
    234630 = 'Project_CARS'
    378860 = 'Project_CARS_2'
    958400 = 'Project_CARS_3'
    429180 = 'Project_CARS'
    2399420 = 'Le_Mans_Ultimate'
    406350 = 'KartKraft'
    211500 = 'RaceRoom_Racing_Experience'
    8600 = 'Race_07'
    # Truck/Bus sims
    270880 = 'American_Truck_Simulator'
    227300 = 'Euro_Truck_Simulator_2'
    232010 = 'Euro_Truck_Simulator'
    252530 = 'OMSI_2'
    427100 = 'Fernbus_Simulator'
    324310 = 'Bus_Simulator_16'
    515180 = 'Bus_Simulator_18'
    976590 = 'Bus_Simulator_21'
    302080 = 'Bus_Driver'
    491540 = 'The_Bus'
    258760 = 'Scania_Truck_Driving_Simulator'
    849100 = 'Alaskan_Road_Truckers'
    302060 = 'Trucks_%26_Trailers'
    2380050 = 'Star_Trucker'
    # Farming sims
    787860 = 'Farming_Simulator_19'
    313160 = 'Farming_Simulator_15'
    447020 = 'Farming_Simulator_17'
    220260 = 'Farming_Simulator_2013'
    1248130 = 'Farming_Simulator_22'
    2300320 = 'Farming_Simulator_25'
    # Driving sims/misc
    493490 = 'City_Car_Driving'
    516750 = 'My_Summer_Car'
    1017180 = 'The_Long_Drive'
    675010 = 'MudRunner'
    1465360 = 'SnowRunner'
    2477340 = 'Expeditions:_A_MudRunner_Game'
    1351240 = 'Taxi_Life:_A_City_Driving_Simulator'
    1249970 = 'Test_Drive_Unlimited_Solar_Crown'
    234140 = 'Mad_Max_(2015)'
    # Burnout / Crew
    1238080 = 'Burnout_Paradise_Remastered'
    24740 = 'Burnout_Paradise:_The_Ultimate_Box'
    241560 = 'The_Crew'
    646910 = 'The_Crew_2'
    2698940 = 'The_Crew_Motorfest'
    # FlatOut
    2990 = 'FlatOut_2'
    6220 = 'FlatOut'
    12360 = 'FlatOut:_Ultimate_Carnage'
    402130 = 'FlatOut_4:_Total_Insanity'
    201510 = 'FlatOut_3:_Chaos_%26_Destruction'
    # TrackMania
    232910 = 'TrackMania%C2%B2:_Stadium'
    7200 = 'TrackMania_United_Forever'
    228760 = 'TrackMania%C2%B2:_Canyon'
    # Sonic
    34190 = 'Sonic_%26_Sega_All-Stars_Racing'
    212480 = 'Sonic_%26_All-Stars_Racing_Transformed'
    785260 = 'Team_Sonic_Racing'
    # Other known
    331160 = 'Cars_(Pixar)'
    71230 = 'Crazy_Taxi'
    252950 = 'Rocket_League'
    50130 = 'Mafia_II'
    228380 = 'Wreckfest'
    635260 = 'CarX_Drift_Racing_Online'
    1029550 = 'Torque_Drift'
    345890 = 'NASCAR_%2715_Victory_Edition'
    1127980 = 'NASCAR_Heat_4'
    # Misc racing
    11390 = 'Crash_Time_2'
    12160 = 'Midnight_Club_II'
    609920 = 'Hotshot_Racing'
    1271700 = 'Hot_Wheels_Unleashed'
    396900 = 'GRIP:_Combat_Racing'
    389140 = 'Horizon_Chase_Turbo'
    505170 = 'Carmageddon:_Max_Damage'
    446020 = 'Jalopy'
    287260 = 'Toybox_Turbos'
    108700 = 'Death_Rally_(2012)'
    358270 = 'Death_Rally'
    732810 = 'Slipstream_(2018)'
    1458140 = 'Pacific_Drive'
    # Misc driving
    1184140 = 'KartRider:_Drift'
    412880 = 'Drift_Streets_Japan'
    457330 = 'High_Octane_Drift'
    # SimBin
    44600 = 'GTR_-_FIA_GT_Racing_Game'
    44690 = 'GT_Legends'
    8660 = 'GTR_Evolution'
    44680 = 'RACE_Injection'
    8690 = 'STCC:_The_Game'
    8790 = 'GTR_2:_FIA_GT_Racing_Game'
    # New additions
    299970 = 'Project_Motor_Racing'
    1203190 = 'Wreckfest_2'
    1826420 = 'CarX_Drift_Racing_Online_2'
    3194360 = 'Formula_Legends'
    1839940 = 'Dakar_Desert_Rally'
    355060 = 'S%C3%A9bastien_Loeb_Rally_Evo'
    658700 = 'V-Rally_4'
    558260 = 'Gravel_(video_game)'
    824280 = 'Monster_Jam_Steel_Titans'
    1205480 = 'Monster_Jam_Steel_Titans_2'
    953580 = 'Tourist_Bus_Simulator'
    1273400 = 'Construction_Simulator_(2022)'
    211970 = 'Test_Drive:_Ferrari_Racing_Legends'
    # Ridge Racer, Star Wars
    202310 = 'Ridge_Racer_Unbounded'
    808910 = 'Star_Wars_Episode_I:_Racer'
    2634950 = 'Tokyo_Xtreme_Racer_(2024)'
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
