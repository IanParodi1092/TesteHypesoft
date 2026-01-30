Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token

$flows = Invoke-RestMethod -Uri 'http://localhost:8080/admin/realms/hypesoft/authentication/flows' -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$flows | ConvertTo-Json -Depth 10 | Out-File auth_flows.json -Encoding utf8
Write-Output 'Wrote auth_flows.json'; Get-Content auth_flows.json
