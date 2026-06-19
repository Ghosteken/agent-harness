<#
.SYNOPSIS
  Recreate the agent-harness.plugin file for Claude desktop upload.

.DESCRIPTION
  Zips the repo contents (excluding .git and the existing .plugin file)
  into agent-harness.plugin at the repo root.

.PARAMETER RepoRoot
  Path to the repo root. Defaults to the parent of the scripts/ directory.

.PARAMETER Out
  Output path for the .plugin file. Defaults to <RepoRoot>\agent-harness.plugin

.EXAMPLE
  .\scripts\build-plugin.ps1
  .\scripts\build-plugin.ps1 -Out "C:\Users\ASUS\Desktop\agent-harness.plugin"
#>
param(
  [string]$RepoRoot = (Split-Path $PSScriptRoot -Parent),
  [string]$Out = ""
)

$ErrorActionPreference = "Stop"

if (-not $Out) {
  $Out = Join-Path $RepoRoot "agent-harness.plugin"
}

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$tmpZip = Join-Path $env:TEMP "agent-harness-plugin-$timestamp.zip"

Write-Host "[agent-harness] Building plugin from: $RepoRoot"
Write-Host "[agent-harness] Output: $Out"

# Collect items, excluding .git and existing .plugin
$exclude = @("agent-harness.plugin", ".git")
$items = Get-ChildItem $RepoRoot | Where-Object { $_.Name -notin $exclude }

if (-not $items) {
  Write-Host "ERROR: No items found to zip in $RepoRoot"
  exit 1
}

# Zip the items (skip anything that can't be read)
try {
  Compress-Archive -Path $items.FullName -DestinationPath $tmpZip -Force
} catch {
  Write-Warning "Some files could not be included: $_"
}

if (-not (Test-Path $tmpZip)) {
  Write-Host "ERROR: Zip creation failed - $tmpZip not found"
  exit 1
}

# Replace output file
if (Test-Path $Out) {
  Remove-Item -Force $Out
}
Copy-Item $tmpZip $Out
Remove-Item $tmpZip

$size = [math]::Round((Get-Item $Out).Length / 1MB, 2)
Write-Host "[agent-harness] Done - agent-harness.plugin ($size MB)"
Write-Host ""
Write-Host "  To install on Claude desktop:"
Write-Host "  1. Open Claude desktop -> Settings -> Extensions"
Write-Host "  2. Click 'Upload local plugin'"
Write-Host "  3. Select: $Out"
