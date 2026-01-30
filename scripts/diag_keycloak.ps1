Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'

docker logs hypesoft-keycloak --tail 200 > keycloak_before.txt

$form = @{ 
    grant_type='password';
    client_id='hypesoft-api';
    client_secret='hypesoft-api-secret';
    username='manager';
    password='Manager123!'
}

try {
    $resp = Invoke-RestMethod -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Method Post -Body $form -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    . "$PSScriptRoot\diag_paths.ps1"
    $resp | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'mgr_debug.json') -Encoding utf8
    Write-Output 'Token response (success):'
    Get-Content mgr_debug.json
} catch {
    Write-Output 'Token response (error):'
    if ($_.Exception.Response -ne $null) {
        $r = $_.Exception.Response.GetResponseStream()
        $sr = New-Object System.IO.StreamReader($r)
        $body = $sr.ReadToEnd()
        Write-Output $body
    } else {
        Write-Output $_.Exception.Message
    }
}

docker logs hypesoft-keycloak --tail 500 > keycloak_after.txt
Write-Output '--- Relevant log lines (resolve_required_actions) ---'
Select-String -Path keycloak_after.txt -Pattern 'resolve_required_actions' -AllMatches | ForEach-Object { $_.Line }
Write-Output '--- Full tail (last 200 lines) ---'

docker logs hypesoft-keycloak --tail 200
