$ErrorActionPreference = 'Stop'
Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$adminToken = (Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}).access_token
$headers = @{ Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json' }
$realm = 'hypesoft'

# delete any existing mgr_auto2
$existing = Invoke-RestMethod -Headers $headers -Uri "http://localhost:8080/admin/realms/$realm/users?username=mgr_auto2"
if ($existing) { foreach ($u in $existing) { Invoke-RestMethod -Headers $headers -Method Delete -Uri "http://localhost:8080/admin/realms/$realm/users/$($u.id)"; Write-Host "Deleted existing mgr_auto2 $($u.id)" } }

# create mgr_auto2
$newUser = @{ username = 'mgr_auto2'; enabled = $true; emailVerified = $true; firstName = 'Mgr'; lastName = 'Auto2' }
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/admin/realms/$realm/users" -Headers $headers -Body (ConvertTo-Json $newUser -Depth 10)
Start-Sleep -Seconds 1
$users = Invoke-RestMethod -Headers $headers -Uri "http://localhost:8080/admin/realms/$realm/users?username=mgr_auto2"
$userId = $users[0].id
Write-Host "Created mgr_auto2 id=$userId"

# set password
$pwd = @{ type = 'password'; value = 'Manager123!'; temporary = $false }
Invoke-RestMethod -Headers $headers -Method Put -Uri "http://localhost:8080/admin/realms/$realm/users/$userId/reset-password" -Body (ConvertTo-Json $pwd)
Write-Host "Password set for mgr_auto2"

# add role Manager and default-roles-hypesoft if present
$roles = Invoke-RestMethod -Headers $headers -Uri "http://localhost:8080/admin/realms/$realm/roles"
$roleMgr = $roles | Where-Object { $_.name -eq 'Manager' }
$roleDefault = $roles | Where-Object { $_.name -eq 'default-roles-hypesoft' }
$toAdd = @()
if ($roleMgr) { $toAdd += @{ id = $roleMgr.id; name = $roleMgr.name } }
if ($roleDefault) { $toAdd += @{ id = $roleDefault.id; name = $roleDefault.name } }
if ($toAdd.Count -gt 0) { Invoke-RestMethod -Headers $headers -Method Post -Uri "http://localhost:8080/admin/realms/$realm/users/$userId/role-mappings/realm" -Body (ConvertTo-Json $toAdd -Depth 5); Write-Host "Added role mappings to mgr_auto2" }

# test token
try {
    $resp = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/realms/$realm/protocol/openid-connect/token" -Body @{client_id='hypesoft-api';client_secret='hypesoft-api-secret';grant_type='password';username='mgr_auto2';password='Manager123!'} -ErrorAction Stop
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    . "$PSScriptRoot\diag_paths.ps1"
    $resp | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'frontend/mgr_auto2_token.json') -Encoding utf8
    Write-Host "mgr_auto2 token saved"
} catch {
    Write-Host "mgr_auto2 token request failed: $_"
}

Write-Host 'Done'
