Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'

# Get admin token from master realm
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
try {
    $t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
} catch {
    Write-Output 'Failed to get admin token'; Write-Output $_.Exception.Message; exit 1
}

$adminToken = $t.access_token
Write-Output 'Admin token obtained, querying user manager...'

$users = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/users?username=manager" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
$users | ConvertTo-Json -Depth 10 | Out-File manager_user.json -Encoding utf8
Write-Output 'Wrote manager_user.json'
Get-Content manager_user.json
