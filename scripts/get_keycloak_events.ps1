Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token

$events = Invoke-RestMethod -Uri 'http://localhost:8080/admin/realms/hypesoft/events?max=20' -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$events | ConvertTo-Json -Depth 10 | Out-File keycloak_events.json -Encoding utf8
Write-Output 'Wrote keycloak_events.json'; Get-Content keycloak_events.json
