Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token

# get client
$clients = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/clients?clientId=hypesoft-api" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$client = $clients[0]
$client.serviceAccountsEnabled = $false
# PUT update
Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/clients/$($client.id)" -Headers @{ Authorization = "Bearer $adminToken" } -Method Put -Body ($client | ConvertTo-Json -Depth 10) -ContentType 'application/json'
Write-Output 'Updated client: serviceAccountsEnabled=false'

# Try password grant for manager
$form = @{ grant_type='password'; client_id='hypesoft-api'; client_secret='hypesoft-api-secret'; username='manager'; password='Manager123!' }
try {
    $resp = Invoke-RestMethod -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Method Post -Body $form -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    $resp | ConvertTo-Json -Depth 5 | Out-File mgr_debug_after_update.json -Encoding utf8
    Write-Output 'Token response success:'
    Get-Content mgr_debug_after_update.json
} catch {
    Write-Output 'Token response error after update:'
    if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); $body = $sr.ReadToEnd(); Write-Output $body } else { Write-Output $_.Exception.Message }
}

docker logs hypesoft-keycloak --tail 300 > keycloak_after_update_client.txt
Write-Output '--- Recent Keycloak logs ---'
Get-Content keycloak_after_update_client.txt | Select-Object -Last 200
