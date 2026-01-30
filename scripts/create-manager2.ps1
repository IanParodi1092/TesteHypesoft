Write-Host 'Creating manager2 user and assigning Manager role'
$ErrorActionPreference = 'Stop'

$kcAdmin = (Get-Content kc_admin_token.json | ConvertFrom-Json).access_token
if (-not $kcAdmin) { Write-Error 'admin token missing' ; exit 1 }

$newUser = @{ username = 'manager2'; enabled = $true; emailVerified = $true; firstName = 'Manager'; lastName = 'Two' }
Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/admin/realms/hypesoft/users' -Headers @{ Authorization = "Bearer $kcAdmin"; 'Content-Type' = 'application/json' } -Body ($newUser | ConvertTo-Json)
Start-Sleep -Seconds 1
$users = Invoke-RestMethod -Method Get -Uri 'http://localhost:8080/admin/realms/hypesoft/users?username=manager2' -Headers @{ Authorization = "Bearer $kcAdmin" }
if (-not $users -or $users.Count -eq 0) { Write-Error 'Failed to create manager2' ; exit 1 }
$uid = $users[0].id
Write-Host "Created manager2 id: $uid"

# set password
$pw = @{ type = 'password'; value = 'Manager2Pass!'; temporary = $false } | ConvertTo-Json
Invoke-RestMethod -Method Put -Uri "http://localhost:8080/admin/realms/hypesoft/users/$uid/reset-password" -Headers @{ Authorization = "Bearer $kcAdmin"; 'Content-Type' = 'application/json' } -Body $pw
Write-Host 'Password set for manager2'

# assign Manager role
$role = Invoke-RestMethod -Method Get -Uri 'http://localhost:8080/admin/realms/hypesoft/roles/Manager' -Headers @{ Authorization = "Bearer $kcAdmin" }
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/admin/realms/hypesoft/users/$uid/role-mappings/realm" -Headers @{ Authorization = "Bearer $kcAdmin"; 'Content-Type' = 'application/json' } -Body (@($role) | ConvertTo-Json -Depth 6)
Write-Host 'Assigned role Manager to manager2'
