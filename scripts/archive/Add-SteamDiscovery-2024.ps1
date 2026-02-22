# Add-SteamDiscovery-2024.ps1
# One-time script: Add games found during Steam discovery pass (Feb 2026)
# Games: On The Road - Truck Simulator, RIDE 6, NASCAR Arcade Rush

param(
    [string]$DatabasePath = "./data/wheel-db.json"
)

$ErrorActionPreference = 'Stop'

# Load database
$raw = Get-Content $DatabasePath -Raw
$db = $raw | ConvertFrom-Json

$added = 0

# --- 1. On The Road - The Truck Simulator ---
if (-not $db.games.PSObject.Properties['on_the_road_truck_simulator']) {
    $db.games | Add-Member -NotePropertyName 'on_the_road_truck_simulator' -NotePropertyValue ([PSCustomObject]@{
        title = "On The Road - The Truck Simulator"
        manufacturer = $null
        developer = "toxtronyx interactive GmbH"
        publisher = "Aerosoft GmbH"
        year = "2019"
        rotation_degrees = 900
        rotation_type = $null
        confidence = "high"
        sources = @(
            [PSCustomObject]@{
                type = "steam_community"
                description = "Steam store page and community confirm steering wheel support with known FFB compatibility issues across wheel models"
                url = "https://store.steampowered.com/app/285380"
                date_accessed = "2026-02-21"
            },
            [PSCustomObject]@{
                type = "reference"
                description = "Truck simulator standard: 900-degree wheel rotation matches real truck steering, confirmed by genre convention (ETS2, ATS, Alaskan Road Truckers)"
                url = $null
                date_accessed = "2026-02-21"
            }
        )
        notes = "Truck simulator competing with ETS2/ATS. Wheel support implemented but FFB inconsistent across wheel models. Developer provides dedicated FFB Test App."
        pc = [PSCustomObject]@{
            wheel_support = "partial"
            force_feedback = "partial"
            controller_support = "full"
        }
        platforms = [PSCustomObject]@{
            steam = [PSCustomObject]@{
                appid = 285380
                tags = @("Simulation", "Driving", "Automobile Sim")
                store_url = "https://store.steampowered.com/app/285380"
                pcgamingwiki_url = "https://www.pcgamingwiki.com/wiki/On_The_Road"
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    })
    $added++
    Write-Host "Added: on_the_road_truck_simulator"
} else {
    Write-Host "SKIP: on_the_road_truck_simulator already exists"
}

# --- 2. RIDE 6 ---
if (-not $db.games.PSObject.Properties['ride_6']) {
    $db.games | Add-Member -NotePropertyName 'ride_6' -NotePropertyValue ([PSCustomObject]@{
        title = "RIDE 6"
        manufacturer = $null
        developer = "Milestone S.r.l."
        publisher = "Milestone S.r.l."
        year = "2026"
        rotation_degrees = 270
        rotation_type = $null
        confidence = "high"
        sources = @(
            [PSCustomObject]@{
                type = "pcgamingwiki"
                description = "Motorcycle racing game. Consistent with all prior RIDE titles - no steering wheel support."
                url = "https://www.pcgamingwiki.com/wiki/Ride_6"
                date_accessed = "2026-02-21"
            },
            [PSCustomObject]@{
                type = "research"
                description = "Motorcycle racing game from well-known developer. All titles in this developer's catalog consistently have no wheel support - motorcycles use body lean and dual-stick controls, not steering wheels."
                url = $null
                date_accessed = "2026-02-21"
            }
        )
        notes = "Latest RIDE entry. Motorcycle racing, no wheel support. 200+ motorcycles."
        pc = [PSCustomObject]@{
            wheel_support = "none"
            force_feedback = "none"
            controller_support = "full"
        }
        platforms = [PSCustomObject]@{
            steam = [PSCustomObject]@{
                appid = 2815070
                tags = @("Racing", "Motorcycle", "Simulation")
                store_url = "https://store.steampowered.com/app/2815070"
                pcgamingwiki_url = "https://www.pcgamingwiki.com/wiki/Ride_6"
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    })
    $added++
    Write-Host "Added: ride_6"
} else {
    Write-Host "SKIP: ride_6 already exists"
}

# --- 3. NASCAR Arcade Rush ---
if (-not $db.games.PSObject.Properties['nascar_arcade_rush']) {
    $db.games | Add-Member -NotePropertyName 'nascar_arcade_rush' -NotePropertyValue ([PSCustomObject]@{
        title = "NASCAR Arcade Rush"
        manufacturer = $null
        developer = "Team6 Game Studios"
        publisher = "GameMill Entertainment"
        year = "2023"
        rotation_degrees = 270
        rotation_type = $null
        confidence = "high"
        sources = @(
            [PSCustomObject]@{
                type = "pcgamingwiki"
                description = "PCGamingWiki confirms arcade-style NASCAR game with controller support but no dedicated steering wheel support"
                url = "https://www.pcgamingwiki.com/wiki/NASCAR_Arcade_Rush"
                date_accessed = "2026-02-21"
            },
            [PSCustomObject]@{
                type = "steam_community"
                description = "Steam community discussions confirm no wheel support. Pure arcade racer with boosts and jumps."
                url = "https://store.steampowered.com/app/2192060"
                date_accessed = "2026-02-21"
            }
        )
        notes = "Arcade-style NASCAR game with boosts, jumps, nitro. No dedicated wheel support."
        pc = [PSCustomObject]@{
            wheel_support = "none"
            force_feedback = "none"
            controller_support = "partial"
        }
        platforms = [PSCustomObject]@{
            steam = [PSCustomObject]@{
                appid = 2192060
                tags = @("Racing", "Arcade")
                store_url = "https://store.steampowered.com/app/2192060"
                pcgamingwiki_url = "https://www.pcgamingwiki.com/wiki/NASCAR_Arcade_Rush"
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    })
    $added++
    Write-Host "Added: nascar_arcade_rush"
} else {
    Write-Host "SKIP: nascar_arcade_rush already exists"
}

# --- Update version ---
$db.version = "2.24.0"
$db.generated = "2026-02-21T00:00:00Z"

# --- Save ---
$json = $db | ConvertTo-Json -Depth 10
# Fix escaped forward slashes
$json = $json -replace '\\/', '/'
[System.IO.File]::WriteAllText((Resolve-Path $DatabasePath).Path, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host "`nDone. Added $added new entries. Version bumped to 2.24.0."
$gameCount = ($db.games.PSObject.Properties | Measure-Object).Count
Write-Host "Total games: $gameCount"
