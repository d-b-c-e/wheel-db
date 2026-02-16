Set-StrictMode -Version Latest

# Cross-platform linking: merge duplicate entries and consolidate regional variants
# 2026-02-15

$dbPath = 'E:\Source\wheel-rotation-db\data\wheel-db.json'
$db = Get-Content -Raw $dbPath | ConvertFrom-Json
$today = '2026-02-15'
$changes = @()

# Helper: remove an entry by slug
function Remove-Entry($slug) {
    $db.games.PSObject.Properties.Remove($slug)
}

# ===================================================================
# 1. Merge OutRun 2 SP SDX: TeknoParrot (outrun2_sp_sdx) + MAME (outrun_2_sp_sdx)
# ===================================================================
$keeper = $db.games.outrun2_sp_sdx
$mameEntry = $db.games.outrun_2_sp_sdx
if ($keeper -and $mameEntry) {
    # Add MAME platform to keeper
    $keeper.platforms | Add-Member -NotePropertyName 'mame' -NotePropertyValue ([PSCustomObject]@{
        romname = $mameEntry.platforms.mame.romname
        clones_inherit = $true
    }) -Force
    Remove-Entry 'outrun_2_sp_sdx'
    $changes += "MERGED: outrun_2_sp_sdx into outrun2_sp_sdx (added mame romname 'outr2sdx')"
} else {
    Write-Host "WARNING: Could not find both outrun entries"
}

# ===================================================================
# 2. Merge Initial D Stage 4: TeknoParrot (initial_d_4) + MAME (initial_d4)
# ===================================================================
$keeper = $db.games.initial_d_4
$mameEntry = $db.games.initial_d4
if ($keeper -and $mameEntry) {
    $keeper.platforms | Add-Member -NotePropertyName 'mame' -NotePropertyValue ([PSCustomObject]@{
        romname = $mameEntry.platforms.mame.romname
        clones_inherit = $true
    }) -Force
    Remove-Entry 'initial_d4'
    $changes += "MERGED: initial_d4 into initial_d_4 (added mame romname 'initiad4')"
} else {
    Write-Host "WARNING: Could not find both Initial D4 entries"
}

# ===================================================================
# 3. Merge Power Drift: pdrift (power-drift) + pdriftl (powerdrift)
# ===================================================================
$keeper = $db.games.PSObject.Properties['power-drift']
$dup = $db.games.PSObject.Properties['powerdrift']
if ($keeper -and $dup) {
    $kv = $keeper.Value
    $dv = $dup.Value
    # Convert to romnames array with both ROM sets
    $kv.platforms.mame = [PSCustomObject]@{
        romnames = @('pdrift', 'pdriftl')
        clones_inherit = $true
    }
    # Merge notes
    $kv.notes = "Sega Y Board (Super Scaler). Go-kart racing by Yu Suzuki. Deluxe cab has hydraulics. Uses gear/cog steering system with FFB. pdriftl is the Link (multi-cab) version."
    # Rename slug from power-drift to power_drift for consistency
    $db.games.PSObject.Properties.Remove('power-drift')
    $db.games | Add-Member -NotePropertyName 'power_drift' -NotePropertyValue $kv -Force
    Remove-Entry 'powerdrift'
    $changes += "MERGED: powerdrift into power_drift (renamed from power-drift, added romname 'pdriftl')"
} else {
    Write-Host "WARNING: Could not find both Power Drift entries"
}

# ===================================================================
# 4. Consolidate Initial D MAME regional variants
# ===================================================================

# --- Stage 1 (2002): merge initd + initdexp ---
$stage1 = $db.games.initial_d_arcade_stage
$stage1exp = $db.games.PSObject.Properties['initial_d_arcade_stage_export_rev_a_gds0']
if ($stage1 -and $stage1exp) {
    $stage1.title = "Initial D Arcade Stage"
    $stage1.rotation_degrees = 540
    $stage1.rotation_type = 'mechanical_stop'
    $stage1.confidence = 'medium'
    $stage1.sources = @(
        [PSCustomObject]@{
            type = 'inference'
            description = "Initial D series uses 540-degree steering (confirmed on Stages 4-8 via TeknoParrot metadata). Stages 1-3 use same Sega NAOMI cabinet steering."
            url = $null
            date_accessed = $today
        }
    )
    $stage1.notes = "Sega NAOMI GD-ROM. First game in the Initial D Arcade Stage series. Japan (initd) and Export (initdexp) versions."
    $stage1.platforms.mame = [PSCustomObject]@{
        romnames = @('initd', 'initdexp')
        clones_inherit = $true
    }
    $stage1.platforms | Add-Member -NotePropertyName 'flycast' -NotePropertyValue ([PSCustomObject]@{
        romname = 'initd'
    }) -Force
    Remove-Entry 'initial_d_arcade_stage_export_rev_a_gds0'
    $changes += "CONSOLIDATED: Initial D Stage 1 (merged initdexp, added flycast, set 540 deg)"
}

# --- Stage 2 (2003): update in place ---
$stage2 = $db.games.initial_d_arcade_stage_ver_2
if ($stage2) {
    $stage2.title = "Initial D Arcade Stage Ver. 2"
    $stage2.rotation_degrees = 540
    $stage2.rotation_type = 'mechanical_stop'
    $stage2.confidence = 'medium'
    $stage2.sources = @(
        [PSCustomObject]@{
            type = 'inference'
            description = "Initial D series uses 540-degree steering (confirmed on Stages 4-8 via TeknoParrot metadata). Same Sega NAOMI cabinet."
            url = $null
            date_accessed = $today
        }
    )
    $stage2.notes = "Sega NAOMI GD-ROM. Second game in the Initial D Arcade Stage series."
    $stage2.platforms | Add-Member -NotePropertyName 'flycast' -NotePropertyValue ([PSCustomObject]@{
        romname = 'initdv2j'
    }) -Force
    $changes += "UPDATED: Initial D Stage 2 (added flycast, set 540 deg)"
}

# --- Stage 3 (2004): merge initdv3j + initdv3e + inidv3cy ---
$stage3 = $db.games.initial_d_arcade_stage_ver_3
$stage3exp = $db.games.PSObject.Properties['initial_d_arcade_stage_ver_3_export_gds0']
$stage3cy = $db.games.PSObject.Properties['initial_d_arcade_stage_ver_3_cycraft_edi']
if ($stage3 -and $stage3exp -and $stage3cy) {
    $stage3.title = "Initial D Arcade Stage Ver. 3"
    $stage3.rotation_degrees = 540
    $stage3.rotation_type = 'mechanical_stop'
    $stage3.confidence = 'medium'
    $stage3.sources = @(
        [PSCustomObject]@{
            type = 'inference'
            description = "Initial D series uses 540-degree steering (confirmed on Stages 4-8 via TeknoParrot metadata). Same Sega NAOMI cabinet."
            url = $null
            date_accessed = $today
        }
    )
    $stage3.notes = "Sega NAOMI GD-ROM. Third game in the series. Japan (initdv3j), Export (initdv3e), and CyCraft motion cabinet (inidv3cy) variants."
    $stage3.platforms.mame = [PSCustomObject]@{
        romnames = @('initdv3j', 'initdv3e', 'inidv3cy')
        clones_inherit = $true
    }
    $stage3.platforms | Add-Member -NotePropertyName 'flycast' -NotePropertyValue ([PSCustomObject]@{
        romname = 'initdv3j'
    }) -Force
    Remove-Entry 'initial_d_arcade_stage_ver_3_export_gds0'
    Remove-Entry 'initial_d_arcade_stage_ver_3_cycraft_edi'
    $changes += "CONSOLIDATED: Initial D Stage 3 (merged 3 entries, added flycast, set 540 deg)"
}

# ===================================================================
# Save
# ===================================================================
$json = $db | ConvertTo-Json -Depth 10
$json = $json -replace '(?m)^\s*\n', ''
[System.IO.File]::WriteAllText($dbPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host "=== Cross-platform merge complete ==="
$changes | ForEach-Object { Write-Host "  $_" }
Write-Host ""
Write-Host "Total entries: $(@($db.games.PSObject.Properties).Count)"
