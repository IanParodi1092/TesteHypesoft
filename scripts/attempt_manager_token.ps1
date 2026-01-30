$ErrorActionPreference = 'Stop'
try {
    $body = @{client_id='hypesoft-api';client_secret='hypesoft-api-secret';grant_type='password';username='manager';password='manager'}
    $resp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Body $body
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    . "$PSScriptRoot\diag_paths.ps1"
    $resp | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'mgr_token_attempt.json') -Encoding utf8
    Write-Host "Token response saved to mgr_token_attempt.json"
} catch {
    Write-Host "Token request failed: $_"
    if ($_.Exception -and $_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $text = $reader.ReadToEnd()
        $text | Out-File -FilePath (Get-DiagPath 'mgr_token_attempt_error.txt') -Encoding utf8
        Write-Host "Error body saved to mgr_token_attempt_error.txt"
    }
}