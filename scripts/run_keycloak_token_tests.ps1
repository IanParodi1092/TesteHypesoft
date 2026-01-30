$ErrorActionPreference = 'Stop'
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$PSScriptRoot\diag_paths.ps1"
Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'

Write-Output '--- Manager token attempt ---'
try {
    $managerBody = 'client_id=hypesoft-api&client_secret=hypesoft-api-secret&grant_type=password&username=manager&password=manager'
    $r = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Body $managerBody -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    $r | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'frontend/manager_token_direct_test.json') -Encoding utf8
    Write-Output 'MANAGER_TOKEN_OK'
} catch {
    if ($_.Exception.Response) {
        $s = $_.Exception.Response.GetResponseStream()
        $sr = New-Object System.IO.StreamReader($s)
        $b = $sr.ReadToEnd()
        $b | Out-File -FilePath (Get-DiagPath 'frontend/manager_token_direct_error_body.txt') -Encoding utf8
        Write-Output 'MANAGER_TOKEN_FAILED_BODY_SAVED'
    } else {
        Write-Output ('MANAGER_TOKEN_FAILED_MSG: ' + $_.Exception.Message)
    }
}

Write-Output '--- Inspect client hypesoft-api ---'
$adminToken = (Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body 'client_id=admin-cli&username=admin&password=admin&grant_type=password' -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop).access_token
$h = @{ Authorization = 'Bearer ' + $adminToken }
$clients = Invoke-RestMethod -Uri 'http://localhost:8080/admin/realms/hypesoft/clients?clientId=hypesoft-api' -Headers $h -Method Get
$clients | ConvertTo-Json -Depth 10 | Out-File -FilePath (Get-DiagPath 'scripts/client_hypesoft_api.json') -Encoding utf8
if ($clients -and $clients.Count -gt 0) {
    $id = $clients[0].id
    $client = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/clients/$id" -Headers $h
    $client | ConvertTo-Json -Depth 20 | Out-File -FilePath (Get-DiagPath 'scripts/client_hypesoft_api_detail.json') -Encoding utf8
    try {
        $secret = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/clients/$id/client-secret" -Headers $h -Method Get
        $secret | ConvertTo-Json -Depth 10 | Out-File -FilePath (Get-DiagPath 'scripts/client_hypesoft_api_secret.json') -Encoding utf8
    } catch {
        Write-Output 'No secret endpoint or failed to fetch secret'
    }
} else {
    Write-Output 'Client not found'
}

Write-Output '--- mgr_auto2 token attempt ---'
try {
    $mgrBody = 'client_id=hypesoft-api&client_secret=hypesoft-api-secret&grant_type=password&username=mgr_auto2&password=Manager123!'
    $r2 = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Body $mgrBody -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    $r2 | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'frontend/mgr_auto2_token_direct_test.json') -Encoding utf8
    Write-Output 'MGR_AUTO2_TOKEN_OK'
} catch {
    Write-Output 'MGR_AUTO2_TOKEN_FAILED — creating mgr_auto2 and retrying'
    try {
        & .\create_mgr_auto2.ps1
    } catch { Write-Output 'create_mgr_auto2.ps1 failed' }
    try {
        $r3 = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Body $mgrBody -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
        $r3 | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'frontend/mgr_auto2_token_direct_test.json') -Encoding utf8
        Write-Output 'MGR_AUTO2_TOKEN_OK_AFTER_CREATE'
    } catch {
        Write-Output 'MGR_AUTO2_TOKEN_STILL_FAILED'
    }
}

Write-Output '--- Finished token tests ---'
