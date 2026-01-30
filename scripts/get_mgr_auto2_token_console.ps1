$ErrorActionPreference='Stop'
try {
    $resp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Body @{client_id='hypesoft-api';client_secret='hypesoft-api-secret';grant_type='password';username='mgr_auto2';password='Manager123!'} -ErrorAction Stop
    $resp | ConvertTo-Json -Depth 5 | Out-Host
} catch {
    Write-Host "Token failed: $_"
    if ($_.Exception -and $_.Exception.Response) { $stream = $_.Exception.Response.GetResponseStream(); $r = New-Object System.IO.StreamReader($stream); $text = $r.ReadToEnd(); Write-Host $text }
}
