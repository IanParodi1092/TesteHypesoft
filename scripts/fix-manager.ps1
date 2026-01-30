Write-Host 'Starting manager fix script'
$ErrorActionPreference = 'Stop'

# 1) obtain admin token
Write-Host 'Requesting admin token (master realm)'
$tokenResp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -ContentType 'application/x-www-form-urlencoded' -Body @{ grant_type = 'password'; client_id = 'admin-cli'; username = 'admin'; password = 'admin' }
if (-not $tokenResp.access_token) { Write-Error 'Failed to get admin token'; exit 1 }
$adminToken = $tokenResp.access_token
Write-Host 'Admin token obtained.'

# 2) find manager user
Write-Host 'Searching for user "manager"'
$users = Invoke-RestMethod -Method Get -Uri 'http://localhost:8080/admin/realms/hypesoft/users?username=manager' -Headers @{ Authorization = "Bearer $adminToken" }
if (-not $users -or $users.Count -eq 0) { Write-Host 'Manager not found'; exit 1 }
$user = $users[0]
$id = $user.id
Write-Host "Manager id: $id"

# 3) get full user representation
$full = Invoke-RestMethod -Method Get -Uri "http://localhost:8080/admin/realms/hypesoft/users/$id" -Headers @{ Authorization = "Bearer $adminToken" }

# 4) ensure requiredActions empty and enabled
$full.requiredActions = @()
$full.emailVerified = $true
$full.enabled = $true

Write-Host 'Updating user (clearing requiredActions)'
Invoke-RestMethod -Method Put -Uri "http://localhost:8080/admin/realms/hypesoft/users/$id" -Headers @{ Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json' } -Body ($full | ConvertTo-Json -Depth 10)
Write-Host 'User updated.'

# 5) reset password
Write-Host 'Resetting password to Manager123!'
$pw = @{ type = 'password'; value = 'Manager123!'; temporary = $false } | ConvertTo-Json
Invoke-RestMethod -Method Put -Uri "http://localhost:8080/admin/realms/hypesoft/users/$id/reset-password" -Headers @{ Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json' } -Body $pw
Write-Host 'Password reset requested.'

# 6) test login using password grant
Write-Host 'Attempting password grant login for manager'
try {
    $mgr = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -ContentType 'application/x-www-form-urlencoded' -Body @{ grant_type = 'password'; client_id = 'hypesoft-api'; client_secret = 'hypesoft-api-secret'; username = 'manager'; password = 'Manager123!' }
    if ($mgr.access_token) { Write-Host 'Manager token obtained (truncated):' $mgr.access_token.Substring(0,40) '...' }
    else { Write-Host 'Manager login response:' ($mgr | ConvertTo-Json) }
} catch {
    Write-Host 'Manager login failed:' $_.Exception.Message
}

Write-Host 'Done.'
