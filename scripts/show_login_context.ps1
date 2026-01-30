Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$lines = Get-Content 'keycloak_after.txt'

Write-Output '--- Matches for LOGIN_ERROR (with 5 lines context) ---'
for ($i=0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'LOGIN_ERROR') {
        $start = [Math]::Max(0, $i - 5)
        $end = [Math]::Min($lines.Count - 1, $i + 5)
        for ($j = $start; $j -le $end; $j++) { Write-Output $lines[$j] }
        Write-Output '---'
    }
}

Write-Output '--- Matches for resolve_required_actions (with 5 lines context) ---'
for ($i=0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'resolve_required_actions') {
        $start = [Math]::Max(0, $i - 5)
        $end = [Math]::Min($lines.Count - 1, $i + 5)
        for ($j = $start; $j -le $end; $j++) { Write-Output $lines[$j] }
        Write-Output '---'
    }
}
