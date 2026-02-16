Set-StrictMode -Version Latest

# Add 8 new Steam racing games discovered from web research (2026-02-15)
$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json
$today = '2026-02-15'

$newGames = [ordered]@{
    "rennsport" = [ordered]@{
        title = "RENNSPORT"
        manufacturer = $null
        developer = "RENNSPORT GmbH"
        publisher = "RENNSPORT GmbH"
        year = "2025"
        rotation_degrees = 900
        rotation_type = $null
        confidence = "verified"
        sources = @(
            [ordered]@{
                type = "developer"
                description = "Built as a sim racer with full direct drive wheelbase optimization. Force feedback calibrated for all major ecosystems."
                url = "https://store.steampowered.com/app/2077750/RENNSPORT/"
                date_accessed = $today
            }
        )
        notes = "Free-to-play competitive sim racer. Full VR support. Designed for direct drive wheelbases."
        pc = [ordered]@{
            wheel_support = "native"
            force_feedback = "native"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 2077750
                tags = @("Racing", "Simulation", "Free to Play")
                store_url = "https://store.steampowered.com/app/2077750"
                pcgamingwiki_url = $null
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "drift_ce" = [ordered]@{
        title = "DRIFT CE"
        manufacturer = $null
        developer = "ECC Games"
        publisher = "505 Games"
        year = "2021"
        rotation_degrees = 540
        rotation_type = $null
        confidence = "high"
        sources = @(
            [ordered]@{
                type = "developer"
                description = "Formerly DRIFT21. Physics 2.0 update overhauled FFB with Moza wheel support. 540 standard for drift sim."
                url = "https://store.steampowered.com/app/520950/DRIFT_CE/"
                date_accessed = $today
            }
        )
        notes = "Drift racing sim on EBISU circuits. Renamed from DRIFT21 in 2023. 1800+ replaceable car components."
        pc = [ordered]@{
            wheel_support = "native"
            force_feedback = "native"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 520950
                tags = @("Racing", "Simulation", "Driving")
                store_url = "https://store.steampowered.com/app/520950"
                pcgamingwiki_url = $null
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "jdm_japanese_drift_master" = [ordered]@{
        title = "JDM: Japanese Drift Master"
        manufacturer = $null
        developer = "Gaming Factory"
        publisher = "Gaming Factory"
        year = "2025"
        rotation_degrees = 540
        rotation_type = $null
        confidence = "high"
        sources = @(
            [ordered]@{
                type = "developer"
                description = "Patch 1.6.0 overhauled FFB support from ground up with customizable settings. 540 aligns with JDM drift standard."
                url = "https://store.steampowered.com/app/1153410/JDM_Japanese_Drift_Master/"
                date_accessed = $today
            }
        )
        notes = "Open-world drift racing through Japan. Steering wheel FFB overhauled in patch 1.6.0."
        pc = [ordered]@{
            wheel_support = "native"
            force_feedback = "native"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 1153410
                tags = @("Racing", "Driving", "Open World")
                store_url = "https://store.steampowered.com/app/1153410"
                pcgamingwiki_url = "https://www.pcgamingwiki.com/wiki/JDM:_Japanese_Drift_Master"
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "assetto_corsa_rally" = [ordered]@{
        title = "Assetto Corsa Rally"
        manufacturer = $null
        developer = "Supernova"
        publisher = "505 Games"
        year = "2025"
        rotation_degrees = 540
        rotation_type = $null
        confidence = "verified"
        sources = @(
            [ordered]@{
                type = "developer"
                description = "Built on Assetto Corsa physics engine refined for rally. 3D laser-scanned stages. Native wheel+FFB."
                url = "https://store.steampowered.com/app/3917090/Assetto_Corsa_Rally/"
                date_accessed = $today
            }
        )
        notes = "Rally sim by Supernova in partnership with Kunos Simulazioni. UE5 engine. Early Access Nov 2025. 85% positive reviews."
        pc = [ordered]@{
            wheel_support = "native"
            force_feedback = "native"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 3917090
                tags = @("Racing", "Simulation", "Rally")
                store_url = "https://store.steampowered.com/app/3917090"
                pcgamingwiki_url = "https://www.pcgamingwiki.com/wiki/Assetto_Corsa_Rally"
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "nascar_25" = [ordered]@{
        title = "NASCAR 25"
        manufacturer = $null
        developer = "iRacing"
        publisher = "Motorsport Games"
        year = "2025"
        rotation_degrees = 900
        rotation_type = $null
        confidence = "verified"
        sources = @(
            [ordered]@{
                type = "developer"
                description = "Built by iRacing with laser scanned cars and tracks. Advanced tire/suspension modeling. FFB calibrated for direct drive."
                url = "https://store.steampowered.com/app/3873970/NASCAR_25/"
                date_accessed = $today
            }
        )
        notes = "Official NASCAR game featuring all four National Series. iRacing-derived physics engine."
        pc = [ordered]@{
            wheel_support = "native"
            force_feedback = "native"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 3873970
                tags = @("Racing", "Simulation", "Sports")
                store_url = "https://store.steampowered.com/app/3873970"
                pcgamingwiki_url = "https://www.pcgamingwiki.com/wiki/NASCAR_25"
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "hot_wheels_unleashed_2" = [ordered]@{
        title = "Hot Wheels Unleashed 2: Turbocharged"
        manufacturer = $null
        developer = "Milestone"
        publisher = "Milestone"
        year = "2023"
        rotation_degrees = 270
        rotation_type = $null
        confidence = "medium"
        sources = @(
            [ordered]@{
                type = "research"
                description = "Arcade racing sequel. Basic wheel support. 270 standard for arcade racers."
                url = "https://store.steampowered.com/app/2051120"
                date_accessed = $today
            }
        )
        notes = "Arcade toy car racer. Sequel to Hot Wheels Unleashed."
        pc = [ordered]@{
            wheel_support = "partial"
            force_feedback = "none"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 2051120
                tags = @("Racing", "Arcade", "Driving")
                store_url = "https://store.steampowered.com/app/2051120"
                pcgamingwiki_url = "https://www.pcgamingwiki.com/wiki/Hot_Wheels_Unleashed_2:_Turbocharged"
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "drive_rally" = [ordered]@{
        title = "#DRIVE Rally"
        manufacturer = $null
        developer = "Pixel Perfect Dude"
        publisher = "QLOC"
        year = "2024"
        rotation_degrees = 540
        rotation_type = $null
        confidence = "high"
        sources = @(
            [ordered]@{
                type = "steam_community"
                description = "Community confirms wheel+FFB support. Officially supported wheels include Logitech, Thrustmaster, Fanatec ranges."
                url = "https://steamcommunity.com/app/2494780/discussions/0/4844274293910709338/"
                date_accessed = $today
            }
        )
        notes = "Retro-styled arcade rally inspired by 1990s racing. Controller and wheel support with force feedback."
        pc = [ordered]@{
            wheel_support = "native"
            force_feedback = "native"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 2494780
                tags = @("Racing", "Rally", "Arcade")
                store_url = "https://store.steampowered.com/app/2494780"
                pcgamingwiki_url = $null
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "old_school_rally" = [ordered]@{
        title = "Old School Rally"
        manufacturer = $null
        developer = "Midnight Minis"
        publisher = "No More Coffee Games"
        year = "2024"
        rotation_degrees = 540
        rotation_type = $null
        confidence = "medium"
        sources = @(
            [ordered]@{
                type = "steam_community"
                description = "Basic Logitech wheel support added. FFB and broader wheel brand support planned for future updates."
                url = "https://steamcommunity.com/app/2824660/discussions/0/6364229920741675189/"
                date_accessed = $today
            }
        )
        notes = "Early Access rally game. Basic wheel support (Logitech only). FFB support in development."
        pc = [ordered]@{
            wheel_support = "partial"
            force_feedback = "none"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 2824660
                tags = @("Racing", "Rally", "Indie")
                store_url = "https://store.steampowered.com/app/2824660"
                pcgamingwiki_url = $null
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }
}

# Add each game, checking for duplicates
$added = @()
foreach ($entry in $newGames.GetEnumerator()) {
    $slug = $entry.Key
    $game = $entry.Value
    if ($db.games.PSObject.Properties[$slug]) {
        Write-Host "SKIP: $slug already exists"
        continue
    }
    # Check for duplicate appid
    $appid = $game.platforms.steam.appid
    $dupAppid = $false
    foreach ($prop in $db.games.PSObject.Properties) {
        $sp = $prop.Value.platforms.PSObject.Properties['steam']
        if ($sp -and $sp.Value.appid -eq $appid) {
            Write-Host "SKIP: $slug - appid $appid already used by $($prop.Name)"
            $dupAppid = $true
            break
        }
    }
    if ($dupAppid) { continue }

    $db.games | Add-Member -NotePropertyName $slug -NotePropertyValue ([PSCustomObject]$game) -Force
    $added += "$slug ($($game.title), appid=$appid)"
}

# Save
$json = $db | ConvertTo-Json -Depth 10
$json = $json -replace '(?m)^\s*\n', ''
[System.IO.File]::WriteAllText($dbPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "=== Added $($added.Count) new Steam games ==="
$added | ForEach-Object { Write-Host "  $_" }
Write-Host "Total entries: $(@($db.games.PSObject.Properties).Count)"
