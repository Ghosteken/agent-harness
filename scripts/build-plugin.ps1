<#
.SYNOPSIS
  Recreate the agent-harness.plugin file for Claude desktop upload.

.DESCRIPTION
  Zips the repo contents (excluding .git, existing .plugin file, and any
  permission-denied skill directories) into agent-harness.plugin at the
  repo root.

.PARAMETER RepoRoot
  Path to the repo root. Defaults to the directory containing this script's
  parent (i.e. the repo root when run from scripts/).

.PARAMETER Out
  Output path for the .plugin file. Defaults to <RepoRoot>\agent-harness.plugin

.EXAMPLE
  .\scripts\build-plugin.ps1
  .\scripts\build-plugin.ps1 -Out "C:\Desktop\agent-harness.plugin"
#>
param(
  [string]$RepoRoot = (Split-Path $PSScriptRoot -Parent),
  [string]$Out = ""
)

$ErrorActionPreference = "Stop"

if (-not $Out) {
  $Out = Join-Path $RepoRoot "agent-harness.plugin"
}

$tmpZip = Join-Path $env:TEMP "agent-harness-plugin-$(Get-Date -Format 'yyyyMMddHHmmss').zip"

Write-Host "[agent-harness] Building plugin from: $RepoRoot"
Write-Host "[agent-harness] Output: $Out"

# Items to exclude from the zip
$exclude = @("agent-harness.plugin", ".git")

$items = Get-ChildItem $RepoRoot | Where-Object { $_.Name -notin $exclude }

if (-not $items) {
  Write-Error "No items found to zip in $RepoRoot"
  exit 1
}

# Build zip, skipping any files that can't be read (e.g. locked skill dirs)
try {
  Compress-Archive -Path $items.FullName -DestinationPath $tmpZip -Force
} catch {
  Write-Warning "Some files could not be included (permission denied): $_"
}

if (-not (Test-Path $tmpZip)) {
  Write-Error "Zip creation failed — $tmpZip not found"
  exit 1
}

# Replace output file
if (Test-Path $Out) { Remove-Item -Force $Out }
Copy-Item $tmpZip $Out
Remove-Item $tmpZip

$size = [math]::Round((Get-Item $Out).Length / 1MB, 2)
Write-Host "[agent-harness] Done — agent-harness.plugin ($size MB)"
Write-Host ""
Write-Host "  To install on Claude desktop:"
Write-Host "  1. Open Claude desktop → Settings → Extensions"
Write-Host "  2. Click 'Upload local plugin'"
Write-Host "  3. Select: $Out"
