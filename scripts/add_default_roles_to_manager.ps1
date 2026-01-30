$ErrorActionPreference = 'Stop'
$adminToken = (Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}).access_token
# find manager user
$users = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users?username=manager"
if (-not $users -or $users.Count -eq 0) { Write-Host "manager user not found"; exit 1 }
$managerId = $users[0].id
Write-Host "manager id: $managerId"
# find role
$roles = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/roles"
$role = $roles | Where-Object { $_.name -eq 'default-roles-hypesoft' }
if (-not $role) { Write-Host "Role default-roles-hypesoft not found"; exit 1 }
Write-Host "Found role id: $($role.id)"
# construct mapping
$roleToAdd = @{ id = $role.id; name = $role.name }
# add role mapping
Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json'} -Method Post -Uri "http://localhost:8080/admin/realms/hypesoft/users/$managerId/role-mappings/realm" -Body (ConvertTo-Json @($roleToAdd) -Depth 5)
Write-Host "Added role mapping to manager"
# confirm
$mapping = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$managerId/role-mappings/realm"
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$PSScriptRoot\diag_paths.ps1"
$mapping | ConvertTo-Json -Depth 10 | Out-File -FilePath (Get-DiagPath 'frontend/manager_roles_after_add.json') -Encoding utf8
Write-Host "Wrote ..\frontend\manager_roles_after_add.json"