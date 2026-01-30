$ErrorActionPreference = 'Stop'
$adminToken = (Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body @{client_id='admin-cli';username='admin';password='admin';grant_type='password'}).access_token
$usersByEmail = Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Uri "http://localhost:8080/admin/realms/hypesoft/users?email=manager@example.com" -ErrorAction SilentlyContinue
if ($usersByEmail) {
    foreach ($u in $usersByEmail) {
        Invoke-RestMethod -Headers @{Authorization = "Bearer $adminToken"} -Method Delete -Uri "http://localhost:8080/admin/realms/hypesoft/users/$($u.id)"
        Write-Host "Deleted user with email manager@example.com: $($u.id)"
    }
} else {
    Write-Host "No user found with email manager@example.com"
}