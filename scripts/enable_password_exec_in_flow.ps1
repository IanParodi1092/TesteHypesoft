$ErrorActionPreference = 'Stop'
$flowAlias = 'direct-grant-no-otp'
$tokenResponse = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}
$token = $tokenResponse.access_token
$execs = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/flows/$flowAlias/executions"
$execs | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 "./${flowAlias}_executions_raw.json"
Write-Host "Wrote ${flowAlias}_executions_raw.json"
# find the execution with providerId direct-grant-validate-password
$pwdExec = $execs | Where-Object { $_.providerId -eq 'direct-grant-validate-password' }
if (-not $pwdExec) { Write-Host "Password execution not found in flow $flowAlias"; exit 1 }
$execId = $pwdExec.id
Write-Host "Found password execution id: $execId, current requirement: $($pwdExec.requirement)"
# prepare updated object
$updated = @{ requirement = 'REQUIRED' }
Invoke-RestMethod -Headers @{Authorization = "Bearer $token"; 'Content-Type' = 'application/json'} -Method Put -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/executions/$execId" -Body ($updated | ConvertTo-Json -Depth 5)
Write-Host "Updated execution $execId to REQUIRED"
# confirm
$execs2 = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/flows/$flowAlias/executions"
$execs2 | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 "./${flowAlias}_executions_after.json"
Write-Host "Wrote ${flowAlias}_executions_after.json"