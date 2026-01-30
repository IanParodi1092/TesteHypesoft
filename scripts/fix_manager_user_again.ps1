$ErrorActionPreference = 'Stop'
$tokenResponse = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}
$token = $tokenResponse.access_token
$userId = 'eee1cd39-ffd7-4a6c-a6e1-59b42a687bbe'
$patch = @{ emailVerified = $true; enabled = $true; requiredActions = @() }
Invoke-RestMethod -Headers @{Authorization = "Bearer $token"; 'Content-Type' = 'application/json'} -Method Put -Uri "http://localhost:8080/admin/realms/hypesoft/users/$userId" -Body (ConvertTo-Json $patch -Depth 10)
Write-Host "Patched user $userId"
# confirm
$u = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$userId"
$u | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 ./manager_after_fix_again.json
Write-Host "Wrote manager_after_fix_again.json"