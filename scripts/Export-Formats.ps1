<#
.SYNOPSIS
    Generates export formats from the unified wheel-db.json database.

.DESCRIPTION
    Reads the primary JSON database and produces:
    - wheel-db.json          (copy of full database for release)
    - mame-wheel-rotation.csv (flat MAME ROM-to-rotation lookup)
    - mame-wheel-rotation.xml (MAME data in XML format)
    - steam-wheel-support.csv (Steam wheel support lookup)
    - wheel-db.csv           (unified flat CSV of all games)

    Only games with known values (non-null rotation or non-unknown wheel support)
    are included in platform-specific exports.

.PARAMETER DatabasePath
    Path to the source wheel-db.json file.

.PARAMETER OutputDir
    Directory where export files are written. Created if it doesn't exist.
#>
param(
    [string]$DatabasePath = "$PSScriptRoot/../data/wheel-db.json",
    [string]$OutputDir = "$PSScriptRoot/../dist"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DatabasePath = Resolve-Path $DatabasePath
Write-Host "Reading database: $DatabasePath"

$db = Get-Content -Raw $DatabasePath | ConvertFrom-Json
$gameProps = @($db.games.PSObject.Properties)
Write-Host "Database version: $($db.version) | Total games: $($gameProps.Count)"

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}
$OutputDir = Resolve-Path $OutputDir

# --- 1. Copy full JSON ---
$jsonDest = Join-Path $OutputDir "wheel-db.json"
Copy-Item -Path $DatabasePath -Destination $jsonDest -Force
Write-Host "Exported: $jsonDest"

# --- 2. MAME CSV/XML (games with MAME romname + known rotation) ---
$mameGames = [System.Collections.ArrayList]::new()

foreach ($prop in $gameProps) {
    $game = $prop.Value
    $plats = $game.platforms

    if (-not $plats -or -not $plats.PSObject.Properties['mame']) { continue }
    $mameInfo = $plats.mame
    if ($null -eq $game.rotation_degrees) { continue }

    $gp = $game.PSObject.Properties
    # Collect ROM names (singular or array)
    $roms = @()
    if ($mameInfo.PSObject.Properties['romnames'] -and $mameInfo.romnames) {
        $roms = @($mameInfo.romnames)
    } elseif ($mameInfo.PSObject.Properties['romname'] -and $mameInfo.romname) {
        $roms = @($mameInfo.romname)
    }
    foreach ($rom in $roms) {
        [void]$mameGames.Add([PSCustomObject]@{
            romname          = $rom
            title            = $game.title
            manufacturer     = if ($gp['manufacturer'] -and $game.manufacturer) { $game.manufacturer } else { '' }
            year             = if ($gp['year'] -and $game.year) { $game.year } else { '' }
            rotation_degrees = $game.rotation_degrees
            rotation_type    = if ($gp['rotation_type'] -and $game.rotation_type) { $game.rotation_type } else { '' }
            confidence       = $game.confidence
        })
    }
}

$mameGames = $mameGames | Sort-Object romname
Write-Host "MAME games with known rotation: $($mameGames.Count)"

# MAME CSV
$csvPath = Join-Path $OutputDir "mame-wheel-rotation.csv"
$csvLines = [System.Collections.ArrayList]::new()
[void]$csvLines.Add("romname,title,manufacturer,year,rotation_degrees,rotation_type,confidence")

foreach ($g in $mameGames) {
    $title = $g.title -replace '"', '""'
    $mfr = $g.manufacturer -replace '"', '""'
    [void]$csvLines.Add("`"$($g.romname)`",`"$title`",`"$mfr`",`"$($g.year)`",$($g.rotation_degrees),`"$($g.rotation_type)`",`"$($g.confidence)`"")
}

$csvLines -join "`n" | Set-Content -Path $csvPath -Encoding UTF8 -NoNewline
Write-Host "Exported: $csvPath ($($mameGames.Count) entries)"

# MAME XML
$xmlPath = Join-Path $OutputDir "mame-wheel-rotation.xml"

$xmlSettings = [System.Xml.XmlWriterSettings]::new()
$xmlSettings.Indent = $true
$xmlSettings.IndentChars = "  "
$xmlSettings.Encoding = [System.Text.UTF8Encoding]::new($false)

$stream = [System.IO.FileStream]::new($xmlPath, [System.IO.FileMode]::Create)
$writer = [System.Xml.XmlWriter]::Create($stream, $xmlSettings)

$writer.WriteStartDocument()
$writer.WriteStartElement("wheelRotationDb")
$writer.WriteAttributeString("version", $db.version)
$writer.WriteAttributeString("generated", $db.generated.ToString("yyyy-MM-ddTHH:mm:ssZ"))
$writer.WriteAttributeString("gameCount", $mameGames.Count.ToString())

foreach ($g in $mameGames) {
    $writer.WriteStartElement("game")
    $writer.WriteAttributeString("romname", $g.romname)
    $writer.WriteAttributeString("title", $g.title)
    $writer.WriteAttributeString("manufacturer", $g.manufacturer)
    $writer.WriteAttributeString("year", $g.year)
    $writer.WriteAttributeString("rotation", $g.rotation_degrees.ToString())
    $writer.WriteAttributeString("type", $g.rotation_type)
    $writer.WriteAttributeString("confidence", $g.confidence)
    $writer.WriteEndElement()
}

$writer.WriteEndElement()
$writer.WriteEndDocument()
$writer.Flush()
$writer.Close()
$stream.Close()

Write-Host "Exported: $xmlPath ($($mameGames.Count) entries)"

# --- 3. Steam CSV (games with Steam appid + known wheel support) ---
$steamGames = [System.Collections.ArrayList]::new()

foreach ($prop in $gameProps) {
    $game = $prop.Value
    $plats = $game.platforms
    $gp = $game.PSObject.Properties

    if (-not $plats -or -not $plats.PSObject.Properties['steam']) { continue }
    if (-not $gp['pc'] -or $null -eq $game.pc) { continue }

    $steamInfo = $plats.steam
    $pc = $game.pc

    # Skip unknown wheel support
    if ($pc.wheel_support -eq 'unknown') { continue }

    $rotation = if ($null -ne $game.rotation_degrees -and $game.rotation_degrees -ne -1) {
        $game.rotation_degrees
    } else { '' }

    [void]$steamGames.Add([PSCustomObject]@{
        appid                       = $steamInfo.appid
        title                       = $game.title
        developer                   = if ($gp['developer'] -and $game.developer) { $game.developer } else { '' }
        publisher                   = if ($gp['publisher'] -and $game.publisher) { $game.publisher } else { '' }
        year                        = if ($gp['year'] -and $game.year) { $game.year } else { '' }
        wheel_support               = $pc.wheel_support
        force_feedback              = $pc.force_feedback
        recommended_rotation_degrees = $rotation
        confidence                  = $game.confidence
    })
}

$steamGames = $steamGames | Sort-Object appid
Write-Host "Steam games with known wheel support: $($steamGames.Count)"

$steamCsvPath = Join-Path $OutputDir "steam-wheel-support.csv"
$steamCsvLines = [System.Collections.ArrayList]::new()
[void]$steamCsvLines.Add("appid,title,developer,publisher,year,wheel_support,force_feedback,recommended_rotation_degrees,confidence")

foreach ($g in $steamGames) {
    $title = $g.title -replace '"', '""'
    $dev = $g.developer -replace '"', '""'
    $pub = $g.publisher -replace '"', '""'
    [void]$steamCsvLines.Add("$($g.appid),`"$title`",`"$dev`",`"$pub`",`"$($g.year)`",`"$($g.wheel_support)`",`"$($g.force_feedback)`",$($g.recommended_rotation_degrees),`"$($g.confidence)`"")
}

$steamCsvLines -join "`n" | Set-Content -Path $steamCsvPath -Encoding UTF8 -NoNewline
Write-Host "Exported: $steamCsvPath ($($steamGames.Count) entries)"

# --- 4. Unified CSV (all games, all platforms) ---
$unifiedCsvPath = Join-Path $OutputDir "wheel-db.csv"
$unifiedLines = [System.Collections.ArrayList]::new()
[void]$unifiedLines.Add("slug,title,manufacturer,developer,publisher,year,rotation_degrees,rotation_type,confidence,wheel_support,force_feedback,mame_romname,steam_appid,teknoparrot_profile")

foreach ($prop in $gameProps) {
    $game = $prop.Value
    $gp = $game.PSObject.Properties
    $plats = $game.platforms

    $title = $game.title -replace '"', '""'
    $mfr = if ($gp['manufacturer'] -and $game.manufacturer) { $game.manufacturer -replace '"', '""' } else { '' }
    $dev = if ($gp['developer'] -and $game.developer) { $game.developer -replace '"', '""' } else { '' }
    $pub = if ($gp['publisher'] -and $game.publisher) { $game.publisher -replace '"', '""' } else { '' }
    $year = if ($gp['year'] -and $game.year) { $game.year } else { '' }
    $rot = if ($null -ne $game.rotation_degrees) { $game.rotation_degrees } else { '' }
    $rotType = if ($gp['rotation_type'] -and $game.rotation_type) { $game.rotation_type } else { '' }

    $ws = ''
    $ffb = ''
    if ($gp['pc'] -and $null -ne $game.pc) {
        $ws = $game.pc.wheel_support
        $ffb = $game.pc.force_feedback
    }

    $mameRom = ''
    if ($plats.PSObject.Properties['mame']) {
        $m = $plats.mame
        if ($m.PSObject.Properties['romnames'] -and $m.romnames) {
            $mameRom = $m.romnames -join ';'
        } elseif ($m.PSObject.Properties['romname'] -and $m.romname) {
            $mameRom = $m.romname
        }
    }
    $steamId = if ($plats.PSObject.Properties['steam']) { $plats.steam.appid } else { '' }
    $tpProfile = ''
    if ($plats.PSObject.Properties['teknoparrot']) {
        $tp = $plats.teknoparrot
        if ($tp.PSObject.Properties['profiles']) {
            $tpProfile = $tp.profiles -join ';'
        } elseif ($tp.PSObject.Properties['profile']) {
            $tpProfile = $tp.profile
        }
    }

    [void]$unifiedLines.Add("`"$($prop.Name)`",`"$title`",`"$mfr`",`"$dev`",`"$pub`",`"$year`",$rot,`"$rotType`",`"$($game.confidence)`",`"$ws`",`"$ffb`",`"$mameRom`",$steamId,`"$tpProfile`"")
}

$unifiedLines -join "`n" | Set-Content -Path $unifiedCsvPath -Encoding UTF8 -NoNewline
Write-Host "Exported: $unifiedCsvPath ($($gameProps.Count) entries)"

Write-Host "`nExport complete. Files in: $OutputDir"
