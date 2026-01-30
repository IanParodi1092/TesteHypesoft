$ErrorActionPreference = 'Stop'
$tokenResponse = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}
$token = $tokenResponse.access_token
$realm = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri 'http://localhost:8080/admin/realms/hypesoft'
$realm.directGrantFlow = 'direct grant'
Invoke-RestMethod -Headers @{Authorization = "Bearer $token"; 'Content-Type' = 'application/json'} -Method Put -Uri 'http://localhost:8080/admin/realms/hypesoft' -Body ($realm | ConvertTo-Json -Depth 20)
Write-Host "Set realm.directGrantFlow to 'direct grant'"