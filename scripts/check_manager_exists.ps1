$ErrorActionPreference = 'Stop'
$token=(Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}).access_token
$users=Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri 'http://localhost:8080/admin/realms/hypesoft/users?username=manager'
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$PSScriptRoot\diag_paths.ps1"
if ($users) { $users | ConvertTo-Json -Depth 10 | Out-File -FilePath (Get-DiagPath 'frontend/manager_after_recreate_raw.json') -Encoding utf8; Write-Host "Wrote frontend\manager_after_recreate_raw.json" } else { Write-Host 'manager not found' }