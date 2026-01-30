Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'
$tokenReq = @{ client_id='admin-cli'; grant_type='password'; username='admin'; password='admin' }
$t = Invoke-RestMethod -Uri 'http://localhost:8080/realms/master/protocol/openid-connect/token' -Method Post -Body $tokenReq -ContentType 'application/x-www-form-urlencoded'
$adminToken = $t.access_token

# Executions ids found earlier
$condId = '4a69fa3c-d335-47c1-a279-b4646ca74a6e'
$otpId = '60318d8a-5424-487e-8fe5-1b045f133d9a'

# Try to update requirement for conditional to CONDITIONAL
try {
    Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/executions/$condId" -Method Put -Headers @{ Authorization = "Bearer $adminToken" } -Body (@{ requirement = 'CONDITIONAL' } | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
    Write-Output "Updated $condId to CONDITIONAL"
} catch { Write-Output "Failed to update conditional execution: $_.Exception.Message" }

# Update OTP execution to ALTERNATIVE
try {
    Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/executions/$otpId" -Method Put -Headers @{ Authorization = "Bearer $adminToken" } -Body (@{ requirement = 'ALTERNATIVE' } | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
    Write-Output "Updated $otpId to ALTERNATIVE"
} catch { Write-Output "Failed to update otp execution: $_.Exception.Message" }

# Re-fetch executions
$flowAlias = 'Direct Grant - Conditional OTP'
$executions = Invoke-RestMethod -Uri "http://localhost:8080/admin/realms/hypesoft/authentication/flows/$([uri]::EscapeDataString($flowAlias))/executions" -Headers @{ Authorization = "Bearer $adminToken" } -Method Get
. "$PSScriptRoot\diag_paths.ps1"
$executions | ConvertTo-Json -Depth 10 | Out-File -FilePath (Get-DiagPath 'direct_grant_conditional_after.json') -Encoding utf8
Write-Output 'Wrote direct_grant_conditional_after.json'; Get-Content direct_grant_conditional_after.json
