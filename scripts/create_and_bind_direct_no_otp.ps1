Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'

# Get admin token
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
try { $t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop } catch { Write-Output 'Failed to get admin token'; Write-Output $_.Exception.Message; exit 1 }
$adminToken = $t.access_token

$realm = 'hypesoft'
$newFlowAlias = 'direct-grant-no-otp'

# 1) Create new top-level flow
$flowObj = @{ alias = $newFlowAlias; description = 'Direct grant flow without OTP (created by script)'; providerId = 'basic-flow'; topLevel = $true; builtIn = $false }
try {
    Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/$realm/authentication/flows" -Headers @{ Authorization = "Bearer $adminToken" } -Method Post -Body ($flowObj | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
    Write-Output "Created flow $newFlowAlias"
} catch {
    Write-Output "Create flow failed (may already exist): $_.Exception.Message"
    if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); Write-Output $sr.ReadToEnd() }
}

# 2) Add executions: username and password
$executions = @(
    @{ provider = 'direct-grant-validate-username'; requirement = 'REQUIRED' },
    @{ provider = 'direct-grant-validate-password'; requirement = 'REQUIRED' }
)
foreach ($ex in $executions) {
    try {
        Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/$realm/authentication/flows/$newFlowAlias/executions/execution" -Headers @{ Authorization = "Bearer $adminToken" } -Method Post -Body ($ex | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
        Write-Output "Added execution $($ex.provider) to $newFlowAlias"
    } catch {
        Write-Output "Add execution failed for $($ex.provider): $_.Exception.Message"
        if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); Write-Output $sr.ReadToEnd() }
    }
}

# 3) Update realm to bind directGrantFlow to new flow
try {
    $realmObj = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/$realm" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get -ErrorAction Stop
    $realmObj.directGrantFlow = $newFlowAlias
    Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/$realm" -Headers @{ Authorization = "Bearer $adminToken" } -Method Put -Body ($realmObj | ConvertTo-Json -Depth 20) -ContentType 'application/json' -ErrorAction Stop
    Write-Output "Bound realm directGrantFlow -> $newFlowAlias"
} catch {
    Write-Output "Failed to bind realm flow: $_.Exception.Message"
    if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); Write-Output $sr.ReadToEnd() }
}

# 4) Test password grant for manager
$form = @{ grant_type='password'; client_id='hypesoft-api'; client_secret='hypesoft-api-secret'; username='manager'; password='Manager123!' }
try {
    $resp = Invoke-RestMethod -Uri "http://localhost:8080/realms/$realm/protocol/openid-connect/token" -Method Post -Body $form -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    . "$PSScriptRoot\diag_paths.ps1"
    $resp | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'mgr_token_after_bind.json') -Encoding utf8
    Write-Output 'Token response success for manager:'
    Get-Content mgr_token_after_bind.json
} catch {
    Write-Output 'Token response error for manager:'
    if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); $body = $sr.ReadToEnd(); Write-Output $body } else { Write-Output $_.Exception.Message }
}

# 5) Output logs and current flow executions
docker logs hypesoft-keycloak --tail 300 > keycloak_after_bind.txt
Write-Output '--- Keycloak relevant lines ---'
Select-String -Path keycloak_after_bind.txt -Pattern 'imported|LOGIN_ERROR|resolve_required_actions|direct-grant-no-otp' -AllMatches | ForEach-Object { $_.Line }
Write-Output '--- Direct grant parent executions now ---'
$parentExecs = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/$realm/authentication/flows/direct%20grant/executions" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$parentExecs | ConvertTo-Json -Depth 10 | Out-File -FilePath (Get-DiagPath 'direct_grant_parent_exec_postbind.json') -Encoding utf8
Get-Content direct_grant_parent_exec_postbind.json | Write-Output
