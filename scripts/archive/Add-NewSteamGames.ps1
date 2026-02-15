<#
.SYNOPSIS
    One-time script to add 11 new Steam racing/driving games to wheel-db.
.DESCRIPTION
    Adds games researched from Steam discovery (Feb 2026).
    Batch 1: art of rally, Rush Rally 3, Slipstream, New Star GP, Beach Buggy Racing 2,
             Parking Garage Rally Circuit, Offroad Mania
    Batch 2: rFactor, GTR 2, My Winter Car, Drifto: Infinite Touge
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$dbPath = "$PSScriptRoot\..\..\data\wheel-db.json"
$db = Get-Content -Raw $dbPath | ConvertFrom-Json

$newGames = [ordered]@{

    "art_of_rally" = [ordered]@{
        title = "art of rally"
        manufacturer = $null
        developer = "Funselektor Labs"
        publisher = "Funselektor Labs"
        year = "2020"
        rotation_degrees = 540
        rotation_type = $null
        confidence = "medium"
        sources = @(
            [ordered]@{
                type = "steam_community"
                description = "Steam community discussions confirm wheel works via xinput but no FFB; 540 degrees recommended by multiple T300/T150 users"
                url = $null
                date_accessed = "2026-02-15"
            }
        )
        notes = "Designed primarily for gamepad/keyboard. Wheels work via xinput but no force feedback (Unity engine limitation). 540 degrees is community consensus."
        pc = [ordered]@{
            wheel_support = "partial"
            force_feedback = "none"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 550320
                tags = @("Racing", "Driving")
                store_url = "https://store.steampowered.com/app/550320"
                pcgamingwiki_url = $null
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "rush_rally_3" = [ordered]@{
        title = "Rush Rally 3"
        manufacturer = $null
        developer = "Brownmonster Limited"
        publisher = "Brownmonster Limited"
        year = "2022"
        rotation_degrees = 540
        rotation_type = $null
        confidence = "high"
        sources = @(
            [ordered]@{
                type = "steam_community"
                description = "Developer-posted Steam discussion confirms DirectInput 8 wheel support with FFB. Recommended 540-720 degree rotation."
                url = $null
                date_accessed = "2026-02-15"
            }
        )
        notes = "Wheel support via DirectInput 8 with force feedback. Developer recommends 540-720 degrees. Logitech G923/G920/G29 and Thrustmaster confirmed working."
        pc = [ordered]@{
            wheel_support = "native"
            force_feedback = "native"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 2020860
                tags = @("Racing", "Driving")
                store_url = "https://store.steampowered.com/app/2020860"
                pcgamingwiki_url = $null
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "slipstream" = [ordered]@{
        title = "Slipstream"
        manufacturer = $null
        developer = "ansdor"
        publisher = "ansdor"
        year = "2018"
        rotation_degrees = $null
        rotation_type = $null
        confidence = "high"
        sources = @(
            [ordered]@{
                type = "steam_community"
                description = "Steam community confirms no native wheel support; no control remapping options in-game"
                url = $null
                date_accessed = "2026-02-15"
            }
        )
        notes = "Retro pseudo-3D arcade racer inspired by OutRun. No native steering wheel support and no in-game control remapping. Keyboard/gamepad only."
        pc = [ordered]@{
            wheel_support = "none"
            force_feedback = "none"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 732810
                tags = @("Racing", "Arcade")
                store_url = "https://store.steampowered.com/app/732810"
                pcgamingwiki_url = "https://www.pcgamingwiki.com/wiki/Slipstream"
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "new_star_gp" = [ordered]@{
        title = "New Star GP"
        manufacturer = $null
        developer = "New Star Games"
        publisher = "Five Aces Publishing"
        year = "2024"
        rotation_degrees = $null
        rotation_type = $null
        confidence = "medium"
        sources = @(
            [ordered]@{
                type = "steam_community"
                description = "Steam discussions and developer comments confirm limited wheel support for Logitech G29 and Thrustmaster T150/T300. No force feedback."
                url = $null
                date_accessed = "2026-02-15"
            }
        )
        notes = "Retro-style F1 racing game. Very limited wheel support added post-launch. Steering feels digital rather than analog. No FFB. Developer acknowledges wheel support is limited."
        pc = [ordered]@{
            wheel_support = "partial"
            force_feedback = "none"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 2217580
                tags = @("Racing", "Sports")
                store_url = "https://store.steampowered.com/app/2217580"
                pcgamingwiki_url = $null
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "beach_buggy_racing_2" = [ordered]@{
        title = "Beach Buggy Racing 2: Island Adventure"
        manufacturer = $null
        developer = "Vector Unit"
        publisher = "Vector Unit"
        year = "2021"
        rotation_degrees = $null
        rotation_type = $null
        confidence = "high"
        sources = @(
            [ordered]@{
                type = "developer"
                description = "Developer response on Steam confirms no steering wheel support. Multiple changes would be needed for wheel experience."
                url = $null
                date_accessed = "2026-02-15"
            }
        )
        notes = "Kart racer. Developer explicitly confirmed no wheel support on PC. Standard gamepads and keyboard only."
        pc = [ordered]@{
            wheel_support = "none"
            force_feedback = "none"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 1230800
                tags = @("Racing", "Arcade")
                store_url = "https://store.steampowered.com/app/1230800"
                pcgamingwiki_url = $null
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "parking_garage_rally_circuit" = [ordered]@{
        title = "Parking Garage Rally Circuit"
        manufacturer = $null
        developer = "Walaber Entertainment"
        publisher = "Walaber Entertainment"
        year = "2024"
        rotation_degrees = $null
        rotation_type = $null
        confidence = "low"
        sources = @(
            [ordered]@{
                type = "steam_community"
                description = "Developer stated wheel works if recognized as game controller. Has deadzone/sensitivity settings. No explicit FFB confirmation."
                url = $null
                date_accessed = "2026-02-15"
            }
        )
        notes = "Lo-fi Sega Saturn-inspired rally game. Wheel works via generic game controller input. Has sensitivity and deadzone adjustment."
        pc = [ordered]@{
            wheel_support = "partial"
            force_feedback = "unknown"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 2737300
                tags = @("Racing", "Indie")
                store_url = "https://store.steampowered.com/app/2737300"
                pcgamingwiki_url = $null
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "offroad_mania" = [ordered]@{
        title = "Offroad Mania"
        manufacturer = $null
        developer = "Active Games"
        publisher = "Active Games"
        year = "2020"
        rotation_degrees = $null
        rotation_type = $null
        confidence = "low"
        sources = @(
            [ordered]@{
                type = "steam_community"
                description = "No dedicated wheel support found. One user reported game crashes on launch when Logitech G29 is connected."
                url = $null
                date_accessed = "2026-02-15"
            }
        )
        notes = "Off-road 4x4 driving simulator with puzzle-like levels. Wheel support appears absent or broken - crash reports with G29 connected."
        pc = [ordered]@{
            wheel_support = "unknown"
            force_feedback = "unknown"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 1222040
                tags = @("Racing", "Simulation")
                store_url = "https://store.steampowered.com/app/1222040"
                pcgamingwiki_url = $null
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "rfactor" = [ordered]@{
        title = "rFactor"
        manufacturer = $null
        developer = "Image Space Incorporated"
        publisher = "Image Space Incorporated"
        year = "2005"
        rotation_degrees = 450
        rotation_type = $null
        confidence = "high"
        sources = @(
            [ordered]@{
                type = "steam_community"
                description = "Steam community guide recommends 450 degrees as good middle ground; configurable via Controller.ini Steering Wheel Range setting"
                url = "https://steamcommunity.com/sharedfiles/filedetails/?id=402072199"
                date_accessed = "2026-02-15"
            }
        )
        notes = "Classic PC sim racer. 450 degrees recommended as most car mods won't use steering lock above 30 degrees. RealFeel FFB plugin recommended over default."
        pc = [ordered]@{
            wheel_support = "native"
            force_feedback = "native"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 339790
                tags = @("Racing", "Simulation")
                store_url = "https://store.steampowered.com/app/339790"
                pcgamingwiki_url = "https://www.pcgamingwiki.com/wiki/RFactor"
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "gtr_2" = [ordered]@{
        title = "GTR 2: FIA GT Racing Game"
        manufacturer = $null
        developer = "SimBin Development Team"
        publisher = "Atari"
        year = "2006"
        rotation_degrees = 240
        rotation_type = $null
        confidence = "high"
        sources = @(
            [ordered]@{
                type = "forum"
                description = "OverTake.gg thread confirms GTR 2 is hard-wired to 240 degrees FFB wheel rotation; cannot be changed"
                url = "https://www.overtake.gg/threads/did-you-know-gtr2-is-hard-wired-to-240-degrees-ffb-wheel-rotation-and-why-it-matters.188737/"
                date_accessed = "2026-02-15"
            }
        )
        notes = "GTR 2 has a hard-wired 240 degree wheel rotation that cannot be changed. Set physical wheel to 240 degrees for 1:1 match."
        pc = [ordered]@{
            wheel_support = "native"
            force_feedback = "native"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 44690
                tags = @("Racing", "Simulation")
                store_url = "https://store.steampowered.com/app/44690"
                pcgamingwiki_url = "https://www.pcgamingwiki.com/wiki/GTR_2"
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "my_winter_car" = [ordered]@{
        title = "My Winter Car"
        manufacturer = $null
        developer = "Amistech Games"
        publisher = "Amistech Games"
        year = "2025"
        rotation_degrees = 900
        rotation_type = $null
        confidence = "medium"
        sources = @(
            [ordered]@{
                type = "steam_community"
                description = "Steam community discussions confirm wheel support with visual rotation matching setting. 900 degrees matches Logitech G29 physical range."
                url = $null
                date_accessed = "2026-02-15"
            }
        )
        notes = "Open-world car life simulator. Has in-game wheel rotation setting to match physical wheel. Some users report alignment issues (~30 degree offset)."
        pc = [ordered]@{
            wheel_support = "native"
            force_feedback = "native"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 4164420
                tags = @("Simulation", "Driving")
                store_url = "https://store.steampowered.com/app/4164420"
                pcgamingwiki_url = $null
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }

    "drifto_infinite_touge" = [ordered]@{
        title = "Drifto: Infinite Touge"
        manufacturer = $null
        developer = "Jonathon Oram Howe"
        publisher = "Jonathon Oram Howe"
        year = "2024"
        rotation_degrees = $null
        rotation_type = $null
        confidence = "low"
        sources = @(
            [ordered]@{
                type = "research"
                description = "No specific wheel support documentation found. Full controller support confirmed on Steam store page."
                url = $null
                date_accessed = "2026-02-15"
            }
        )
        notes = "Drift-focused touge racing game. Full controller support but no documented wheel-specific information."
        pc = [ordered]@{
            wheel_support = "unknown"
            force_feedback = "unknown"
            controller_support = "full"
        }
        platforms = [ordered]@{
            steam = [ordered]@{
                appid = 2949020
                tags = @("Racing", "Indie")
                store_url = "https://store.steampowered.com/app/2949020"
                pcgamingwiki_url = $null
                popularity_rank = $null
                owners_estimate = $null
            }
        }
    }
}

# Add each new game to the database
$added = 0
foreach ($key in $newGames.Keys) {
    if ($db.games.PSObject.Properties[$key]) {
        Write-Host "SKIP: $key already exists" -ForegroundColor Yellow
    } else {
        $db.games | Add-Member -NotePropertyName $key -NotePropertyValue ([PSCustomObject]$newGames[$key])
        $added++
        Write-Host "ADD:  $key ($($newGames[$key].title))" -ForegroundColor Green
    }
}

# Update version
$db.version = "2.3.0"
$db.generated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# Save
$db | ConvertTo-Json -Depth 10 | Set-Content -Path $dbPath -Encoding UTF8
$newCount = @($db.games.PSObject.Properties).Count

Write-Host ""
Write-Host "Added $added new games. Total: $newCount (was 829)" -ForegroundColor Cyan
Write-Host "Version bumped to 2.3.0"
