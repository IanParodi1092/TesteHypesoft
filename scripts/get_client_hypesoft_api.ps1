Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token

$clients = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/clients?clientId=hypesoft-api" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$clients | ConvertTo-Json -Depth 10 | Out-File client_hypesoft_api.json -Encoding utf8
Write-Output 'Wrote client_hypesoft_api.json'; Get-Content client_hypesoft_api.json
