$ErrorActionPreference = 'Stop'
$tokenResponse = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}
$token = $tokenResponse.access_token
$realm = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri 'http://localhost:8080/admin/realms/hypesoft'
$realm | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 "./realm_repr.json"
Write-Host "Wrote realm_repr.json"