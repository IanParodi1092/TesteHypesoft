Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'

# Get admin token on master
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
try { $t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop } catch { Write-Output 'Failed to get master admin token'; Write-Output $_.Exception.Message; exit 1 }
$adminToken = $t.access_token

# Delete realm if exists
try {
    Invoke-RestMethod -Uri 'http://localhost:8080/admin/realms/hypesoft' -Headers @{ Authorization = "Bearer $adminToken" } -Method Delete -ErrorAction Stop
    Write-Output 'Realm deleted'
} catch { Write-Output 'Realm delete returned:'; Write-Output $_.Exception.Message }

# Restart keycloak container to trigger import
Write-Output 'Restarting Keycloak container'
docker restart hypesoft-keycloak | Out-Null
Start-Sleep -Seconds 6

# Wait and tail logs until import message appears
Write-Output 'Waiting for import...'
Start-Sleep -Seconds 6
docker logs hypesoft-keycloak --tail 200 > keycloak_reimport_logs.txt
Get-Content keycloak_reimport_logs.txt | Select-Object -Last 200

# Try manager password grant
$form = @{ grant_type='password'; client_id='hypesoft-api'; client_secret='hypesoft-api-secret'; username='manager'; password='Manager123!' }
try { $resp = Invoke-RestMethod -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -Method Post -Body $form -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop; $resp | ConvertTo-Json -Depth 5 | Out-File -FilePath (Get-DiagPath 'mgr_token_after_reimport.json') -Encoding utf8; Write-Output 'Token success'; Get-Content (Get-DiagPath 'mgr_token_after_reimport.json') } catch { Write-Output 'Token error'; if ($_.Exception.Response -ne $null) { $r = $_.Exception.Response.GetResponseStream(); $sr = New-Object System.IO.StreamReader($r); $body = $sr.ReadToEnd(); Write-Output $body } else { Write-Output $_.Exception.Message } }

# Save final logs
docker logs hypesoft-keycloak --tail 300 > keycloak_after_reimport.txt
Write-Output '--- Relevant events ---'
Select-String -Path keycloak_after_reimport.txt -Pattern 'imported|resolve_required_actions|LOGIN_ERROR' -AllMatches | ForEach-Object { $_.Line }
Write-Output '--- Last 200 lines ---'
Get-Content keycloak_after_reimport.txt | Select-Object -Last 200
