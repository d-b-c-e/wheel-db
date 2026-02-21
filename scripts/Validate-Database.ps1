<#
.SYNOPSIS
    Validates wheel-db.json against the v2.0 schema and checks for data issues.

.DESCRIPTION
    Checks:
    - Required top-level fields
    - Required per-entry fields (title, rotation_degrees, confidence, sources, platforms)
    - Enum values (rotation_type, confidence, source types, wheel_support, force_feedback)
    - Rotation values in valid range (45-1080, -1, or null)
    - Sources array non-empty
    - No duplicate slugs (inherent in JSON keys)
    - No duplicate Steam appids or MAME romnames
    - pc sub-object validity when present
    - Platform sub-entry validity

.PARAMETER DatabasePath
    Path to wheel-db.json
#>
param(
    [string]$DatabasePath = "$PSScriptRoot\..\data\wheel-db.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=== Validate Wheel Database ===" -ForegroundColor Cyan

$db = Get-Content -Raw $DatabasePath | ConvertFrom-Json
$gameProps = @($db.games.PSObject.Properties)
$gameCount = $gameProps.Count

Write-Host "  Version: $($db.version)"
Write-Host "  Total games: $gameCount"
Write-Host ""

$errors = 0
$warnings = 0

# --- Valid enum values ---
$validRotationType = @('mechanical_stop', 'optical_encoder', 'potentiometer', 'unknown')
$validConfidence = @('verified', 'high', 'medium', 'low', 'unknown')
$validSourceTypes = @(
    'manual', 'forum', 'wiki', 'video', 'measurement', 'inference', 'other',
    'api', 'pcgamingwiki', 'reddit', 'steam_community', 'youtube',
    'developer', 'manual_test',
    'parts', 'database', 'emulator', 'code', 'reference', 'research', 'catver'
)
$validWheelSupport = @('native', 'partial', 'none', 'unknown')
$validFFB = @('native', 'partial', 'none', 'unknown')
$validControllerSupport = @('full', 'partial', 'none')

# ============================================================
# Check 1: Top-level required fields
# ============================================================
Write-Host "[Check 1] Top-level fields..." -ForegroundColor Yellow
foreach ($field in @('version', 'generated', 'games')) {
    if (-not $db.PSObject.Properties[$field]) {
        Write-Host "  ERROR: Missing top-level field '$field'" -ForegroundColor Red
        $errors++
    }
}
if ($errors -eq 0) { Write-Host "  Pass" -ForegroundColor Green }

# ============================================================
# Check 2: Required fields per entry
# ============================================================
Write-Host "[Check 2] Required fields per entry..." -ForegroundColor Yellow
$requiredFields = @('title', 'confidence', 'sources', 'platforms')
$check2Errors = 0
foreach ($prop in $gameProps) {
    $game = $prop.Value
    $gp = $game.PSObject.Properties
    foreach ($field in $requiredFields) {
        if (-not $gp[$field]) {
            Write-Host "  ERROR: Missing '$field' in '$($prop.Name)'" -ForegroundColor Red
            $errors++; $check2Errors++
        }
    }
    # rotation_degrees must exist as a property (can be null)
    if (-not $gp['rotation_degrees']) {
        Write-Host "  ERROR: Missing 'rotation_degrees' in '$($prop.Name)'" -ForegroundColor Red
        $errors++; $check2Errors++
    }
}
if ($check2Errors -eq 0) { Write-Host "  Pass" -ForegroundColor Green }

# ============================================================
# Check 3: Enum values
# ============================================================
Write-Host "[Check 3] Enum values..." -ForegroundColor Yellow
$check3Errors = 0
foreach ($prop in $gameProps) {
    $game = $prop.Value
    $gp = $game.PSObject.Properties
    $label = "'$($prop.Name)'"

    # rotation_type (nullable)
    if ($gp['rotation_type'] -and $null -ne $game.rotation_type) {
        if ($game.rotation_type -notin $validRotationType) {
            Write-Host "  ERROR: Invalid rotation_type '$($game.rotation_type)' in $label" -ForegroundColor Red
            $errors++; $check3Errors++
        }
    }

    # confidence
    if ($gp['confidence'] -and $game.confidence -notin $validConfidence) {
        Write-Host "  ERROR: Invalid confidence '$($game.confidence)' in $label" -ForegroundColor Red
        $errors++; $check3Errors++
    }

    # source types
    if ($game.sources) {
        foreach ($src in $game.sources) {
            if ($src.type -and $src.type -notin $validSourceTypes) {
                Write-Host "  ERROR: Invalid source type '$($src.type)' in $label" -ForegroundColor Red
                $errors++; $check3Errors++
            }
        }
    }

    # pc sub-object enums
    if ($gp['pc'] -and $null -ne $game.pc) {
        $pc = $game.pc
        $pp = $pc.PSObject.Properties
        if ($pp['wheel_support'] -and $pc.wheel_support -notin $validWheelSupport) {
            Write-Host "  ERROR: Invalid pc.wheel_support '$($pc.wheel_support)' in $label" -ForegroundColor Red
            $errors++; $check3Errors++
        }
        if ($pp['force_feedback'] -and $pc.force_feedback -notin $validFFB) {
            Write-Host "  ERROR: Invalid pc.force_feedback '$($pc.force_feedback)' in $label" -ForegroundColor Red
            $errors++; $check3Errors++
        }
        if ($pp['controller_support'] -and $null -ne $pc.controller_support) {
            if ($pc.controller_support -notin $validControllerSupport) {
                Write-Host "  ERROR: Invalid pc.controller_support '$($pc.controller_support)' in $label" -ForegroundColor Red
                $errors++; $check3Errors++
            }
        }
    }
}
if ($check3Errors -eq 0) { Write-Host "  Pass" -ForegroundColor Green }

# ============================================================
# Check 4: Rotation values
# ============================================================
Write-Host "[Check 4] Rotation values..." -ForegroundColor Yellow
$check4Errors = 0
foreach ($prop in $gameProps) {
    $game = $prop.Value
    if ($null -ne $game.rotation_degrees) {
        $rot = $game.rotation_degrees
        if ($rot -eq -1) { continue }  # infinite rotation is valid
        if ($rot -lt 45 -or $rot -gt 1080) {
            Write-Host "  ERROR: Invalid rotation $rot in '$($prop.Name)' (must be -1, 45-1080, or null)" -ForegroundColor Red
            $errors++; $check4Errors++
        }
    }
}
if ($check4Errors -eq 0) { Write-Host "  Pass" -ForegroundColor Green }

# ============================================================
# Check 5: Sources non-empty
# ============================================================
Write-Host "[Check 5] Sources non-empty..." -ForegroundColor Yellow
$check5Errors = 0
foreach ($prop in $gameProps) {
    $game = $prop.Value
    if (-not $game.sources -or @($game.sources).Count -eq 0) {
        Write-Host "  ERROR: Empty sources in '$($prop.Name)'" -ForegroundColor Red
        $errors++; $check5Errors++
    }
}
if ($check5Errors -eq 0) { Write-Host "  Pass" -ForegroundColor Green }

# ============================================================
# Check 6: No duplicate Steam appids
# ============================================================
Write-Host "[Check 6] Unique Steam appids..." -ForegroundColor Yellow
$steamAppids = @{}
$check6Errors = 0
foreach ($prop in $gameProps) {
    $game = $prop.Value
    $plats = $game.platforms
    if ($plats -and $plats.PSObject.Properties['steam'] -and $plats.steam) {
        $appid = $plats.steam.appid
        if ($steamAppids.ContainsKey($appid)) {
            Write-Host "  ERROR: Duplicate Steam appid $appid in '$($prop.Name)' and '$($steamAppids[$appid])'" -ForegroundColor Red
            $errors++; $check6Errors++
        } else {
            $steamAppids[$appid] = $prop.Name
        }
    }
}
if ($check6Errors -eq 0) { Write-Host "  Pass ($($steamAppids.Count) Steam entries)" -ForegroundColor Green }

# ============================================================
# Check 7: No duplicate MAME romnames
# ============================================================
Write-Host "[Check 7] Unique MAME romnames..." -ForegroundColor Yellow
$mameRoms = @{}
$check7Errors = 0
foreach ($prop in $gameProps) {
    $game = $prop.Value
    $plats = $game.platforms
    if ($plats -and $plats.PSObject.Properties['mame'] -and $plats.mame) {
        # Collect all ROM names (singular romname or romnames array)
        $roms = @()
        if ($plats.mame.PSObject.Properties['romnames'] -and $plats.mame.romnames) {
            $roms = @($plats.mame.romnames)
        } elseif ($plats.mame.PSObject.Properties['romname'] -and $plats.mame.romname) {
            $roms = @($plats.mame.romname)
        }
        foreach ($rom in $roms) {
            if ($mameRoms.ContainsKey($rom)) {
                Write-Host "  ERROR: Duplicate MAME romname '$rom' in '$($prop.Name)' and '$($mameRoms[$rom])'" -ForegroundColor Red
                $errors++; $check7Errors++
            } else {
                $mameRoms[$rom] = $prop.Name
            }
        }
    }
}
if ($check7Errors -eq 0) { Write-Host "  Pass ($($mameRoms.Count) MAME entries)" -ForegroundColor Green }

# ============================================================
# Check 8: Infinite rotation must be optical_encoder
# ============================================================
Write-Host "[Check 8] Infinite rotation type consistency..." -ForegroundColor Yellow
$check8Errors = 0
foreach ($prop in $gameProps) {
    $game = $prop.Value
    if ($game.rotation_degrees -eq -1 -and $game.PSObject.Properties['rotation_type'] -and $game.rotation_type -ne 'optical_encoder') {
        Write-Host "  ERROR: rotation=-1 but type='$($game.rotation_type)' in '$($prop.Name)' (must be optical_encoder)" -ForegroundColor Red
        $errors++; $check8Errors++
    }
}
if ($check8Errors -eq 0) { Write-Host "  Pass" -ForegroundColor Green }

# ============================================================
# Check 9: Steam entries should have pc sub-object
# ============================================================
Write-Host "[Check 9] Steam entries have pc metadata..." -ForegroundColor Yellow
$check9Warnings = 0
foreach ($prop in $gameProps) {
    $game = $prop.Value
    if ($game.platforms.PSObject.Properties['steam'] -and (-not $game.PSObject.Properties['pc'] -or $null -eq $game.pc)) {
        Write-Host "  WARN: Steam entry '$($prop.Name)' has no pc sub-object" -ForegroundColor DarkYellow
        $warnings++; $check9Warnings++
    }
}
if ($check9Warnings -eq 0) { Write-Host "  Pass" -ForegroundColor Green }

# ============================================================
# Check 10: pc entries should have a PC-playable platform (Steam or PCSX2)
# ============================================================
Write-Host "[Check 10] pc metadata has PC-playable platform..." -ForegroundColor Yellow
$check10Warnings = 0
foreach ($prop in $gameProps) {
    $game = $prop.Value
    if ($game.PSObject.Properties['pc'] -and $null -ne $game.pc) {
        $hasPcPlatform = $game.platforms.PSObject.Properties['steam'] -or $game.platforms.PSObject.Properties['pcsx2']
        if (-not $hasPcPlatform) {
            Write-Host "  WARN: '$($prop.Name)' has pc metadata but no Steam or PCSX2 platform" -ForegroundColor DarkYellow
            $warnings++; $check10Warnings++
        }
    }
}
if ($check10Warnings -eq 0) { Write-Host "  Pass" -ForegroundColor Green }

# ============================================================
# Statistics
# ============================================================
$withRotation = 0; $withNull = 0; $withInfinite = 0
$hasMame = 0; $hasSteam = 0; $hasTP = 0; $hasPcsx2 = 0; $hasPc = 0
$rotationValues = @{}

foreach ($prop in $gameProps) {
    $game = $prop.Value
    $gp = $game.PSObject.Properties
    $plats = $game.platforms

    if ($null -eq $game.rotation_degrees) { $withNull++ }
    elseif ($game.rotation_degrees -eq -1) { $withInfinite++ }
    else {
        $withRotation++
        $deg = $game.rotation_degrees.ToString()
        if (-not $rotationValues.ContainsKey($deg)) { $rotationValues[$deg] = 0 }
        $rotationValues[$deg]++
    }

    if ($plats.PSObject.Properties['mame']) { $hasMame++ }
    if ($plats.PSObject.Properties['steam']) { $hasSteam++ }
    if ($plats.PSObject.Properties['teknoparrot']) { $hasTP++ }
    if ($plats.PSObject.Properties['pcsx2']) { $hasPcsx2++ }
    if ($gp['pc'] -and $null -ne $game.pc) { $hasPc++ }
}

Write-Host ""
Write-Host "=== Database Statistics ===" -ForegroundColor Cyan
Write-Host "  Total games:        $gameCount"
Write-Host "  With rotation:      $withRotation"
Write-Host "  Unknown rotation:   $withNull"
Write-Host "  Infinite rotation:  $withInfinite"
Write-Host ""
Write-Host "  Platform breakdown:"
Write-Host "    MAME:             $hasMame"
Write-Host "    TeknoParrot:      $hasTP"
Write-Host "    Steam:            $hasSteam"
Write-Host "    PCSX2:            $hasPcsx2"
Write-Host "    With PC metadata: $hasPc"
Write-Host ""
Write-Host "  Rotation distribution:"
$rotationValues.GetEnumerator() | Sort-Object { [int]$_.Key } | ForEach-Object {
    Write-Host "    $($_.Key) degrees: $($_.Value) games"
}

# PC-specific stats
if ($hasPc -gt 0) {
    $nativeWheel = 0; $partialWheel = 0; $noWheel = 0
    $nativeFFB = 0; $partialFFB = 0; $noFFB = 0
    foreach ($prop in $gameProps) {
        $game = $prop.Value
        if ($game.PSObject.Properties['pc'] -and $null -ne $game.pc) {
            switch ($game.pc.wheel_support) {
                'native'  { $nativeWheel++ }
                'partial' { $partialWheel++ }
                'none'    { $noWheel++ }
            }
            switch ($game.pc.force_feedback) {
                'native'  { $nativeFFB++ }
                'partial' { $partialFFB++ }
                'none'    { $noFFB++ }
            }
        }
    }
    Write-Host ""
    Write-Host "  PC Wheel Support:   native=$nativeWheel  partial=$partialWheel  none=$noWheel"
    Write-Host "  PC Force Feedback:  native=$nativeFFB  partial=$partialFFB  none=$noFFB"
}

Write-Host ""
Write-Host "=== Validation Summary ===" -ForegroundColor Cyan
if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "  PASS - Database is valid ($gameCount games)" -ForegroundColor Green
    exit 0
} elseif ($errors -eq 0) {
    Write-Host "  PASS - Database is valid ($gameCount games, $warnings warning(s))" -ForegroundColor Green
    exit 0
} else {
    Write-Host "  FAIL - Found $errors error(s), $warnings warning(s)" -ForegroundColor Red
    exit 1
}
