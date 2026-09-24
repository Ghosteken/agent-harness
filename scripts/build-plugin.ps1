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
$stageDir = Join-Path $env:TEMP "agent-harness-plugin-stage-$timestamp"

Write-Host "[agent-harness] Building plugin from: $RepoRoot"
Write-Host "[agent-harness] Output: $Out"

# Collect items, excluding .git, the existing .plugin, and archive/ (pre-prune bulk content not meant to ship)
$exclude = @("agent-harness.plugin", ".git", "archive")
$items = Get-ChildItem $RepoRoot | Where-Object { $_.Name -notin $exclude }

if (-not $items) {
  Write-Host "ERROR: No items found to zip in $RepoRoot"
  exit 1
}

# Stage into a temp copy so we can drop local-only files (e.g. .claude/settings.local.json)
# without touching the real working tree.
New-Item -ItemType Directory -Force -Path $stageDir | Out-Null
foreach ($item in $items) {
  Copy-Item -Path $item.FullName -Destination (Join-Path $stageDir $item.Name) -Recurse -Force
}
Get-ChildItem -Path $stageDir -Recurse -Filter "settings.local.*" -File | Remove-Item -Force

$stagedItems = Get-ChildItem $stageDir

# Build the zip entry-by-entry with explicit forward-slash names, using only
# the base ZipArchive class (not the ZipFile/ZipFileExtensions static helpers,
# which have been observed to resolve inconsistently between Windows
# PowerShell 5.1's .NET Framework and pwsh's .NET Core — a CI run under pwsh
# silently produced a near-empty archive with no error or warning surfaced).
# ZipArchive itself is a plain BCL type with identical behavior on both
# runtimes. $ErrorActionPreference = "Stop" above ensures any failure here
# actually aborts the script instead of being swallowed.
Add-Type -AssemblyName System.IO.Compression
if (Test-Path $tmpZip) { Remove-Item -Force $tmpZip }

$files = @(Get-ChildItem -Path $stageDir -Recurse -File)
if ($files.Count -eq 0) {
  Remove-Item -Recurse -Force $stageDir -ErrorAction SilentlyContinue
  throw "No files found to zip in staged directory $stageDir"
}

$fileStream = [System.IO.File]::Open($tmpZip, [System.IO.FileMode]::Create)
try {
  $archive = New-Object System.IO.Compression.ZipArchive($fileStream, [System.IO.Compression.ZipArchiveMode]::Create)
  try {
    foreach ($file in $files) {
      $relativePath = $file.FullName.Substring($stageDir.Length + 1) -replace '\\', '/'
      $entry = $archive.CreateEntry($relativePath, [System.IO.Compression.CompressionLevel]::Optimal)
      $entryStream = $entry.Open()
      try {
        $srcStream = [System.IO.File]::OpenRead($file.FullName)
        try { $srcStream.CopyTo($entryStream) } finally { $srcStream.Dispose() }
      } finally {
        $entryStream.Dispose()
      }
    }
  } finally {
    $archive.Dispose()
  }
} finally {
  $fileStream.Dispose()
  Remove-Item -Recurse -Force $stageDir -ErrorAction SilentlyContinue
}

if (-not (Test-Path $tmpZip)) {
  Write-Host "ERROR: Zip creation failed - $tmpZip not found"
  exit 1
}

# Self-verify: reopen the zip we just wrote and confirm it actually contains
# the skills we just zipped, before it ever gets treated as a valid build.
# Guards against a repeat of the above: a zip step that reports success while
# silently producing broken/partial content.
$liveSkillCount = @(Get-ChildItem -Path (Join-Path $RepoRoot "skills") -Directory |
  Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }).Count

$verifyStream = [System.IO.File]::OpenRead($tmpZip)
try {
  $verifyArchive = New-Object System.IO.Compression.ZipArchive($verifyStream, [System.IO.Compression.ZipArchiveMode]::Read)
  try {
    $zippedSkillCount = @($verifyArchive.Entries | Where-Object { $_.FullName -match '^skills/[^/]+/SKILL\.md$' }).Count
  } finally {
    $verifyArchive.Dispose()
  }
} finally {
  $verifyStream.Dispose()
}

if ($zippedSkillCount -ne $liveSkillCount) {
  Remove-Item -Force $tmpZip -ErrorAction SilentlyContinue
  throw "Build verification failed: zip contains $zippedSkillCount skill(s) but skills/ has $liveSkillCount. Not writing a broken output file."
}
Write-Host "[agent-harness] Verified: $zippedSkillCount skills bundled, matching skills/ on disk."

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
