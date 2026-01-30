Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token

# enable events on realm
$realm = Invoke-RestMethod -Uri 'http://localhost:8080/admin/realms/hypesoft' -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$realm.eventsEnabled = $true
$realm.eventsListeners = @('jboss-logging')
$realm.eventsExpiration = 3600
Invoke-RestMethod -Uri 'http://localhost:8080/admin/realms/hypesoft' -Headers @{ Authorization = "Bearer $adminToken" } -Method Put -Body ($realm | ConvertTo-Json -Depth 10) -ContentType 'application/json'
Write-Output 'Realm events enabled'

# attempt login
$form = @{ grant_type='password'; client_id='hypesoft-api'; client_secret='hypesoft-api-secret'; username='manager'; password='Manager123!' }
try { $resp = Invoke-RestMethod -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Method Post -Body $form -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop; $resp | ConvertTo-Json -Depth 5 | Out-File mgr_debug.json -Encoding utf8; Write-Output 'Token success'; Get-Content mgr_debug.json } catch { Write-Output 'Token error'; if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); $body = $sr.ReadToEnd(); Write-Output $body } else { Write-Output $_.Exception.Message } }

Start-Sleep -Seconds 1

# fetch events
$events = Invoke-RestMethod -Uri 'http://localhost:8080/admin/realms/hypesoft/events?max=50' -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$events | ConvertTo-Json -Depth 10 | Out-File keycloak_events_after.json -Encoding utf8
Write-Output 'Wrote keycloak_events_after.json'
Get-Content keycloak_events_after.json
