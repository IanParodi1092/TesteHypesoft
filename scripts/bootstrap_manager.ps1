<#
Idempotent Keycloak bootstrap script for seeded `manager` user.
Actions:
- wait for Keycloak
- obtain admin token
- ensure realm.directGrantFlow is set to "direct grant"
- ensure role `Manager` exists
- create or update user `manager` with emailVerified=true, requiredActions=[], enabled=true
- set password to Manager123!
- assign realm role `Manager`
- test token and save to ../frontend/manager_token_bootstrap.json
#>

$ErrorActionPreference = 'Stop'

function Wait-KeycloakReady {
    param($url = 'http://localhost:8080/realms/hypesoft/.well-known/openid-configuration', $timeoutSec = 120)
    $end = (Get-Date).AddSeconds($timeoutSec)
    while ((Get-Date) -lt $end) {
        try {
            Invoke-RestMethod -Method Get -Uri $url -TimeoutSec 5 -ErrorAction Stop | Out-Null
            Write-Host "Keycloak ready"
            return $true
        } catch {
            Start-Sleep -Seconds 1
        }
    }
    throw "Keycloak did not become ready within $timeoutSec seconds"
}

function Get-AdminToken {
    $body = @{ client_id = 'admin-cli'; username = 'admin'; password = 'admin'; grant_type = 'password' }
    $t = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body $body -ContentType 'application/x-www-form-urlencoded'
    return $t.access_token
}

Write-Host "Bootstrap start: $(Get-Date -Format o)"
Wait-KeycloakReady
$adminToken = Get-AdminToken
$headers = @{ Authorization = "Bearer $adminToken"; "Content-Type" = 'application/json' }
$realm = 'hypesoft'

# 1) Ensure realm.directGrantFlow is set to 'direct grant'
try {
    $realmRep = Invoke-RestMethod -Method Get -Uri "http://localhost:8080/admin/realms/$realm" -Headers $headers
    if ($realmRep.directGrantFlow -ne 'direct grant') {
        Write-Host "Updating realm.directGrantFlow -> 'direct grant'"
        $patch = @{ directGrantFlow = 'direct grant' } | ConvertTo-Json
        Invoke-RestMethod -Method Put -Uri "http://localhost:8080/admin/realms/$realm" -Headers $headers -Body $patch
    } else {
        Write-Host "Realm directGrantFlow already set to 'direct grant'"
    }
} catch {
    Write-Host "Failed to fetch/update realm: $_"
}

# 2) Ensure role Manager exists
try {
    Invoke-RestMethod -Method Get -Uri "http://localhost:8080/admin/realms/$realm/roles/Manager" -Headers $headers -ErrorAction Stop | Out-Null
    Write-Host "Role 'Manager' exists"
} catch {
    Write-Host "Creating role 'Manager'"
    $roleBody = @{ name = 'Manager' } | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri "http://localhost:8080/admin/realms/$realm/roles" -Headers $headers -Body $roleBody
}

# 3) Create or update user 'manager'
try {
    $users = Invoke-RestMethod -Method Get -Uri "http://localhost:8080/admin/realms/$realm/users?username=manager" -Headers $headers
    if ($users -and $users.Count -gt 0) {
        $user = $users[0]
        $userId = $user.id
        Write-Host "Found existing user 'manager' id=$userId. Patching attributes."
        $upd = @{ firstName = ($user.firstName -or 'Manager'); lastName = ($user.lastName -or 'User'); emailVerified = $true; enabled = $true; requiredActions = @() } | ConvertTo-Json
        Invoke-RestMethod -Method Put -Uri "http://localhost:8080/admin/realms/$realm/users/$userId" -Headers $headers -Body $upd
    } else {
        Write-Host "Creating user 'manager'"
        $newUser = @{ username = 'manager'; enabled = $true; emailVerified = $true; firstName = 'Manager'; lastName = 'User'; realmRoles = @('Manager') }
        Invoke-RestMethod -Method Post -Uri "http://localhost:8080/admin/realms/$realm/users" -Headers $headers -Body ($newUser | ConvertTo-Json) -ErrorAction Stop
        Start-Sleep -Seconds 1
        $users2 = Invoke-RestMethod -Method Get -Uri "http://localhost:8080/admin/realms/$realm/users?username=manager" -Headers $headers
        $userId = $users2[0].id
        Write-Host "Created user manager id=$userId"
    }
} catch {
    Write-Host "Error creating/updating user: $_"
    throw
}

# 4) Reset password (idempotent)
try {
    $pw = @{ type = 'password'; value = 'Manager123!'; temporary = $false } | ConvertTo-Json
    Invoke-RestMethod -Method Put -Uri "http://localhost:8080/admin/realms/$realm/users/$userId/reset-password" -Headers $headers -Body $pw
    Write-Host "Password set for user 'manager'"
} catch {
    Write-Host "Failed to reset password: $_"
}

# 5) Ensure requiredActions cleared (defensive)
try {
    $userRep = Invoke-RestMethod -Method Get -Uri "http://localhost:8080/admin/realms/$realm/users/$userId" -Headers $headers
    if ($userRep.requiredActions -and $userRep.requiredActions.Count -gt 0) {
        $upd2 = @{ firstName = $userRep.firstName; lastName = $userRep.lastName; emailVerified = $true; enabled = $true; requiredActions = @() } | ConvertTo-Json
        Invoke-RestMethod -Method Put -Uri "http://localhost:8080/admin/realms/$realm/users/$userId" -Headers $headers -Body $upd2
        Write-Host "Cleared requiredActions for manager"
    } else {
        Write-Host "No requiredActions present"
    }
} catch {
    Write-Host "Failed to clear requiredActions: $_"
}

# 6) Assign realm role Manager to user (idempotent)
try {
    $role = Invoke-RestMethod -Method Get -Uri "http://localhost:8080/admin/realms/$realm/roles/Manager" -Headers $headers
    $mappings = Invoke-RestMethod -Method Get -Uri "http://localhost:8080/admin/realms/$realm/users/$userId/role-mappings/realm" -Headers $headers
    $has = $false
    foreach ($r in $mappings) { if ($r.name -eq 'Manager') { $has = $true } }
    if (-not $has) {
        Invoke-RestMethod -Method Post -Uri "http://localhost:8080/admin/realms/$realm/users/$userId/role-mappings/realm" -Headers $headers -Body (@($role) | ConvertTo-Json)
        Write-Host "Assigned role Manager to user manager"
    } else {
        Write-Host "User already has Manager role"
    }
} catch {
    Write-Host "Failed to assign role: $_"
}

# 7) Attempt token using password grant and save result
try {
    Start-Sleep -Seconds 1
    $body = @{ client_id = 'hypesoft-api'; client_secret = 'hypesoft-api-secret'; grant_type = 'password'; username = 'manager'; password = 'Manager123!' }
    $resp = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/realms/$realm/protocol/openid-connect/token" -Body $body -ErrorAction Stop
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    . "$PSScriptRoot\diag_paths.ps1"
    $resp | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'frontend/manager_token_bootstrap.json') -Encoding utf8
    Write-Host "Token obtained and saved to frontend\manager_token_bootstrap.json"
} catch {
    $tokenFailed = $true
    Write-Host "Token request failed after bootstrap: $_"
    if ($_.Exception -and $_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $text = $reader.ReadToEnd()
        $text | Out-File -FilePath (Get-DiagPath 'frontend/manager_token_bootstrap_error.txt') -Encoding utf8
        Write-Host "Error body written to frontend\manager_token_bootstrap_error.txt"
    }
}

# If token still fails, recreate user from scratch and retry (idempotent)
try {
    $err = Get-Content "..\frontend\manager_token_bootstrap_error.txt" -ErrorAction SilentlyContinue
    if ($tokenFailed -or $err) {
        Write-Host "Token failed - recreating user 'manager' from scratch and retrying"
        # delete user
        Invoke-RestMethod -Method Delete -Uri "http://localhost:8080/admin/realms/$realm/users/$userId" -Headers $headers
        Start-Sleep -Seconds 1
        # create clean user
        $newUser = @{ username = 'manager'; enabled = $true; emailVerified = $true; firstName = 'Manager'; lastName = 'User'; realmRoles = @('Manager') }
        Invoke-RestMethod -Method Post -Uri "http://localhost:8080/admin/realms/$realm/users" -Headers $headers -Body ($newUser | ConvertTo-Json) -ErrorAction Stop
        Start-Sleep -Seconds 1
        $usersN = Invoke-RestMethod -Method Get -Uri "http://localhost:8080/admin/realms/$realm/users?username=manager" -Headers $headers
        $userId = $usersN[0].id
        Write-Host "Recreated user manager id=$userId"
        # set password
        $pw = @{ type = 'password'; value = 'Manager123!'; temporary = $false } | ConvertTo-Json
        Invoke-RestMethod -Method Put -Uri "http://localhost:8080/admin/realms/$realm/users/$userId/reset-password" -Headers $headers -Body $pw
        # assign role
        $role = Invoke-RestMethod -Method Get -Uri "http://localhost:8080/admin/realms/$realm/roles/Manager" -Headers $headers
        Invoke-RestMethod -Method Post -Uri "http://localhost:8080/admin/realms/$realm/users/$userId/role-mappings/realm" -Headers $headers -Body (@($role) | ConvertTo-Json)
        Start-Sleep -Seconds 1
        # retry token
        try {
            $body2 = @{ client_id = 'hypesoft-api'; client_secret = 'hypesoft-api-secret'; grant_type = 'password'; username = 'manager'; password = 'Manager123!' }
            $resp2 = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/realms/$realm/protocol/openid-connect/token" -Body $body2 -ErrorAction Stop
            $resp2 | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'frontend/manager_token_bootstrap.json') -Encoding utf8
            Write-Host "Token obtained after recreate and saved to frontend\manager_token_bootstrap.json"
        } catch {
            Write-Host "Token retry failed after recreate: $_"
            if ($_.Exception -and $_.Exception.Response) {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $text = $reader.ReadToEnd()
                $text | Out-File -FilePath (Get-DiagPath 'frontend/manager_token_bootstrap_error_after_recreate.txt') -Encoding utf8
                Write-Host "Wrote frontend\manager_token_bootstrap_error_after_recreate.txt"
            }
        }
    }
} catch {
    Write-Host "Recreate attempt failed: $_"
}

Write-Host "Bootstrap finished: $(Get-Date -Format o)"
