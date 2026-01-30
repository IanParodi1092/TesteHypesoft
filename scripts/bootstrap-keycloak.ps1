Param(
    [string]$KeycloakUrl = "http://localhost:8080",
    [string]$AdminUser = "admin",
    [string]$AdminPass = "admin",
    [string]$RealmFile = "..\docker\keycloak\realm-export.json"
)

Write-Host "Keycloak URL: $KeycloakUrl"

# Wait for Keycloak
for ($i=0; $i -lt 30; $i++) {
    try {
        $r = Invoke-WebRequest -Uri "$KeycloakUrl/realms/master" -UseBasicParsing -Method Get -TimeoutSec 5 -ErrorAction Stop
        Write-Host 'Keycloak reachable'
        break
    } catch {
        Write-Host -NoNewline '.'
        Start-Sleep -Seconds 2
    }
}

Write-Host "Requesting admin token..."
$body = @{ grant_type = 'password'; client_id = 'admin-cli'; username = $AdminUser; password = $AdminPass }
$tokenResp = Invoke-RestMethod -Method Post -Uri "$KeycloakUrl/realms/master/protocol/openid-connect/token" -ContentType 'application/x-www-form-urlencoded' -Body $body
if (-not $tokenResp.access_token) { Write-Error 'Failed to obtain admin token'; exit 1 }
$token = $tokenResp.access_token

Write-Host "Checking if realm 'hypesoft' exists..."
try {
    $resp = Invoke-RestMethod -Method Get -Uri "$KeycloakUrl/admin/realms/hypesoft" -Headers @{ Authorization = ('Bearer ' + $token) } -ErrorAction Stop
    Write-Host "Realm 'hypesoft' exists - skipping import"
    exit 0
} catch {
    Write-Host "Realm not found, importing..."
}

$realmPath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) $RealmFile
if (-not (Test-Path $realmPath)) { Write-Error "Realm file not found: $realmPath"; exit 1 }

Invoke-RestMethod -Method Post -Uri "$KeycloakUrl/admin/realms" -Headers @{ Authorization = ('Bearer ' + $token) } -ContentType 'application/json' -InFile $realmPath
Write-Host 'Import request sent.'
