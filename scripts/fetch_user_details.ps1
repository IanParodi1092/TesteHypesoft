$ErrorActionPreference = 'Stop'
Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$adminToken = (Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Body 'client_id=admin-cli&username=admin&password=admin&grant_type=password' -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop).access_token
$h = @{ Authorization = 'Bearer ' + $adminToken }

foreach ($u in @('manager','mgr_auto2')) {
    try {
        $found = Invoke-RestMethod -Headers $h -Uri "http://localhost:8080/admin/realms/hypesoft/users?username=$u" -Method Get
        if ($found -and $found.Count -gt 0) {
            $id = $found[0].id
            $detail = Invoke-RestMethod -Headers $h -Uri "http://localhost:8080/admin/realms/hypesoft/users/$id" -Method Get
            $detail | ConvertTo-Json -Depth 20 | Out-File -Encoding utf8 "./scripts/user_$u.json"
            Write-Output "Wrote ./scripts/user_$u.json"
        } else {
            Write-Output "$u not found"
        }
    } catch {
        Write-Output ("Failed to fetch $u")
    }
}
