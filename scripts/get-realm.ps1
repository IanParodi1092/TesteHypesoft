Write-Host 'Fetching realm configuration (hypesoft)'
$ErrorActionPreference = 'Stop'
$tokenResp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -ContentType 'application/x-www-form-urlencoded' -Body @{ grant_type = 'password'; client_id = 'admin-cli'; username = 'admin'; password = 'admin' }
if (-not $tokenResp.access_token) { Write-Error 'Failed to get admin token' ; exit 1 }
$adminToken = $tokenResp.access_token
$realm = Invoke-RestMethod -Method Get -Uri 'http://localhost:8080/admin/realms/hypesoft' -Headers @{ Authorization = "Bearer $adminToken" }
$realm | ConvertTo-Json -Depth 8
