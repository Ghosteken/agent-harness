<#
.SYNOPSIS
  Recreate the agent-harness.plugin file for Claude desktop upload.

.DESCRIPTION
  Builds the zip via `git archive` from the current commit — the exclude
  list lives in .gitattributes (export-ignore), not in this script. This
  replaces an earlier manual Copy-Item/Compress-Archive staging approach
  that behaved inconsistently between Windows PowerShell 5.1 (.NET
  Framework, used locally) and pwsh (.NET Core, used in CI): it silently
  produced a near-empty archive under pwsh with no error surfaced. git's
  own archive writer is a single, well-tested code path on every runtime.

  Note: `git archive` zips the current commit, not uncommitted working-tree
  changes — commit first if you need those reflected in the build.

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

Write-Host "[agent-harness] Building plugin from: $RepoRoot"
Write-Host "[agent-harness] Output: $Out"

if (Test-Path $Out) {
  Remove-Item -Force $Out
}

& git -C $RepoRoot archive --format=zip --worktree-attributes -o $Out HEAD
if ($LASTEXITCODE -ne 0) {
  throw "git archive failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path $Out)) {
  throw "Zip creation failed - $Out not found"
}

# Self-verify: reopen the zip we just wrote and confirm it actually contains
# the skills currently on disk, before ever treating this as a valid build.
Add-Type -AssemblyName System.IO.Compression

$liveSkillCount = @(Get-ChildItem -Path (Join-Path $RepoRoot "skills") -Directory |
  Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }).Count

$verifyStream = [System.IO.File]::OpenRead($Out)
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
  Remove-Item -Force $Out -ErrorAction SilentlyContinue
  throw "Build verification failed: zip contains $zippedSkillCount skill(s) but skills/ has $liveSkillCount on disk (uncommitted changes? git archive only zips HEAD). Not leaving a broken output file in place."
}
Write-Host "[agent-harness] Verified: $zippedSkillCount skills bundled, matching skills/ on disk."

$size = [math]::Round((Get-Item $Out).Length / 1MB, 2)
Write-Host "[agent-harness] Done - agent-harness.plugin ($size MB)"
Write-Host ""
Write-Host "  To install on Claude desktop:"
Write-Host "  1. Open Claude desktop -> Settings -> Extensions"
Write-Host "  2. Click 'Upload local plugin'"
Write-Host "  3. Select: $Out"
