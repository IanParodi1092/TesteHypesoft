$ErrorActionPreference = 'Stop'
$tokenResponse = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}
$token = $tokenResponse.access_token
$clients = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri "http://localhost:8080/admin/realms/hypesoft/clients?clientId=hypesoft-api"
$clients | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 "./hypesoft_api_clients.json"
Write-Host "Wrote hypesoft_api_clients.json"