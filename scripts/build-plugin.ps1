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

$tmpOut = "$Out.tmp"
if (Test-Path $tmpOut) {
  Remove-Item -Force $tmpOut
}

& git -C $RepoRoot archive --format=zip --worktree-attributes -o $tmpOut HEAD
if ($LASTEXITCODE -ne 0) {
  throw "git archive failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path $tmpOut)) {
  throw "Zip creation failed - $tmpOut not found"
}

# Self-verify against git's own committed tree (HEAD), not the raw working
# directory — git archive only ever bundles committed content, so comparing
# against uncommitted disk state produces false failures whenever there's
# WIP. This still catches a genuine zip-writer bug (a HEAD/zip mismatch),
# just not "you have an uncommitted skill" as a false positive.
Add-Type -AssemblyName System.IO.Compression

$headSkillPaths = & git -C $RepoRoot ls-tree -r --name-only HEAD -- skills
$headSkillCount = @($headSkillPaths | Where-Object { $_ -match '^skills/[^/]+/SKILL\.md$' }).Count

$verifyStream = [System.IO.File]::OpenRead($tmpOut)
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

if ($zippedSkillCount -ne $headSkillCount) {
  Remove-Item -Force $tmpOut -ErrorAction SilentlyContinue
  throw "Build verification failed: zip contains $zippedSkillCount skill(s) but HEAD has $headSkillCount. Leaving any existing $Out untouched."
}

# Only replace the real output now that the new build is confirmed good —
# never delete a known-good $Out before the replacement is verified.
if (Test-Path $Out) {
  Remove-Item -Force $Out
}
Move-Item -Force $tmpOut $Out
Write-Host "[agent-harness] Verified: $zippedSkillCount skills bundled, matching HEAD."

$uncommittedSkills = & git -C $RepoRoot status --porcelain -- skills
if ($uncommittedSkills) {
  Write-Host "[agent-harness] Note: skills/ has uncommitted changes — this build reflects HEAD, not your working tree. Commit first if you need those included."
}

$size = [math]::Round((Get-Item $Out).Length / 1MB, 2)
Write-Host "[agent-harness] Done - agent-harness.plugin ($size MB)"
Write-Host ""
Write-Host "  To install on Claude desktop:"
Write-Host "  1. Open Claude desktop -> Settings -> Extensions"
Write-Host "  2. Click 'Upload local plugin'"
Write-Host "  3. Select: $Out"
