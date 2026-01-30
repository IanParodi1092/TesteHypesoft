$ErrorActionPreference = 'Stop'
$tokenResponse = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}
$token = $tokenResponse.access_token
$userId = 'eee1cd39-ffd7-4a6c-a6e1-59b42a687bbe'
$creds = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$userId/credentials"
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$PSScriptRoot\diag_paths.ps1"
$creds | ConvertTo-Json -Depth 10 | Out-File -FilePath (Get-DiagPath 'manager_credentials.json') -Encoding utf8
Write-Host "Wrote manager_credentials.json"