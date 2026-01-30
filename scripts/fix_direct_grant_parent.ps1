Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'

$execId = '09ebb250-0848-428f-b718-f67514280f69' # Direct Grant - Conditional OTP (parent)
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token

Write-Output "Updating execution $execId -> DISABLED"
try {
    Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/executions/$execId" -Method Put -Headers @{ Authorization = "Bearer $adminToken" } -Body (@{ requirement = 'DISABLED' } | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
    Write-Output 'Update request sent successfully.'
} catch {
    Write-Output 'Update failed:'
    Write-Output $_.Exception.Message
    if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); Write-Output $sr.ReadToEnd() }
}

# Re-fetch parent executions
$flowAlias = 'direct grant'
$executions = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/flows/$([uri]::EscapeDataString($flowAlias))/executions" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$executions | ConvertTo-Json -Depth 10 | Out-File direct_grant_parent_exec_after.json -Encoding utf8
Write-Output 'Wrote direct_grant_parent_exec_after.json'
Get-Content direct_grant_parent_exec_after.json

# Try manager password grant
$form = @{ grant_type='password'; client_id='hypesoft-api'; client_secret='hypesoft-api-secret'; username='manager'; password='Manager123!' }
try {
    $resp = Invoke-RestMethod -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Method Post -Body $form -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    $resp | ConvertTo-Json -Depth 5 | Out-File mgr_debug_after_fix.json -Encoding utf8
    Write-Output 'Token response (manager success):'
    Get-Content mgr_debug_after_fix.json
} catch {
    Write-Output 'Token response (manager error):'
    if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); $body = $sr.ReadToEnd(); Write-Output $body } else { Write-Output $_.Exception.Message }
}

# Tail logs
docker logs hypesoft-keycloak --tail 300 > keycloak_after_fix.txt
Write-Output '--- Relevant events ---'
Select-String -Path keycloak_after_fix.txt -Pattern 'resolve_required_actions|LOGIN_ERROR' -AllMatches | ForEach-Object { $_.Line }
Write-Output '--- Last 200 lines ---'
Get-Content keycloak_after_fix.txt | Select-Object -Last 200
