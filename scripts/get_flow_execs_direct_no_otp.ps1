$ErrorActionPreference = 'Stop'
$flowId = '87866a67-cb69-40cf-8551-f423b298ccc2'
$tokenResponse = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}
$token = $tokenResponse.access_token
$execs = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/flows/$flowId/executions"
$execs | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 "./direct_no_otp_executions.json"
Write-Host "Wrote direct_no_otp_executions.json"