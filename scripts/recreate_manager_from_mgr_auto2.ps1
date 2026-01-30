$ErrorActionPreference = 'Stop'
$adminToken = (Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}).access_token
# find any existing manager users and delete them
$existing = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users?username=manager"
if ($existing) {
    foreach ($u in $existing) {
        Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Method Delete -Uri "http://localhost:8080/admin/realms/hypesoft/users/$($u.id)"
        Write-Host "Deleted existing user id: $($u.id)"
    }
}
# find clean user mgr_auto2
$found = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users?username=mgr_auto2"
if (-not $found -or $found.Count -eq 0) { Write-Host "mgr_auto2 not found; cannot clone"; exit 1 }
$src = $found[0]
# create new manager using src fields
$emailVal = 'manager+clone@example.com'
$newUser = @{ username = 'manager'; firstName = $src.firstName; lastName = $src.lastName; email = $emailVal; enabled = $true; emailVerified = $true }
Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json'} -Method Post -Uri 'http://localhost:8080/admin/realms/hypesoft/users' -Body (ConvertTo-Json $newUser -Depth 10)
Write-Host "Created new manager user"
# find new id
$new = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users?username=manager"
$newId = $new[0].id
Write-Host "New manager id: $newId"
# set password
$pwd = @{ type = 'password'; value = 'Manager123!'; temporary = $false }
Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json'} -Method Put -Uri "http://localhost:8080/admin/realms/hypesoft/users/$newId/reset-password" -Body (ConvertTo-Json $pwd)
Write-Host "Password set for manager (Manager123!)"
# add roles: Manager and default-roles-hypesoft if present
$roles = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/roles"
$roleMgr = $roles | Where-Object { $_.name -eq 'Manager' }
$roleDefault = $roles | Where-Object { $_.name -eq 'default-roles-hypesoft' }
$toAdd = @()
if ($roleMgr) { $toAdd += @{ id = $roleMgr.id; name = $roleMgr.name } }
if ($roleDefault) { $toAdd += @{ id = $roleDefault.id; name = $roleDefault.name } }
if ($toAdd.Count -gt 0) {
    Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json'} -Method Post -Uri "http://localhost:8080/admin/realms/hypesoft/users/$newId/role-mappings/realm" -Body (ConvertTo-Json $toAdd -Depth 5)
    Write-Host "Added role mappings to manager"
}
# update email to canonical manager email
Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json'} -Method Put -Uri "http://localhost:8080/admin/realms/hypesoft/users/$newId" -Body (ConvertTo-Json @{ email = 'manager@example.com'; emailVerified = $true } -Depth 5)
Write-Host "Updated email to manager@example.com"
# test token
try {
    $resp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Body @{client_id='hypesoft-api';client_secret='hypesoft-api-secret';grant_type='password';username='manager';password='Manager123!'} -ErrorAction Stop
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    . "$PSScriptRoot\diag_paths.ps1"
    $resp | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'frontend/manager_token_after_recreate.json') -Encoding utf8
    Write-Host "Token saved to frontend\manager_token_after_recreate.json"
} catch {
    Write-Host "Token request failed: $_"
    if ($_.Exception -and $_.Exception.Response) {
        $body = $_.Exception.Response.GetResponseStream() | ForEach-Object { new-object System.IO.StreamReader($_).ReadToEnd() }
        $body | Out-File -FilePath (Get-DiagPath 'frontend/manager_token_after_recreate_error.txt') -Encoding utf8
        Write-Host "Error body saved to frontend\manager_token_after_recreate_error.txt"
    }
}
Write-Host 'Done recreate script'