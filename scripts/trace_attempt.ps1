Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'

# Get admin token (for debug if needed)
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token

# Attempt manager password grant
$form = @{ grant_type='password'; client_id='hypesoft-api'; client_secret='hypesoft-api-secret'; username='manager'; password='Manager123!' }
try {
    $resp = Invoke-RestMethod -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Method Post -Body $form -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    . "$PSScriptRoot\diag_paths.ps1"
    $resp | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'mgr_debug.json') -Encoding utf8
    Write-Output 'Token response success:'
    Get-Content mgr_debug.json
} catch {
    Write-Output 'Token response error:'
    if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); $body = $sr.ReadToEnd(); Write-Output $body } else { Write-Output $_.Exception.Message }
}

# Collect whole trace tail
docker logs hypesoft-keycloak --tail 1000 > keycloak_after_trace.txt
Write-Output '--- Relevant TRACE lines ---'
Select-String -Path keycloak_after_trace.txt -Pattern 'resolve_required_actions|LOGIN_ERROR|requiredAction|required-actions|required_action|required_action' -AllMatches | ForEach-Object { $_.Line }
Write-Output '--- Full last 300 lines ---'
Get-Content keycloak_after_trace.txt | Select-Object -Last 300
