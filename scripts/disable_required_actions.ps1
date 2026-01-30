$ErrorActionPreference = 'Stop'
Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token
$headers = @{ Authorization = "Bearer $adminToken"; 'Content-Type' = 'application/json' }
$realm = 'hypesoft'

$toDisable = @('VERIFY_EMAIL','CONFIGURE_TOTP','UPDATE_PROFILE','UPDATE_PASSWORD','VERIFY_PROFILE')
foreach ($alias in $toDisable) {
    try {
        $prov = Invoke-RestMethod -Method Get -Uri "http://localhost:8080/admin/realms/$realm/authentication/required-actions" -Headers $headers
        $match = $prov | Where-Object { $_.providerId -eq $alias }
        if ($match) {
            $body = @{ providerId = $match.providerId; alias = $match.alias; name = $match.name; enabled = $false; defaultAction = $false; priority = $match.priority } | ConvertTo-Json
            Invoke-RestMethod -Method Put -Uri "http://localhost:8080/admin/realms/$realm/authentication/required-actions/$($match.providerId)" -Headers $headers -Body $body
            Write-Host "Disabled required-action provider: $alias"
        } else {
            Write-Host "Provider $alias not found"
        }
    } catch {
        Write-Host ("Failed to disable {0}: {1}" -f $alias, $_)
    }
}

Write-Host 'Done disabling selected required-action providers'
