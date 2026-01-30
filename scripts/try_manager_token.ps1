$ErrorActionPreference = 'Stop'
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$PSScriptRoot\diag_paths.ps1"
Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$body = 'client_id=hypesoft-api&client_secret=hypesoft-api-secret&grant_type=password&username=manager&password=Manager123!'
try {
    $r = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Body $body -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    $r | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'frontend/manager_token_after_import.json') -Encoding utf8
    Write-Output 'MANAGER_TOKEN_OK'
} catch {
    if ($_.Exception.Response) {
        $s = $_.Exception.Response.GetResponseStream()
        $sr = New-Object System.IO.StreamReader($s)
        $b = $sr.ReadToEnd()
        $b | Out-File -FilePath (Get-DiagPath 'frontend/manager_token_after_import_error_body.txt') -Encoding utf8
        Write-Output 'MANAGER_TOKEN_FAILED_BODY_SAVED'
    } else {
        Write-Output ('MANAGER_TOKEN_FAILED_MSG: ' + $_.Exception.Message)
    }
}
