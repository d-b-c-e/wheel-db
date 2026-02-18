Set-StrictMode -Version Latest

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json

$today = '2026-02-18'
$upgraded = 0
$wsFixed = 0
$rotFixed = 0

function Update-Entry {
    param(
        [string]$Slug,
        [string]$NewConfidence,
        [string]$SourceType,
        [string]$SourceDesc,
        [string]$SourceUrl,
        [string]$WheelSupport,
        [string]$FFB,
        [object]$NewRotation,
        [string]$Notes
    )

    $entry = $db.games.PSObject.Properties[$Slug]
    if (-not $entry) {
        Write-Host "  SKIP: $Slug not found"
        return
    }
    $game = $entry.Value

    # Update confidence
    if ($NewConfidence -and $NewConfidence -ne $game.confidence) {
        $old = $game.confidence
        $game.confidence = $NewConfidence
        Write-Host "  CONFIDENCE: $Slug $old -> $NewConfidence"
        $script:upgraded++
    }

    # Update rotation if specified
    if ($null -ne $NewRotation -and $NewRotation -ne $game.rotation_degrees) {
        $old = $game.rotation_degrees
        $game.rotation_degrees = $NewRotation
        Write-Host "  ROTATION: $Slug $old -> $NewRotation"
        $script:rotFixed++
    }

    # Update PC metadata
    if ($game.PSObject.Properties['pc'] -and $game.pc) {
        if ($WheelSupport -and $WheelSupport -ne 'unchanged') {
            $old = $game.pc.wheel_support
            if ($old -ne $WheelSupport) {
                $game.pc.wheel_support = $WheelSupport
                Write-Host "  WHEEL: $Slug $old -> $WheelSupport"
                $script:wsFixed++
            }
        }
        if ($FFB -and $FFB -ne 'unchanged') {
            $old = $game.pc.force_feedback
            if ($old -ne $FFB) {
                $game.pc.force_feedback = $FFB
                Write-Host "  FFB: $Slug $old -> $FFB"
            }
        }
    }

    # Add source
    if ($SourceType -and $SourceDesc) {
        $newSource = [PSCustomObject]@{
            type          = $SourceType
            description   = $SourceDesc
            url           = if ($SourceUrl) { $SourceUrl } else { $null }
            date_accessed = $today
        }
        $game.sources += $newSource
    }

    # Update notes if provided
    if ($Notes) {
        $game.notes = $Notes
    }
}

Write-Host "=== Upgrading Steam Confidence Levels ==="
Write-Host ""

# --- 10 games upgraded to medium confidence ---
Write-Host "--- Medium Confidence Upgrades ---"

Update-Entry -Slug 'drive_megapolis' -NewConfidence 'medium' `
    -SourceType 'steam_community' `
    -SourceDesc 'Steam community confirms wheel support via JoyMapping configuration for driving skills trainer' `
    -SourceUrl 'https://steamcommunity.com/app/514970/discussions/0/348293292497899786/' `
    -WheelSupport 'partial' -FFB 'unchanged'

Update-Entry -Slug 'crash_time_2' -NewConfidence 'medium' `
    -SourceType 'steam_community' `
    -SourceDesc 'Steam community guides confirm wheel support works if activated from title screen; Logitech wheels reported working' `
    -SourceUrl 'https://steamcommunity.com/sharedfiles/filedetails/?id=329238068' `
    -WheelSupport 'partial' -FFB 'unchanged'

Update-Entry -Slug 'jalopy' -NewConfidence 'medium' `
    -SourceType 'steam_community' `
    -SourceDesc 'Game has dedicated steering wheel input mode in settings; developer warns only select wheels supported' `
    -SourceUrl 'https://steamcommunity.com/app/446020/discussions/0/1697169163398125163/' `
    -WheelSupport 'partial' -FFB 'none'

Update-Entry -Slug 'new_star_gp' -NewConfidence 'medium' `
    -SourceType 'forum' `
    -SourceDesc 'Wheel support added in April 2024 update for Logitech G29 and Thrustmaster T150; no FFB but recentering works' `
    -SourceUrl 'https://www.operationsports.com/new-star-gp-update-adds-some-steering-wheel-support-improvements-and-fixes/' `
    -WheelSupport 'partial' -FFB 'none'

Update-Entry -Slug 'parking_garage_rally_circuit' -NewConfidence 'medium' `
    -SourceType 'steam_community' `
    -SourceDesc 'Developer confirms wheels work if registered as game controller; in-game deadzone and sensitivity settings' `
    -SourceUrl 'https://steamcommunity.com/app/2737300/discussions/0/597388446551569738/' `
    -WheelSupport 'partial' -FFB 'none'

Update-Entry -Slug 'monster_jam_steel_titans' -NewConfidence 'medium' `
    -SourceType 'steam_community' `
    -SourceDesc 'Native wheel support for Logitech/Thrustmaster via UserWheelInput.ini; limited but functional' `
    -SourceUrl 'https://steamcommunity.com/app/824280/discussions/0/1639789306589175222/' `
    -WheelSupport 'partial' -FFB 'partial'

Update-Entry -Slug 'monster_jam_steel_titans_2' -NewConfidence 'medium' `
    -SourceType 'steam_community' `
    -SourceDesc 'Native wheel support with decent FFB on Thrustmaster T300; torque steer effects work, cuts out at high speed' `
    -SourceUrl 'https://steamcommunity.com/app/1205480/discussions/0/3073117690248861846/' `
    -WheelSupport 'partial' -FFB 'partial'

Update-Entry -Slug 'tourist_bus_simulator' -NewConfidence 'medium' `
    -SourceType 'steam_community' `
    -SourceDesc 'Native wheel support confirmed; Logitech G29, Fanatec, Moza recognized. Related Fernbus uses 700deg default, BS21 uses 720deg.' `
    -SourceUrl 'https://steamcommunity.com/app/953580/discussions/0/4349987747247374781/' `
    -WheelSupport 'native' -FFB 'unchanged'

Update-Entry -Slug 'construction_simulator' -NewConfidence 'medium' `
    -SourceType 'forum' `
    -SourceDesc 'Official FAQ lists extensive supported wheels (Logitech G27/G29/G920, Thrustmaster T150/T300RS, Fanatec CSL Elite). No native FFB.' `
    -SourceUrl 'https://www.construction-simulator.com/en/faq-cs2022.php' `
    -WheelSupport 'native' -FFB 'partial'

# GRIP: rotation change 270 -> 180
Update-Entry -Slug 'grip_combat_racing' -NewConfidence 'medium' `
    -SourceType 'steam_community' `
    -SourceDesc 'Community XOutput tutorial recommends 180 degree Wheel Operating Range with 100% sensitivity' `
    -SourceUrl 'https://steamcommunity.com/app/396900/discussions/0/5413843407461989070/' `
    -WheelSupport 'none' -FFB 'none' `
    -NewRotation 180 `
    -Notes 'No native wheel support. Community workaround via XOutput recommends 180 degrees with centering spring.'

Write-Host ""
Write-Host "--- Wheel Support = None Corrections ---"

# 19 games where wheel_support and FFB should be "none"
$noneGames = @(
    @{ Slug = 'kartrider_drift'; Desc = 'No native wheel support; designed for controllers. Game shutting down outside Korea/Taiwan.' }
    @{ Slug = 'pacific_drive'; Desc = 'Developer confirmed no native wheel support. Workarounds via x360ce have issues.' }
    @{ Slug = 'sonic_and_allstars_racing_transformed'; Desc = 'No native wheel support; air/boat transformations make wheels impractical.' }
    @{ Slug = 'circuit_superstars'; Desc = 'No steering wheel support; top-down arcade racer designed for controllers.' }
    @{ Slug = 'table_top_racing_world_tour'; Desc = 'Developer confirmed no wheel support and no plans to add it.' }
    @{ Slug = 'hotshot_racing'; Desc = 'Developer confirmed no plans for wheel support despite community demand.' }
    @{ Slug = 'team_sonic_racing'; Desc = 'No native wheel support; community workarounds via Wheel2Xinput only.' }
    @{ Slug = 'hot_wheels_unleashed'; Desc = 'Developer confirms no wheel support; designed as arcade racer for controllers.' }
    @{ Slug = 'horizon_chase_turbo'; Desc = 'No native wheel support; retro arcade racer inspired by OutRun designed for controllers.' }
    @{ Slug = 'carmageddon_max_damage'; Desc = 'No native wheel support; config file FFB settings non-functional.' }
    @{ Slug = 'drift86'; Desc = 'No wheel support; game uses simplified physics unsuited for wheel input.' }
    @{ Slug = 'drive_beyond_horizons'; Desc = 'Early Access; no native controller/wheel support yet. Steam controller emulation as workaround.' }
    @{ Slug = 'toybox_turbos'; Desc = 'No wheel support; top-down micro machines-style racer designed for controllers.' }
    @{ Slug = 'death_rally_classic'; Desc = 'Classic 1996 DOS top-down combat racer; no modern wheel support.' }
    @{ Slug = 'death_rally'; Desc = '2012 remake of top-down combat racer for mobile/touch; no wheel support.' }
    @{ Slug = 'kanjozoku_game'; Desc = 'Developer confirmed no steering wheel support; only keyboard/mouse and controller.' }
    @{ Slug = 'heading_out'; Desc = 'No wheel support; narrative-focused driving game designed for controller/keyboard.' }
    @{ Slug = 'trail_out'; Desc = 'Developer stated wheel support not a priority: "We have an arcade game, not a simulator."' }
    @{ Slug = 'beach_buggy_racing_2'; Desc = 'Developer confirmed no full steering wheel support; originally mobile game.' }
)

$noneGames | ForEach-Object {
    $slug = $_.Slug
    $desc = $_.Desc
    $entry = $db.games.PSObject.Properties[$slug]
    if (-not $entry) {
        Write-Host "  SKIP: $slug not found"
        return
    }
    $game = $entry.Value

    if ($game.PSObject.Properties['pc'] -and $game.pc) {
        $oldWs = $game.pc.wheel_support
        $oldFfb = $game.pc.force_feedback
        $changed = $false
        if ($oldWs -ne 'none') {
            $game.pc.wheel_support = 'none'
            $changed = $true
            $script:wsFixed++
        }
        if ($oldFfb -ne 'none') {
            $game.pc.force_feedback = 'none'
            $changed = $true
        }
        if ($changed) {
            Write-Host "  FIXED: $slug ws=$oldWs->none ffb=$oldFfb->none"
        }

        # Add research source
        $newSource = [PSCustomObject]@{
            type          = 'research'
            description   = $desc
            url           = $null
            date_accessed = $today
        }
        $game.sources += $newSource
    }
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host "  Confidence upgrades: $upgraded"
Write-Host "  Wheel support fixes: $wsFixed"
Write-Host "  Rotation fixes: $rotFixed"

$db | ConvertTo-Json -Depth 10 | Set-Content $dbPath -Encoding UTF8
Write-Host "Database saved."
