param(
    [string]$KeycloakBaseUrl = "http://localhost:8080",
    [string]$Realm = "hypesoft",
    [string]$AdminUser = "admin",
    [string]$AdminPass = "admin",
    [string]$OutPath = "docker/keycloak/realm-export.json"
)

function Get-AdminToken {
    param($baseUrl, $user, $pass)
    $body = @{ client_id = 'admin-cli'; username = $user; password = $pass; grant_type = 'password' }
    $resp = Invoke-RestMethod -Method Post -Uri "$baseUrl/realms/master/protocol/openid-connect/token" -Body $body -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    return $resp.access_token
}

Write-Output "[export_realm_from_running] Exporting realm '$Realm' from $KeycloakBaseUrl"

try {
    $token = Get-AdminToken -baseUrl $KeycloakBaseUrl -user $AdminUser -pass $AdminPass
} catch {
    Write-Error "Failed to get admin token: $_"
    exit 2
}

# Ensure output directory exists
$headers = @{ Authorization = "Bearer $token" }
$outDir = Split-Path $OutPath -Parent
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

# Try partial export (POST) which is supported by Keycloak Admin API
try {
    $uri = "$KeycloakBaseUrl/admin/realms/$Realm/partial-export?exportClients=true&exportGroupsAndRoles=true&exportUsers=true"
    Write-Output "Attempting partial-export via POST $uri"
    $body = @{ "exportUsers" = $true }
    $export = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body ($body | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
    $export | ConvertTo-Json -Depth 50 | Out-File -Encoding utf8 $OutPath
    Write-Output "Wrote partial export to $OutPath"
    exit 0
} catch {
    Write-Warning "Partial-export POST failed: $($_.Exception.Message). Falling back to GET realm representation."
}

# Fallback: GET realm representation
try {
    $uri2 = "$KeycloakBaseUrl/admin/realms/$Realm"
    Write-Output "Fetching realm via GET $uri2"
    $realmObj = Invoke-RestMethod -Method Get -Uri $uri2 -Headers $headers -ErrorAction Stop
    $realmObj | ConvertTo-Json -Depth 50 | Out-File -Encoding utf8 $OutPath
    Write-Output "Wrote realm representation to $OutPath (note: this may not be a full realm export)."
    exit 0
} catch {
    Write-Error "Failed to fetch realm: $($_.Exception.Message)"
    exit 3
}
