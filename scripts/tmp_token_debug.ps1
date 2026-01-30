$ErrorActionPreference = 'Stop'
$body = @{client_id='hypesoft-api'; client_secret='hypesoft-api-secret'; grant_type='password'; username='manager'; password='Manager123!'}
try {
    $r = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Body $body -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    $r | ConvertTo-Json -Depth 5 | Out-Host
} catch {
    Write-Host "Exception:" $_.Exception.Message
    if ($_.Exception.Response) {
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $text = $reader.ReadToEnd()
            Write-Host "Response body:"
            Write-Host $text
        } catch {
            Write-Host "Failed to read response stream: $_"
        }
    }
}
