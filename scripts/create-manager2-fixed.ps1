Write-Host 'Creating manager2 (fixed) and assigning Manager role'
$ErrorActionPreference = 'Stop'

# obtain admin token
$tokenResp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -ContentType 'application/x-www-form-urlencoded' -Body @{ grant_type = 'password'; client_id = 'admin-cli'; username = 'admin'; password = 'admin' }
if (-not $tokenResp.access_token) { Write-Error 'Failed to get admin token' ; exit 1 }
$adminToken = $tokenResp.access_token

# create user
$newUser = @{ username = 'manager2'; enabled = $true; emailVerified = $true; firstName = 'Manager'; lastName = 'Two' }
Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/admin/realms/hypesoft/users' -Headers @{ Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json' } -Body ($newUser | ConvertTo-Json)
Start-Sleep -Seconds 1

# get user id
$users = Invoke-RestMethod -Method Get -Uri 'http://localhost:8080/admin/realms/hypesoft/users?username=manager2' -Headers @{ Authorization = "Bearer $adminToken" }
if (-not $users -or $users.Count -eq 0) { Write-Error 'Failed to create manager2' ; exit 1 }
$uid = $users[0].id
Write-Host "manager2 id: $uid"

# set password
$pw = @{ type = 'password'; value = 'Manager2Pass!'; temporary = $false } | ConvertTo-Json
Invoke-RestMethod -Method Put -Uri "http://localhost:8080/admin/realms/hypesoft/users/$uid/reset-password" -Headers @{ Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json' } -Body $pw
Write-Host 'Password set'

# fetch role id
$role = Invoke-RestMethod -Method Get -Uri 'http://localhost:8080/admin/realms/hypesoft/roles/Manager' -Headers @{ Authorization = "Bearer $adminToken" }
if (-not $role.id) { Write-Error 'Role Manager not found' ; exit 1 }
$roleMinimal = @{ id = $role.id; name = $role.name }

# assign role mapping using minimal representation
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/admin/realms/hypesoft/users/$uid/role-mappings/realm" -Headers @{ Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json' } -Body (@($roleMinimal) | ConvertTo-Json -Depth 6)
Write-Host 'Assigned Manager role to manager2'

# test login
try {
    $mgr = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -ContentType 'application/x-www-form-urlencoded' -Body @{ grant_type = 'password'; client_id = 'hypesoft-api'; client_secret = 'hypesoft-api-secret'; username = 'manager2'; password = 'Manager2Pass!' }
    if ($mgr.access_token) { Write-Host 'Manager2 token obtained (truncated):' $mgr.access_token.Substring(0,40) '...' }
    else { Write-Host 'Manager2 token response:' ($mgr | ConvertTo-Json) }
} catch { Write-Host 'Login failed:' $_.Exception.Message }

Write-Host 'Done.'
