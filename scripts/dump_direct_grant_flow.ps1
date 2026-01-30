$ErrorActionPreference = 'Stop'
Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$adminToken = (Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body 'client_id=admin-cli&username=admin&password=admin&grant_type=password' -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop).access_token
$h = @{ Authorization = 'Bearer ' + $adminToken }
$flowAlias = 'direct grant'
$flows = Invoke-RestMethod -Uri 'http://localhost:8080/admin/realms/hypesoft/authentication/flows' -Headers $h -Method Get -ErrorAction Stop
$flows | ConvertTo-Json -Depth 20 | Out-File -Encoding utf8 './scripts/authentication_flows_all.json'
Write-Output 'Wrote ./scripts/authentication_flows_all.json'

$match = $flows | Where-Object { $_.alias -eq $flowAlias }
if (-not $match) { Write-Output "Flow '$flowAlias' not found in list"; exit 1 }
$enc = [uri]::EscapeDataString($flowAlias)
$execs = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/flows/$enc/executions" -Headers $h -Method Get -ErrorAction Stop
$execs | ConvertTo-Json -Depth 20 | Out-File -Encoding utf8 './scripts/direct_grant_flow_executions.json'
Write-Output 'Wrote ./scripts/direct_grant_flow_executions.json'
