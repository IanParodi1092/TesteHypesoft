$ErrorActionPreference = 'Stop'
$tokenResponse = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}
$token = $tokenResponse.access_token
$realm = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri 'http://localhost:8080/admin/realms/hypesoft'
$realm.eventsEnabled = $true
$realm.enabledEventTypes = @('LOGIN_ERROR','LOGIN','REGISTER','CODE_TO_TOKEN','REVOKE_GRANT','LOGOUT','CLIENT_LOGIN')
Invoke-RestMethod -Headers @{Authorization = "Bearer $token"; 'Content-Type' = 'application/json'} -Method Put -Uri 'http://localhost:8080/admin/realms/hypesoft' -Body ($realm | ConvertTo-Json -Depth 20)
Write-Host 'Realm eventsEnabled set to true and enabledEventTypes updated'