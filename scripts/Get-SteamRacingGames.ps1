<#
.SYNOPSIS
    Fetches top racing/driving games from Steam via SteamSpy and Steam Store APIs.

.DESCRIPTION
    1. Queries SteamSpy for games tagged "Racing" and "Driving"
    2. Merges and ranks by ownership/popularity
    3. Enriches top N games with Steam Store API details
    4. Outputs ranked list to JSON for manual research

.PARAMETER OutputPath
    Path to save the JSON output.

.PARAMETER TopN
    Number of top games to retrieve (default: 500).

.PARAMETER SkipEnrich
    Skip Steam Store API enrichment (faster, less detail).

.PARAMETER Force
    Re-fetch even if output file exists.

.EXAMPLE
    .\Get-SteamRacingGames.ps1
    .\Get-SteamRacingGames.ps1 -TopN 100 -Force
#>
param(
    [string]$OutputPath = "$PSScriptRoot\..\sources\cache\steam-racing-games.json",
    [int]$TopN = 500,
    [switch]$SkipEnrich,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=== Get Steam Racing Games ===" -ForegroundColor Cyan
Write-Host "  Output: $OutputPath"
Write-Host "  Top games: $TopN"
Write-Host ""

# Create output directory
$outDir = Split-Path $OutputPath -Parent
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

if ((Test-Path $OutputPath) -and -not $Force) {
    Write-Host "Output file already exists. Use -Force to overwrite." -ForegroundColor Yellow
    $existing = Get-Content -Raw $OutputPath | ConvertFrom-Json
    Write-Host "  Existing file has $($existing.game_count) games (generated $($existing.generated))"
    exit 0
}

# ============================================================
# Step 1: Fetch racing/driving games from SteamSpy
# ============================================================

Write-Host "[1/4] Fetching games from SteamSpy..." -ForegroundColor Yellow

$allGames = @{}
$tags = @("Racing", "Driving")

foreach ($tag in $tags) {
    Write-Host "  Querying tag: $tag..."
    try {
        $url = "https://steamspy.com/api.php?request=tag&tag=$tag"
        $response = Invoke-RestMethod -Uri $url -UseBasicParsing
        $count = 0
        foreach ($prop in $response.PSObject.Properties) {
            if (-not $allGames.ContainsKey($prop.Name)) {
                $allGames[$prop.Name] = $prop.Value
                $count++
            }
        }
        Write-Host "    Found $count new games (total: $($allGames.Count))" -ForegroundColor Green
        Start-Sleep -Seconds 2  # SteamSpy rate limit
    }
    catch {
        Write-Warning "Failed to fetch tag '$tag': $_"
    }
}

if ($allGames.Count -eq 0) {
    Write-Error "No games found from SteamSpy. Check your internet connection."
    exit 1
}

Write-Host "  Total unique games: $($allGames.Count)" -ForegroundColor Green

# ============================================================
# Step 2: Rank by popularity (owners midpoint)
# ============================================================

Write-Host "[2/4] Ranking by popularity..." -ForegroundColor Yellow

function ConvertTo-OwnersMidpoint {
    param([string]$OwnersStr)
    if (-not $OwnersStr) { return 0 }
    # Format: "1,000,000 .. 2,000,000" or "1000000 .. 2000000"
    $cleaned = $OwnersStr -replace ',', ''
    if ($cleaned -match '(\d+)\s*\.\.\s*(\d+)') {
        $low = [long]$matches[1]
        $high = [long]$matches[2]
        return ($low + $high) / 2
    }
    # Format: "1,000,000 - 2,000,000"
    if ($cleaned -match '(\d+)\s*-\s*(\d+)') {
        $low = [long]$matches[1]
        $high = [long]$matches[2]
        return ($low + $high) / 2
    }
    return 0
}

$rankedGames = $allGames.Values | ForEach-Object {
    $ownersMidpoint = ConvertTo-OwnersMidpoint -OwnersStr $_.owners
    [PSCustomObject]@{
        appid           = $_.appid
        name            = $_.name
        developer       = $_.developer
        publisher       = $_.publisher
        owners          = $_.owners
        owners_midpoint = $ownersMidpoint
        ccu             = if ($_.ccu) { $_.ccu } else { 0 }
        average_forever = if ($_.average_forever) { $_.average_forever } else { 0 }
        price           = $_.price
    }
} | Sort-Object -Property owners_midpoint -Descending | Select-Object -First $TopN

Write-Host "  Selected top $($rankedGames.Count) games" -ForegroundColor Green
Write-Host "  Top 5:" -ForegroundColor DarkGray
$rankedGames | Select-Object -First 5 | ForEach-Object {
    Write-Host "    $($_.name) ($($_.owners))" -ForegroundColor DarkGray
}

# ============================================================
# Step 3: Enrich with Steam Store API (optional)
# ============================================================

$enrichedGames = [System.Collections.ArrayList]::new()

if ($SkipEnrich) {
    Write-Host "[3/4] Skipping Steam Store API enrichment (-SkipEnrich)" -ForegroundColor Yellow
    $rank = 0
    foreach ($game in $rankedGames) {
        $rank++
        [void]$enrichedGames.Add([PSCustomObject]@{
            steam_appid      = [int]$game.appid
            title            = $game.name
            developer        = $game.developer
            publisher        = $game.publisher
            release_year     = $null
            controller_support = $null
            owners_estimate  = $game.owners
            popularity_rank  = $rank
            ccu              = $game.ccu
        })
    }
}
else {
    $estimatedMinutes = [math]::Ceiling($rankedGames.Count * 0.35 / 60)
    Write-Host "[3/4] Enriching with Steam Store API (~${estimatedMinutes} min)..." -ForegroundColor Yellow

    $rank = 0
    $errors = 0

    foreach ($game in $rankedGames) {
        $rank++
        $pct = [math]::Floor($rank / $rankedGames.Count * 100)
        Write-Host "  [$rank/$($rankedGames.Count)] ($pct%) $($game.name)" -NoNewline

        try {
            Start-Sleep -Milliseconds 350  # Steam Store API rate limit

            $storeUrl = "https://store.steampowered.com/api/appdetails?appids=$($game.appid)"
            $storeData = Invoke-RestMethod -Uri $storeUrl -UseBasicParsing

            $appData = $storeData."$($game.appid)"

            if ($appData.success -eq $true) {
                $details = $appData.data

                # Parse release year
                $releaseYear = $null
                if ($details.release_date -and $details.release_date.date) {
                    try {
                        $releaseYear = ([DateTime]::Parse($details.release_date.date)).Year.ToString()
                    }
                    catch { }
                }

                [void]$enrichedGames.Add([PSCustomObject]@{
                    steam_appid        = [int]$game.appid
                    title              = $details.name
                    developer          = if ($details.developers -and $details.developers.Count -gt 0) { $details.developers[0] } else { $game.developer }
                    publisher          = if ($details.publishers -and $details.publishers.Count -gt 0) { $details.publishers[0] } else { $game.publisher }
                    release_year       = $releaseYear
                    controller_support = $details.controller_support
                    owners_estimate    = $game.owners
                    popularity_rank    = $rank
                    ccu                = $game.ccu
                })

                Write-Host " ok" -ForegroundColor Green
            }
            else {
                # Game might be delisted or region-locked
                [void]$enrichedGames.Add([PSCustomObject]@{
                    steam_appid        = [int]$game.appid
                    title              = $game.name
                    developer          = $game.developer
                    publisher          = $game.publisher
                    release_year       = $null
                    controller_support = $null
                    owners_estimate    = $game.owners
                    popularity_rank    = $rank
                    ccu                = $game.ccu
                })
                Write-Host " (unavailable)" -ForegroundColor DarkGray
            }
        }
        catch {
            $errors++
            [void]$enrichedGames.Add([PSCustomObject]@{
                steam_appid        = [int]$game.appid
                title              = $game.name
                developer          = $game.developer
                publisher          = $game.publisher
                release_year       = $null
                controller_support = $null
                owners_estimate    = $game.owners
                popularity_rank    = $rank
                ccu                = $game.ccu
            })
            Write-Host " (error)" -ForegroundColor Red

            # If we get rate-limited, back off
            $resp = $null
            try { $resp = $_.Exception.Response } catch { }
            if ($resp -and $resp.StatusCode -eq 429) {
                Write-Host "    Rate limited, waiting 30s..." -ForegroundColor Yellow
                Start-Sleep -Seconds 30
            }
        }
    }

    if ($errors -gt 0) {
        Write-Host "  $errors games had enrichment errors" -ForegroundColor Yellow
    }
}

# ============================================================
# Step 4: Save output
# ============================================================

Write-Host "[4/4] Saving output..." -ForegroundColor Yellow

$output = [ordered]@{
    generated  = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    source     = "SteamSpy API + Steam Store API"
    game_count = $enrichedGames.Count
    games      = $enrichedGames
}

$output | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputPath -Encoding UTF8

Write-Host ""
Write-Host "=== Complete ===" -ForegroundColor Cyan
Write-Host "  Games saved: $($enrichedGames.Count)"
Write-Host "  Output file: $OutputPath"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review the game list in the output file"
Write-Host "  2. Research wheel support for each game"
Write-Host "  3. Add entries to data/steam-wheel-support.json"
