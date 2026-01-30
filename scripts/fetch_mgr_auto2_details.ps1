$ErrorActionPreference = 'Stop'
# find token file
$found = Get-ChildItem -Path .. -Recurse -Filter 'mgr_auto2_token.json' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $found) { $found = Get-ChildItem -Path . -Recurse -Filter 'mgr_auto2_token.json' -ErrorAction SilentlyContinue | Select-Object -First 1 }
if (-not $found) { Write-Host "mgr_auto2_token.json not found"; exit 1 }
$tokenFile = $found.FullName
$mgrToken = Get-Content $tokenFile -Raw | ConvertFrom-Json
$mgrId = $mgrToken.sub
# admin token
$adminToken = (Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}).access_token
# fetch details
$user = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$mgrId"
$creds = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$mgrId/credentials"
$feds = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$mgrId/federated-identity"
$roles = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$mgrId/role-mappings/realm"
$combined = @{ user = $user; credentials = $creds; federatedIdentities = $feds; realmRoleMappings = $roles }
$combined | ConvertTo-Json -Depth 20 | Out-File -Encoding utf8 "..\frontend\mgr_auto2_full.json"
Write-Host "Wrote ..\frontend\mgr_auto2_full.json"