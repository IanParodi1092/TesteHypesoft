$ErrorActionPreference = 'Stop'
$timestamp = Get-Date -Format o
Write-Host "Repro start: $timestamp"
# wait for Keycloak realm to be available
$maxAttempts = 60
for ($i = 0; $i -lt $maxAttempts; $i++) {
    try {
        Invoke-RestMethod -Method Get -Uri 'http://localhost:8080/realms/hypesoft/.well-known/openid-configuration' -TimeoutSec 5 -ErrorAction Stop | Out-Null
        Write-Host "Keycloak realm available"
        break
    } catch {
        Start-Sleep -Seconds 1
    }
}

# attempt token
try {
    $body = @{client_id='hypesoft-api';client_secret='hypesoft-api-secret';grant_type='password';username='manager';password='Manager123!'}
    $resp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Body $body -ErrorAction Stop
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    . "$PSScriptRoot\diag_paths.ps1"
    $resp | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'frontend/manager_token_repro_success.json') -Encoding utf8
    Write-Host "Token obtained and saved"
} catch {
    Write-Host "Token request failed: $_"
    if ($_.Exception -and $_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $text = $reader.ReadToEnd()
        $text | Out-File -FilePath (Get-DiagPath 'frontend/manager_token_repro_error.txt') -Encoding utf8
        Write-Host "Error body saved"
    }
}
Start-Sleep -Seconds 1
# dump keycloak logs and extract context around resolve_required_actions
docker-compose logs keycloak --no-color > ..\keycloak_deep_repro_full.log
Select-String -Path ..\keycloak_deep_repro_full.log -Pattern 'resolve_required_actions' -Context 15,15 | Out-File -FilePath (Get-DiagPath 'keycloak_deep_repro_context.txt') -Encoding utf8
Write-Host "Wrote keycloak_deep_repro_full.log and keycloak_deep_repro_context.txt"
# also save tail of logs
Get-Content ..\keycloak_deep_repro_full.log -Tail 400 | Out-File -FilePath (Get-DiagPath 'keycloak_deep_repro_tail.log') -Encoding utf8
Write-Host "Wrote tail log"
Write-Host "Done"