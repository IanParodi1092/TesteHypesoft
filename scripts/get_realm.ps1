Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token
$realm = Invoke-RestMethod -Headers @{ Authorization = "Bearer $adminToken" } -Uri 'http://localhost:8080/admin/realms/hypesoft' -Method Get
$realm | ConvertTo-Json -Depth 10 | Out-File realm_repr_runtime.json -Encoding utf8
Write-Host 'Wrote realm_repr_runtime.json'