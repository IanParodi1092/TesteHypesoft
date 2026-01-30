Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token
$users = Invoke-RestMethod -Headers @{ Authorization = "Bearer $adminToken" } -Uri 'http://localhost:8080/admin/realms/hypesoft/users?username=manager'
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$PSScriptRoot\diag_paths.ps1"
$users | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'scripts/tmp_manager_check.json') -Encoding utf8
if ($users.Count -gt 0) { $id = $users[0].id; Invoke-RestMethod -Headers @{ Authorization = "Bearer $adminToken" } -Uri "http://localhost:8080/admin/realms/hypesoft/users/$id/role-mappings/realm" | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'scripts/tmp_manager_roles.json') -Encoding utf8 }
Write-Host 'Wrote tmp files'
