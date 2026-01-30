Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'

$realm = 'hypesoft'
# get admin token
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
try { $t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop } catch { Write-Output 'Failed to get admin token'; Write-Output $_.Exception.Message; exit 1 }
$adminToken = $t.access_token

# find manager
$users = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/$realm/users?username=manager" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
if (-not $users -or $users.Count -eq 0) { Write-Output 'Manager user not found'; exit 1 }
$user = $users[0]
$uid = $user.id
Write-Output "Found manager id: $uid"

# Patch user: enabled=true, emailVerified=true, requiredActions=[]
$patch = @{ enabled = $true; emailVerified = $true; requiredActions = @() }
try {
    Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/$realm/users/$uid" -Headers @{ Authorization = "Bearer $adminToken" } -Method Put -Body ($patch | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
    Write-Output 'Patched user: enabled, emailVerified, cleared requiredActions'
} catch { Write-Output 'Patch failed:'; Write-Output $_.Exception.Message; if ($_.Exception.Response) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); Write-Output $sr.ReadToEnd() } }

# Reset password
$pw = @{ type='password'; value='Manager123!'; temporary=$false }
try {
    Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/$realm/users/$uid/reset-password" -Headers @{ Authorization = "Bearer $adminToken" } -Method Put -Body ($pw | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
    Write-Output 'Password reset'
} catch { Write-Output 'Password reset failed:'; Write-Output $_.Exception.Message }

# Ensure credentials exist (read user)
$userDetail = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/$realm/users/$uid" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$userDetail | ConvertTo-Json -Depth 10 | Out-File manager_after_patch.json -Encoding utf8
Write-Output 'Wrote manager_after_patch.json'

# Try password grant for manager
$form = @{ grant_type='password'; client_id='hypesoft-api'; client_secret='hypesoft-api-secret'; username='manager'; password='Manager123!' }
try {
    $resp = Invoke-RestMethod -Uri "http://localhost:8080/realms/$realm/protocol/openid-connect/token" -Method Post -Body $form -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    $resp | ConvertTo-Json -Depth 5 | Out-File mgr_token_after_fix_final.json -Encoding utf8
    Write-Output 'Token response success for manager:'
    Get-Content mgr_token_after_fix_final.json
} catch {
    Write-Output 'Token response error for manager:'
    if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); $body = $sr.ReadToEnd(); Write-Output $body } else { Write-Output $_.Exception.Message }
}

# collect logs
docker logs hypesoft-keycloak --tail 300 > keycloak_after_fix_manager.txt
Write-Output '--- Relevant events ---'
Select-String -Path keycloak_after_fix_manager.txt -Pattern 'resolve_required_actions|LOGIN_ERROR|requiredAction|required-actions' -AllMatches | ForEach-Object { $_.Line }
Write-Output '--- manager_after_patch.json ---'
Get-Content manager_after_patch.json
