$ErrorActionPreference = 'Stop'
Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$adminToken = (Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body 'client_id=admin-cli&username=admin&password=admin&grant_type=password' -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop).access_token
$h = @{ Authorization = 'Bearer ' + $adminToken }
$ra = Invoke-RestMethod -Uri 'http://localhost:8080/admin/realms/hypesoft/authentication/required-actions' -Headers $h -Method Get
$ra | ConvertTo-Json -Depth 20 | Out-File -Encoding utf8 './scripts/required_actions.json'
Write-Output 'Wrote ./scripts/required_actions.json'
