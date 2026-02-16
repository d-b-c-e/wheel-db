Set-StrictMode -Version Latest

# Add emulator platform keys to arcade games and merge Mario Kart duplicates
# 2026-02-16

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json
$changes = @()

function Remove-Entry($slug) {
    $db.games.PSObject.Properties.Remove($slug)
}

# ===================================================================
# A. Add supermodel platform to 9 Sega Model 3 games
# ===================================================================
$supermodelGames = @{
    'daytonausa2'             = 'daytona2'
    'daytonausa2pe'           = 'dayto2pe'
    'scudrace'                = 'scud'
    'segarally2'              = 'srally2'
    'dirtdevils'              = 'dirtdvls'
    'lemans24'                = 'lemans24'
    'emergencycallambulance'  = 'eca'
    'harleydavidson'          = 'harley'
    'magical_truck_adventure' = 'magtruck'
}

foreach ($slug in $supermodelGames.Keys) {
    $entry = $db.games.PSObject.Properties[$slug]
    if (-not $entry) {
        Write-Host "WARNING: $slug not found"
        continue
    }
    $game = $entry.Value
    if ($game.platforms.PSObject.Properties['supermodel']) {
        Write-Host "SKIP: $slug already has supermodel"
        continue
    }
    $game.platforms | Add-Member -NotePropertyName 'supermodel' -NotePropertyValue ([PSCustomObject]@{
        romname = $supermodelGames[$slug]
    }) -Force
    $changes += "ADDED supermodel to $slug (romname=$($supermodelGames[$slug]))"
}

# ===================================================================
# B. Add m2emulator platform to 4 Sega Model 2 games
# ===================================================================
$m2Games = @{
    'manxttsuperbike' = 'manxttc'
    'motorraid'       = 'motoraid'
    'overrev'         = 'overrev'
    'supergt24h'      = 'sgt24h'
}

foreach ($slug in $m2Games.Keys) {
    $entry = $db.games.PSObject.Properties[$slug]
    if (-not $entry) {
        Write-Host "WARNING: $slug not found"
        continue
    }
    $game = $entry.Value
    if ($game.platforms.PSObject.Properties['m2emulator']) {
        Write-Host "SKIP: $slug already has m2emulator"
        continue
    }
    $game.platforms | Add-Member -NotePropertyName 'm2emulator' -NotePropertyValue ([PSCustomObject]@{
        romname = $m2Games[$slug]
    }) -Force
    $changes += "ADDED m2emulator to $slug (romname=$($m2Games[$slug]))"
}

# ===================================================================
# C. Add flycast platform to 6 NAOMI games
# ===================================================================
$flycastGames = @{
    '18wheeler'                                  = '18wheelr'
    'crazytaxi'                                  = 'crzytaxi'
    'jambosafari'                                = 'jambo'
    'ferrari_f355_challenge_deluxe_no_link'      = 'f355'
    'ferrari_f355_challenge_twindeluxe'          = 'f355twin'
    'ferrari_f355_challenge_2__international_'   = 'f355twn2'
}

foreach ($slug in $flycastGames.Keys) {
    $entry = $db.games.PSObject.Properties[$slug]
    if (-not $entry) {
        Write-Host "WARNING: $slug not found"
        continue
    }
    $game = $entry.Value
    if ($game.platforms.PSObject.Properties['flycast']) {
        Write-Host "SKIP: $slug already has flycast"
        continue
    }
    $game.platforms | Add-Member -NotePropertyName 'flycast' -NotePropertyValue ([PSCustomObject]@{
        romname = $flycastGames[$slug]
    }) -Force
    $changes += "ADDED flycast to $slug (romname=$($flycastGames[$slug]))"
}

# ===================================================================
# D. Add dolphin platform + merge Mario Kart duplicates
# ===================================================================

# D1. Add dolphin to fzeroax_monster
$fzm = $db.games.PSObject.Properties['fzeroax_monster']
if ($fzm -and -not $fzm.Value.platforms.PSObject.Properties['dolphin']) {
    $fzm.Value.platforms | Add-Member -NotePropertyName 'dolphin' -NotePropertyValue ([PSCustomObject]@{
        game_id = 'GFZJ8P'
    }) -Force
    $changes += "ADDED dolphin to fzeroax_monster (game_id=GFZJ8P)"
}

# D2. Merge mario_kart_arcade_gp (MAME) into mario_kart_gp (TP)
$mkgp_tp = $db.games.PSObject.Properties['mario_kart_gp']
$mkgp_mame = $db.games.PSObject.Properties['mario_kart_arcade_gp']
if ($mkgp_tp -and $mkgp_mame) {
    $keeper = $mkgp_tp.Value
    $mameRom = $mkgp_mame.Value.platforms.mame.romname
    $keeper.platforms | Add-Member -NotePropertyName 'mame' -NotePropertyValue ([PSCustomObject]@{
        romname = $mameRom
        clones_inherit = $true
    }) -Force
    $keeper.platforms | Add-Member -NotePropertyName 'dolphin' -NotePropertyValue ([PSCustomObject]@{
        game_id = 'GGPE01'
    }) -Force
    Remove-Entry 'mario_kart_arcade_gp'
    $changes += "MERGED mario_kart_arcade_gp into mario_kart_gp (added mame=$mameRom, dolphin=GGPE01)"
} else {
    Write-Host "WARNING: Could not find both Mario Kart GP entries"
}

# D3. Merge mario_kart_arcade_gp_2 (MAME) into mario_kart_gp2 (TP)
$mkgp2_tp = $db.games.PSObject.Properties['mario_kart_gp2']
$mkgp2_mame = $db.games.PSObject.Properties['mario_kart_arcade_gp_2']
if ($mkgp2_tp -and $mkgp2_mame) {
    $keeper = $mkgp2_tp.Value
    $mameRom = $mkgp2_mame.Value.platforms.mame.romname
    $keeper.platforms | Add-Member -NotePropertyName 'mame' -NotePropertyValue ([PSCustomObject]@{
        romname = $mameRom
        clones_inherit = $true
    }) -Force
    $keeper.platforms | Add-Member -NotePropertyName 'dolphin' -NotePropertyValue ([PSCustomObject]@{
        game_id = 'GGPE02'
    }) -Force
    Remove-Entry 'mario_kart_arcade_gp_2'
    $changes += "MERGED mario_kart_arcade_gp_2 into mario_kart_gp2 (added mame=$mameRom, dolphin=GGPE02)"
} else {
    Write-Host "WARNING: Could not find both Mario Kart GP 2 entries"
}

# ===================================================================
# Save
# ===================================================================
$json = $db | ConvertTo-Json -Depth 10
$json = $json -replace '(?m)^\s*\n', ''
[System.IO.File]::WriteAllText($dbPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "=== Emulator platform linking complete ==="
$changes | ForEach-Object { Write-Host "  $_" }
Write-Host ""
Write-Host "Total changes: $($changes.Count)"
Write-Host "Total entries: $(@($db.games.PSObject.Properties).Count)"
