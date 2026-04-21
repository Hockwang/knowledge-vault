# Single-direction hard sync: source project docs/ -> mirror/<project>/
# Any edits in mirror/ will be overwritten on the next sync.
#
# Usage:
#   .\scripts\sync.ps1          # sync all projects in vault-config.yml
#
# Requires: Windows PowerShell 5.1+ (robocopy is built-in)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VaultRoot = Split-Path -Parent $ScriptDir
$Config    = Join-Path $ScriptDir 'vault-config.yml'

if (-not (Test-Path $Config)) {
    Write-Host "Error: $Config not found." -ForegroundColor Red
    Write-Host "Copy vault-config.example.yml to vault-config.yml and fill in your project paths." -ForegroundColor Red
    exit 1
}

# Minimal YAML parse — matches the layout in vault-config.example.yml only.
$projects = @()
$current = $null
foreach ($line in Get-Content $Config) {
    # strip inline comments
    $clean = $line -replace '\s*#.*$', ''

    if ($clean -match '^\s*-\s*name:\s*(.+?)\s*$') {
        if ($current) { $projects += $current }
        $current = @{ name = $Matches[1].Trim() }
    }
    elseif ($clean -match '^\s*source:\s*(.+?)\s*$' -and $current) {
        $current.source = $Matches[1].Trim()
    }
}
if ($current) { $projects += $current }

if ($projects.Count -eq 0) {
    Write-Host "No projects found in vault-config.yml." -ForegroundColor Red
    exit 1
}

$count = 0
foreach ($p in $projects) {
    if (-not $p.ContainsKey('source')) {
        Write-Host "Warning: project '$($p.name)' has no source, skipping" -ForegroundColor Yellow
        continue
    }

    $source = $p.source
    if (-not (Test-Path $source -PathType Container)) {
        Write-Host "Warning: source for '$($p.name)' does not exist: $source (skipping)" -ForegroundColor Yellow
        continue
    }

    $target = Join-Path $VaultRoot "mirror\$($p.name)"
    Write-Host "-> $($p.name): $source -> mirror\$($p.name)\"
    New-Item -ItemType Directory -Path $target -Force | Out-Null

    # /MIR = mirror (includes /E copies + /PURGE deletes extras in dest)
    # /NFL /NDL /NJH /NJS = quiet output (no file/dir lists, no job headers/summaries)
    # /R:1 /W:1 = retry once with 1-second wait on failures
    & robocopy $source $target /MIR /NFL /NDL /NJH /NJS /R:1 /W:1 | Out-Null

    # robocopy exit codes 0-7 are "success variants" (files copied, no errors);
    # 8+ indicates actual failure. Reset $LASTEXITCODE so pipeline continues.
    if ($LASTEXITCODE -ge 8) {
        Write-Host "robocopy failed for $($p.name) with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
    $count++
}

Write-Host ""
Write-Host "Synced $count project(s). Now tell Claude Code to start processing."
Write-Host "Trigger phrase is in CLAUDE.md (Chinese) / AGENT-GUIDE.md."
