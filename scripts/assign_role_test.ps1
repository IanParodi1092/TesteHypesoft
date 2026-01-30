Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token
$headers = @{ Authorization = "Bearer $adminToken"; "Content-Type" = 'application/json' }
$user = Invoke-RestMethod -Headers $headers -Uri 'http://localhost:8080/admin/realms/hypesoft/users?username=manager'
$userId = $user[0].id
$role = Invoke-RestMethod -Headers $headers -Uri 'http://localhost:8080/admin/realms/hypesoft/roles/Manager'
Write-Host "UserId: $userId; RoleId: $($role.id)"
try {
    Invoke-RestMethod -Method Post -Uri "http://localhost:8080/admin/realms/hypesoft/users/$userId/role-mappings/realm" -Headers $headers -Body (@($role) | ConvertTo-Json) -ErrorAction Stop
    Write-Host "Assigned role via test script"
} catch {
    Write-Host "Assign failed: $_"
    if ($_.Exception -and $_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream(); $reader = New-Object System.IO.StreamReader($stream); $text = $reader.ReadToEnd(); Write-Host 'Response body:'; Write-Host $text
    }
}
