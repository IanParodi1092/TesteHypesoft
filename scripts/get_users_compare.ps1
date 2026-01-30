$ErrorActionPreference = 'Stop'
$tokenResponse = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}
$token = $tokenResponse.access_token
# manager id (existing seeded)
$manager = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri "http://localhost:8080/admin/realms/hypesoft/users?username=manager"
if ($manager -is [array]) { $managerId = $manager[0].id } else { $managerId = $manager.id }
# mgr_auto2 id from token file
# locate mgr_auto2 token file in workspace
$found = Get-ChildItem -Path .. -Recurse -Filter 'mgr_auto2_token.json' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $found) { $found = Get-ChildItem -Path . -Recurse -Filter 'mgr_auto2_token.json' -ErrorAction SilentlyContinue | Select-Object -First 1 }
if (-not $found) { Write-Host "mgr_auto2_token.json not found in workspace"; exit 1 }
$tokenFile = $found.FullName
$mgrToken = Get-Content $tokenFile -Raw | ConvertFrom-Json
$mgrAuto2Id = $mgrToken.sub
# fetch details for each
function fetchDetails($id, $prefix) {
    $user = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$id"
    $creds = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$id/credentials"
    $feds = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$id/federated-identity"
    $roles = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri "http://localhost:8080/admin/realms/hypesoft/users/$id/role-mappings/realm"
    $obj = @{ user = $user; credentials = $creds; federatedIdentities = $feds; realmRoleMappings = $roles }
    $obj | ConvertTo-Json -Depth 20 | Out-File -Encoding utf8 "./${prefix}_full.json"
    Write-Host "Wrote ${prefix}_full.json"
}
fetchDetails $managerId 'manager'
fetchDetails $mgrAuto2Id 'mgr_auto2'
Write-Host "Done fetching user details"