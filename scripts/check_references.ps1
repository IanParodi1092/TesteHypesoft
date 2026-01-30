#!/usr/bin/env pwsh
$repo = Get-Location
$patterns = @()
Get-ChildItem -Path . -Filter *.ps1 -File | ForEach-Object {
    $text = Get-Content $_.FullName -Raw
    $m1 = [regex]::Matches($text, '"([^"`n]+?\.(json|txt))"') | ForEach-Object { $_.Groups[1].Value }
    $m2 = [regex]::Matches($text, "'([^'`n]+?\.(json|txt))'") | ForEach-Object { $_.Groups[1].Value }
    foreach ($v in $m1) { $patterns += $v }
    foreach ($v in $m2) { $patterns += $v }
}
$patterns = $patterns | Select-Object -Unique | Sort-Object
Write-Output "Referenced files in scripts (unique):"
$missing = @()
foreach ($ref in $patterns) {
    $refTrim = $ref.Trim()
    $absolute = Join-Path $repo $refTrim
    if (Test-Path $absolute) { Write-Output "OK:   $refTrim" }
    else {
        # try relative to repo root
        $altRoot = (Resolve-Path "$repo\.." -ErrorAction SilentlyContinue)
        $alt = $null
        if ($altRoot) { $alt = Join-Path $altRoot.Path $refTrim }
        if ($alt -and (Test-Path $alt)) { Write-Output "OK(rel): $refTrim -> $alt" }
        else { Write-Output "MISSING: $refTrim"; $missing += $refTrim }
    }
}
Write-Output '--- Missing summary ---'
$missing | ForEach-Object { Write-Output $_ }
if ($missing.Count -gt 0) { exit 2 } else { exit 0 }