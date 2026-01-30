$ErrorActionPreference = 'Stop'
$adminToken = (Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}).access_token
$found = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users?username=mgr_auto2"
if (-not $found -or $found.Count -eq 0) { Write-Host "User mgr_auto2 not found"; exit 1 }
$uid = $found[0].id
$user = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$uid"
$creds = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$uid/credentials"
$feds = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$uid/federated-identity"
$roles = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$uid/role-mappings/realm"
$combined = @{ user = $user; credentials = $creds; federatedIdentities = $feds; realmRoleMappings = $roles }
$combined | ConvertTo-Json -Depth 20 | Out-File -Encoding utf8 "..\frontend\mgr_auto2_full.json"
Write-Host "Wrote ..\frontend\mgr_auto2_full.json"