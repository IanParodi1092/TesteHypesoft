Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'

$realm = 'hypesoft'
# attempt password grant
$form = @{ grant_type='password'; client_id='hypesoft-api'; client_secret='hypesoft-api-secret'; username='manager'; password='Manager123!' }
Write-Output "Attempting password grant for user 'manager' at $(Get-Date -Format o)"
try {
    $resp = Invoke-RestMethod -Uri "http://localhost:8080/realms/$realm/protocol/openid-connect/token" -Method Post -Body $form -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    $resp | ConvertTo-Json -Depth 5 | Out-File mgr_token_diag.json -Encoding utf8
    Write-Output 'Token response success:'; Get-Content mgr_token_diag.json
} catch {
    Write-Output 'Token response error:'
    if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); $body = $sr.ReadToEnd(); Write-Output $body } else { Write-Output $_.Exception.Message }
}

# collect big tail of Keycloak logs
docker logs hypesoft-keycloak --tail 2000 > keycloak_trace_detailed.txt

# Patterns to search
$patterns = @( 'resolve_required_actions', 'requiredAction', 'required actions', 'required-actions', 'required_actions', 'UPDATE_PROFILE', 'UPDATE_PASSWORD', 'VERIFY_EMAIL', 'CONFIGURE_TOTP', 'TERMS_AND_CONDITIONS', 'VERIFY_PROFILE', 'direct-grant-validate-otp', 'idp-review-profile' )

Write-Output '--- Matching log lines (pattern list) ---'
foreach ($p in $patterns) {
    Write-Output "--- Pattern: $p ---"
    Select-String -Path keycloak_trace_detailed.txt -Pattern $p -AllMatches | ForEach-Object { $_.Line }
}

Write-Output '--- Context around resolve_required_actions matches (5 lines before/after) ---'
$matches = Select-String -Path keycloak_trace_detailed.txt -Pattern 'resolve_required_actions' -AllMatches
foreach ($m in $matches) {
    $idx = $m.LineNumber - 1
    $lines = Get-Content keycloak_trace_detailed.txt
    $start = [Math]::Max(0, $idx - 5)
    $end = [Math]::Min($lines.Count - 1, $idx + 5)
    for ($i = $start; $i -le $end; $i++) { Write-Output $lines[$i] }
    Write-Output '---'
}

Write-Output 'Done.'
