Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token

$actions = Invoke-RestMethod -Uri 'http://localhost:8080/admin/realms/hypesoft/authentication/required-actions' -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$actions | ConvertTo-Json -Depth 10 | Out-File required_actions.json -Encoding utf8
Write-Output 'Wrote required_actions.json'; Get-Content required_actions.json
