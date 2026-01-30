$ErrorActionPreference = 'Stop'
Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$adminToken = (Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body 'client_id=admin-cli&username=admin&password=admin&grant_type=password' -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop).access_token
$h = @{ Authorization = 'Bearer ' + $adminToken }

$manager = Invoke-RestMethod -Headers $h -Uri 'http://localhost:8080/admin/realms/hypesoft/users?username=manager' -Method Get
if ($manager -and $manager.Count -gt 0) {
    $mid = $manager[0].id
    $creds = Invoke-RestMethod -Headers $h -Uri "http://localhost:8080/admin/realms/hypesoft/users/$mid/credentials" -Method Get
    $creds | ConvertTo-Json -Depth 20 | Out-File -Encoding utf8 './scripts/manager_credentials.json'
    Write-Output 'Wrote ./scripts/manager_credentials.json'
}

$mgr = Invoke-RestMethod -Headers $h -Uri 'http://localhost:8080/admin/realms/hypesoft/users?username=mgr_auto2' -Method Get
if ($mgr -and $mgr.Count -gt 0) {
    $mid = $mgr[0].id
    $creds2 = Invoke-RestMethod -Headers $h -Uri "http://localhost:8080/admin/realms/hypesoft/users/$mid/credentials" -Method Get
    $creds2 | ConvertTo-Json -Depth 20 | Out-File -Encoding utf8 './scripts/mgr_auto2_credentials.json'
    Write-Output 'Wrote ./scripts/mgr_auto2_credentials.json'
}
