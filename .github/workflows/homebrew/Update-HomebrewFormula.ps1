<#
.SYNOPSIS
    Updates the Homebrew formula from the brew.template by substituting version, repo, and SHA256 values.

.PARAMETER Version
    The release version (e.g., 0.1.0).

.PARAMETER Repo
    The target GitHub repository (e.g., microsoft/modernize-cli).

.PARAMETER AssetsPath
    Path to directory containing the downloaded .tar.gz release assets.

.PARAMETER OutputPath
    Path to write the generated Formula/modernize.rb file.

.EXAMPLE
    ./Update-HomebrewFormula.ps1 -Version 0.1.0 -Repo microsoft/modernize-cli -AssetsPath ./assets -OutputPath ./Formula/modernize.rb
#>
param(
    [Parameter(Mandatory)]
    [string]$Version,

    [Parameter(Mandatory)]
    [string]$Repo,

    [Parameter(Mandatory)]
    [string]$AssetsPath,

    [Parameter(Mandatory)]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

$templatePath = Join-Path $PSScriptRoot 'brew.template'
if (-not (Test-Path $templatePath)) {
    Write-Error "Template not found at $templatePath"
    exit 1
}

# Compute SHA256 for each platform asset
$platforms = @{
    'DARWIN_X64_SHA256'   = "modernize_${Version}_darwin_x64.tar.gz"
    'DARWIN_ARM64_SHA256' = "modernize_${Version}_darwin_arm64.tar.gz"
    'LINUX_X64_SHA256'    = "modernize_${Version}_linux_x64.tar.gz"
    'LINUX_ARM64_SHA256'  = "modernize_${Version}_linux_arm64.tar.gz"
}

$checksums = @{}
foreach ($entry in $platforms.GetEnumerator()) {
    $assetFile = Join-Path $AssetsPath $entry.Value
    if (-not (Test-Path $assetFile)) {
        Write-Error "Asset not found: $assetFile"
        exit 1
    }
    $hash = (Get-FileHash -Path $assetFile -Algorithm SHA256).Hash.ToLower()
    $checksums[$entry.Key] = $hash
    Write-Host "$($entry.Value): $hash"
}

# Read template and substitute placeholders using literal string replacement
$content = Get-Content -Path $templatePath -Raw
$content = $content.Replace('{{VERSION}}', $Version)
$content = $content.Replace('{{REPO}}', $Repo)
$content = $content.Replace('{{DARWIN_X64_SHA256}}', $checksums['DARWIN_X64_SHA256'])
$content = $content.Replace('{{DARWIN_ARM64_SHA256}}', $checksums['DARWIN_ARM64_SHA256'])
$content = $content.Replace('{{LINUX_X64_SHA256}}', $checksums['LINUX_X64_SHA256'])
$content = $content.Replace('{{LINUX_ARM64_SHA256}}', $checksums['LINUX_ARM64_SHA256'])

# Ensure output directory exists
$outputDir = Split-Path -Parent $OutputPath
if ($outputDir -and -not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Set-Content -Path $OutputPath -Value $content
Write-Host "Formula written to $OutputPath"
