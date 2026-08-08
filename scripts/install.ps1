<#
.SYNOPSIS
  agent-harness installer for Windows (PowerShell)

.DESCRIPTION
  Installs the agent-harness plugin for Claude Code.

.PARAMETER Global
  Install to $HOME\.claude\plugins\agent-harness\ (all projects)

.PARAMETER Project
  Install to .\.claude\plugins\agent-harness\ in the current directory (default)

.PARAMETER DryRun
  Show what would happen without making any changes

.EXAMPLE
  .\install.ps1                   # project-level install
  .\install.ps1 -Global           # user-level install
  .\install.ps1 -Global -DryRun   # preview global install
#>

[CmdletBinding()]
param(
  [switch]$Global,
  [switch]$Project,
  [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PluginName = 'agent-harness'
$RepoUrl    = 'https://github.com/Ghosteken/agent-harness.git'
$Version    = '1.0.0'

function Write-Info    { param($Msg) Write-Host "[agent-harness] $Msg" -ForegroundColor Cyan }
function Write-Success { param($Msg) Write-Host "[agent-harness] $Msg" -ForegroundColor Green }
function Write-Warn    { param($Msg) Write-Host "[agent-harness] $Msg" -ForegroundColor Yellow }
function Write-Err     { param($Msg) Write-Error "[agent-harness] $Msg" }

function Invoke-Step {
  param([scriptblock]$Action, [string]$Description)
  if ($DryRun) {
    Write-Host "  [dry-run] $Description" -ForegroundColor DarkGray
  } else {
    & $Action
  }
}

# Resolve scope
$UseGlobal = $Global.IsPresent -or (-not $Project.IsPresent)

if ($UseGlobal) {
  $InstallDir   = Join-Path $HOME ".claude\plugins\$PluginName"
  $SettingsFile = Join-Path $HOME ".claude\settings.json"
} else {
  $InstallDir   = Join-Path (Get-Location) ".claude\plugins\$PluginName"
  $SettingsFile = Join-Path (Get-Location) ".claude\settings.json"
}

Write-Info "agent-harness installer v$Version"
Write-Info "Scope:       $(if ($UseGlobal) { 'global' } else { 'project' })"
Write-Info "Install dir: $InstallDir"
Write-Info "Settings:    $SettingsFile"
Write-Host ''

# Check git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Err 'git is not installed or not on PATH. Install Git for Windows: https://git-scm.com/download/win'
}

# Warn about jq
if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
  Write-Warn 'jq is not installed. The session-start hook will degrade gracefully.'
  Write-Warn '  Install via Scoop: scoop install jq'
  Write-Warn '  Or Chocolatey:     choco install jq'
}

# Overwrite check
if ((Test-Path $InstallDir) -and (-not $DryRun)) {
  $confirm = Read-Host "Plugin already exists at $InstallDir. Overwrite? [y/N]"
  if ($confirm -ne 'y') { Write-Info 'Aborted.'; exit 0 }
  Invoke-Step { Remove-Item -Recurse -Force $InstallDir } "Remove existing install at $InstallDir"
}

# Determine source
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Split-Path -Parent $ScriptDir
$LocalPluginJson = Join-Path $RepoRoot '.claude-plugin\plugin.json'

if (Test-Path $LocalPluginJson) {
  Write-Info "Source: local clone at $RepoRoot"
  Invoke-Step {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    Copy-Item -Recurse -Force "$RepoRoot\*" $InstallDir
  } "Copy local files to $InstallDir"
} else {
  Write-Info "Source: cloning from $RepoUrl"
  Invoke-Step {
    git clone --depth 1 $RepoUrl $InstallDir
  } "git clone $RepoUrl $InstallDir"
}

# Register plugin in settings.json
function Register-Plugin {
  param([string]$SettingsPath, [string]$PluginPath)

  if ($DryRun) {
    Write-Host "  [dry-run] Would register plugin in $SettingsPath" -ForegroundColor DarkGray
    return
  }

  $Dir = Split-Path -Parent $SettingsPath
  if (-not (Test-Path $Dir)) { New-Item -ItemType Directory -Force -Path $Dir | Out-Null }

  if (-not (Test-Path $SettingsPath)) {
    '{}' | Set-Content -Path $SettingsPath -Encoding UTF8
  }

  $Settings = Get-Content $SettingsPath -Raw -Encoding UTF8 | ConvertFrom-Json

  # Ensure plugins array exists
  if (-not ($Settings.PSObject.Properties.Name -contains 'plugins')) {
    $Settings | Add-Member -MemberType NoteProperty -Name 'plugins' -Value @()
  }

  # Remove existing entry with same name, then append
  $Settings.plugins = @($Settings.plugins | Where-Object { $_.name -ne $PluginName })
  $Settings.plugins += [PSCustomObject]@{ name = $PluginName; path = $PluginPath }

  $Settings | ConvertTo-Json -Depth 10 | Set-Content -Path $SettingsPath -Encoding UTF8
  Write-Success "Registered plugin in $SettingsPath"
}

Register-Plugin -SettingsPath $SettingsFile -PluginPath $InstallDir

Write-Host ''
Write-Success 'Installation complete!'
Write-Host ''
Write-Host "  Plugin installed to: $InstallDir"
Write-Host ''
Write-Host '  Next steps:'
if ($UseGlobal) {
  Write-Host '    1. Restart Claude Code (or run: claude --reload)'
  Write-Host '    2. Use /spec, /plan, /build, /test, /review, /ship in any project'
} else {
  Write-Host '    1. Restart Claude Code in this project'
  Write-Host '    2. Use /spec, /plan, /build, /test, /review, /ship'
}
Write-Host '    3. See README.md for the full workflow guide'
Write-Host ''
