$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$PSScriptRoot\diag_paths.ps1"
Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token
$role = Invoke-RestMethod -Headers @{ Authorization = "Bearer $adminToken" } -Uri 'http://localhost:8080/admin/realms/hypesoft/roles/Manager'
$role | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'scripts/tmp_role_manager.json') -Encoding utf8
Write-Host 'Wrote tmp_role_manager.json ->' (Get-DiagPath 'scripts/tmp_role_manager.json')