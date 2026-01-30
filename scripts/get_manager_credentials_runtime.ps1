Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$manager = Get-Content ./manager_user.json | ConvertFrom-Json
$userId = $manager.id
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token
$creds = Invoke-RestMethod -Headers @{ Authorization = "Bearer $adminToken" } -Uri "http://localhost:8080/admin/realms/hypesoft/users/$userId/credentials"
$creds | ConvertTo-Json -Depth 10 | Out-File .\frontend\manager_credentials_runtime.json -Encoding utf8
Write-Host 'Wrote frontend\manager_credentials_runtime.json'