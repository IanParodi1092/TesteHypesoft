$ErrorActionPreference = 'Stop'
$tokenResponse = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}
$token = $tokenResponse.access_token
# create user
$newUser = @{ username = 'mgr_auto2'; firstName = 'Mgr'; lastName = 'Auto'; email = 'mgr_auto2@example.com'; enabled = $true; emailVerified = $true }
$user = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"; 'Content-Type' = 'application/json'} -Method Post -Uri 'http://localhost:8080/admin/realms/hypesoft/users' -Body (ConvertTo-Json $newUser -Depth 10)
Write-Host "Created user (response):" $user
# find created user id
$created = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri "http://localhost:8080/admin/realms/hypesoft/users?username=mgr_auto2"
$uid = $created[0].id
Write-Host "User id: $uid"
# set password
$pwd = @{ type = 'password'; value = 'Password123!'; temporary = $false }
Invoke-RestMethod -Headers @{Authorization = "Bearer $token"; 'Content-Type' = 'application/json'} -Method Put -Uri "http://localhost:8080/admin/realms/hypesoft/users/$uid/reset-password" -Body (ConvertTo-Json $pwd)
Write-Host "Password set for $uid"
# attempt token
try {
    $resp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Body @{client_id='hypesoft-api';client_secret='hypesoft-api-secret';grant_type='password';username='mgr_auto2';password='Password123!'}
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    . "$PSScriptRoot\diag_paths.ps1"
    $resp | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'mgr_auto2_token.json') -Encoding utf8
    Write-Host "Token saved to mgr_auto2_token.json"
} catch {
    Write-Host "Token request failed: $_"
    if ($_.Exception -and $_.Exception.Response) {
        $body = $_.Exception.Response.GetResponseStream() | ForEach-Object { new-object System.IO.StreamReader($_).ReadToEnd() }
        $body | Out-File -FilePath (Get-DiagPath 'mgr_auto2_token_error.txt') -Encoding utf8
        Write-Host "Error body saved to mgr_auto2_token_error.txt"
    }
}