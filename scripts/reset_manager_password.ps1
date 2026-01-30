$ErrorActionPreference = 'Stop'
$tokenResponse = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}
$token = $tokenResponse.access_token
$userId = 'eee1cd39-ffd7-4a6c-a6e1-59b42a687bbe'
$body = @{ type = 'password'; value = 'manager'; temporary = $false }
Invoke-RestMethod -Headers @{Authorization = "Bearer $token"; 'Content-Type' = 'application/json'} -Method Put -Uri "http://localhost:8080/admin/realms/hypesoft/users/$userId/reset-password" -Body (ConvertTo-Json $body)
Write-Host 'Password reset to "manager" for user manager (temporary=false)'