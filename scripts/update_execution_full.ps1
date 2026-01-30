Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$execId = '09ebb250-0848-428f-b718-f67514280f69'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token

Write-Output "GET execution $execId"
try { $detail = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/executions/$execId" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get -ErrorAction Stop; $detail | ConvertTo-Json -Depth 10 | Out-File -FilePath (Get-DiagPath 'execution_detail.json') -Encoding utf8; Write-Output 'Wrote execution_detail.json ->' (Get-DiagPath 'execution_detail.json'); Get-Content (Get-DiagPath 'execution_detail.json') } catch { Write-Output 'GET failed'; Write-Output $_.Exception.Message; if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); Write-Output $sr.ReadToEnd() } }

# Attempt to PUT back with requirement DISABLED using full object if obtained
if (Test-Path 'execution_detail.json') {
    $obj = Get-Content execution_detail.json | ConvertFrom-Json
    $obj.requirement = 'DISABLED'
    try { Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/executions/$execId" -Method Put -Headers @{ Authorization = "Bearer $adminToken" } -Body ($obj | ConvertTo-Json -Depth 15) -ContentType 'application/json' -ErrorAction Stop; Write-Output 'PUT succeeded' } catch { Write-Output 'PUT failed'; Write-Output $_.Exception.Message; if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); Write-Output $sr.ReadToEnd() } }
}

# Re-fetch executions for parent flow
$flowAlias = 'direct grant'
$executions = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/flows/$([uri]::EscapeDataString($flowAlias))/executions" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$executions | ConvertTo-Json -Depth 10 | Out-File -FilePath (Get-DiagPath 'direct_grant_parent_exec_after2.json') -Encoding utf8
Write-Output 'Wrote direct_grant_parent_exec_after2.json ->' (Get-DiagPath 'direct_grant_parent_exec_after2.json')
Get-Content (Get-DiagPath 'direct_grant_parent_exec_after2.json')

# Try manager password grant
$form = @{ grant_type='password'; client_id='hypesoft-api'; client_secret='hypesoft-api-secret'; username='manager'; password='Manager123!' }
try { $resp = Invoke-RestMethod -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Method Post -Body $form -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop; $resp | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'mgr_debug_after_fix2.json') -Encoding utf8; Write-Output 'Token success'; Get-Content (Get-DiagPath 'mgr_debug_after_fix2.json') } catch { Write-Output 'Token error'; if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); $body = $sr.ReadToEnd(); Write-Output $body } else { Write-Output $_.Exception.Message } }

docker logs hypesoft-keycloak --tail 200 | Out-File -FilePath (Get-DiagPath 'keycloak_after_fix2.txt') -Encoding utf8
Write-Output '--- Relevant events ---'
Select-String -Path (Get-DiagPath 'keycloak_after_fix2.txt') -Pattern 'resolve_required_actions|LOGIN_ERROR' -AllMatches | ForEach-Object { $_.Line }
Write-Output '--- Last 200 lines ---'
Get-Content (Get-DiagPath 'keycloak_after_fix2.txt') | Select-Object -Last 200
