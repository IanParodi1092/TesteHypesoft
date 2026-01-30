Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'

# Get admin token
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
try { $t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop } catch { Write-Output 'Failed to get admin token'; Write-Output $_.Exception.Message; exit 1 }
$adminToken = $t.access_token

# Create user mgr_auto
$body = @{ username = 'mgr_auto'; enabled = $true; emailVerified = $true }
$created = Invoke-RestMethod -Uri 'http://localhost:8080/admin/realms/hypesoft/users' -Headers @{ Authorization = "Bearer $adminToken" } -Method Post -Body ($body | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
Write-Output 'Created user (or got 201)'

# Find created user's id
$users = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/users?username=mgr_auto" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$uid = $users[0].id
Write-Output "User id: $uid"

# Set password
$pw = @{ type='password'; value='Manager123!'; temporary=$false }
Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/users/$uid/reset-password" -Headers @{ Authorization = "Bearer $adminToken" } -Method Put -Body ($pw | ConvertTo-Json) -ContentType 'application/json'
Write-Output 'Password set'

# Try password grant for mgr_auto
$form = @{ grant_type='password'; client_id='hypesoft-api'; client_secret='hypesoft-api-secret'; username='mgr_auto'; password='Manager123!' }
try {
    $resp = Invoke-RestMethod -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Method Post -Body $form -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    . "$PSScriptRoot\diag_paths.ps1"
    $resp | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'mgr_auto_token.json') -Encoding utf8
    Write-Output 'Token response (mgr_auto success):'
    Get-Content mgr_auto_token.json
} catch {
    Write-Output 'Token response (mgr_auto error):'
    if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); $body = $sr.ReadToEnd(); Write-Output $body } else { Write-Output $_.Exception.Message }
}

docker logs hypesoft-keycloak --tail 300 > keycloak_after_create_user.txt
Write-Output '--- Recent Keycloak logs ---'
Get-Content keycloak_after_create_user.txt | Select-Object -Last 200
