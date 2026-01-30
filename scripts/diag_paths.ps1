param()

# Diagnostics helper: set diagnostics directory and helper to resolve paths
try {
    $repoRoot = Resolve-Path -Path (Join-Path $PSScriptRoot '..')
} catch {
    $repoRoot = (Get-Location).Path
}

$DiagnosticsDir = Join-Path $repoRoot 'diagnostics_untracked'
if (-not (Test-Path $DiagnosticsDir)) { New-Item -ItemType Directory -Path $DiagnosticsDir -Force | Out-Null }

function Get-DiagPath {
    param([string]$RelativePath)
    $clean = $RelativePath -replace '^\.\/?','' -replace '^\\',''
    $full = Join-Path $DiagnosticsDir $clean
    $parent = Split-Path $full -Parent
    if ($parent -and -not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    return $full
}

Set-Variable -Name DiagnosticsDir -Value $DiagnosticsDir -Scope Script -Force
