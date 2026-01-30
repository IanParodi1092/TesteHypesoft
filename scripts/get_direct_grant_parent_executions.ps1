Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token

$flowAlias = 'direct grant'
$executions = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/flows/$([uri]::EscapeDataString($flowAlias))/executions" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$executions | ConvertTo-Json -Depth 10 | Out-File direct_grant_parent_exec.json -Encoding utf8
Write-Output 'Wrote direct_grant_parent_exec.json'; Get-Content direct_grant_parent_exec.json
