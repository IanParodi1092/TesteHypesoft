Write-Host 'Create or fix manager2 user and assign Manager role (final)'
$ErrorActionPreference = 'Stop'

# admin token
$tokenResp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -ContentType 'application/x-www-form-urlencoded' -Body @{ grant_type = 'password'; client_id = 'admin-cli'; username = 'admin'; password = 'admin' }
if (-not $tokenResp.access_token) { Write-Error 'Failed to get admin token' ; exit 1 }
$adminToken = $tokenResp.access_token

# find existing user
$users = Invoke-RestMethod -Method Get -Uri 'http://localhost:8080/admin/realms/hypesoft/users?username=manager2' -Headers @{ Authorization = "Bearer $adminToken" }
if ($users -and $users.Count -gt 0) { $uid = $users[0].id; Write-Host "Found existing manager2: $uid" } else { Write-Host 'Creating manager2'; $newUser = @{ username = 'manager2'; enabled = $true; emailVerified = $true; firstName = 'Manager'; lastName = 'Two' }; Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/admin/realms/hypesoft/users' -Headers @{ Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json' } -Body ($newUser | ConvertTo-Json); Start-Sleep -Seconds 1; $users = Invoke-RestMethod -Method Get -Uri 'http://localhost:8080/admin/realms/hypesoft/users?username=manager2' -Headers @{ Authorization = "Bearer $adminToken" }; if (-not $users -or $users.Count -eq 0) { Write-Error 'Failed to create manager2' ; exit 1 } ; $uid = $users[0].id }

Write-Host "Using manager2 id: $uid"

# set password
$pw = @{ type = 'password'; value = 'Manager2Pass!'; temporary = $false } | ConvertTo-Json
Invoke-RestMethod -Method Put -Uri "http://localhost:8080/admin/realms/hypesoft/users/$uid/reset-password" -Headers @{ Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json' } -Body $pw
Write-Host 'Password set'

# assign Manager role (minimal representation)
$role = Invoke-RestMethod -Method Get -Uri 'http://localhost:8080/admin/realms/hypesoft/roles/Manager' -Headers @{ Authorization = "Bearer $adminToken" }
if (-not $role.id) { Write-Error 'Manager role not found'; exit 1 }
$roleMinimal = @{ id = $role.id; name = $role.name }
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/admin/realms/hypesoft/users/$uid/role-mappings/realm" -Headers @{ Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json' } -Body (@($roleMinimal) | ConvertTo-Json -Depth 6)
Write-Host 'Manager role assigned'

# test login
try {
    $mgr = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -ContentType 'application/x-www-form-urlencoded' -Body @{ grant_type = 'password'; client_id = 'hypesoft-api'; client_secret = 'hypesoft-api-secret'; username = 'manager2'; password = 'Manager2Pass!' }
    if ($mgr.access_token) { Write-Host 'Manager2 token obtained (truncated):' $mgr.access_token.Substring(0,40) '...' } else { Write-Host 'Manager2 login response:' ($mgr | ConvertTo-Json) }
} catch { Write-Host 'Manager2 login failed:' $_.Exception.Response.Content.ReadAsStringAsync().Result }

Write-Host 'Done.'
