param(
    [string]$KeycloakBaseUrl = "http://localhost:8080",
    [string]$Realm = "hypesoft",
    [string]$AdminUser = "admin",
    [string]$AdminPass = "admin",
    [string]$RealmExportPath = "docker/keycloak/realm-export.json"
)

# Purpose: lightweight, safe checks to help prepare Keycloak for production.
# - Verifica que o `realm-export.json` existe e contém um flow `direct grant` customizado
# - Verifica que o realm em execução tem `directGrantFlow` apontando para o mesmo alias
# - NÃO desativa required-actions nem aplica mudanças destrutivas

function Get-AdminToken {
    param($baseUrl, $user, $pass)
    $body = @{ client_id = 'admin-cli'; username = $user; password = $pass; grant_type = 'password' }
    $resp = Invoke-RestMethod -Method Post -Uri "$baseUrl/realms/master/protocol/openid-connect/token" -Body $body -ErrorAction Stop
    return $resp.access_token
}

Write-Output "[prepare_keycloak_prod] Starting checks against $KeycloakBaseUrl (realm: $Realm)"
if (-not (Test-Path $RealmExportPath)) {
    Write-Error "realm-export.json not found at $RealmExportPath. Put the production export there and re-run."
    exit 2
}

$export = Get-Content $RealmExportPath -Raw | ConvertFrom-Json

$flowExistsInExport = $false
if ($export.authenticationFlows) {
    foreach ($f in $export.authenticationFlows) {
        if ($f.alias -eq 'direct grant' -and $f.builtIn -eq $false) { $flowExistsInExport = $true; break }
    }
}

if (-not $flowExistsInExport) {
    Write-Warning "realm-export.json does not contain a top-level custom 'direct grant' flow. Recommended for prod."
    Write-Output "Add a non-builtIn 'direct grant' authenticationFlow that includes username+password executions. See docs/KEYCLOAK_PROD.md"
}

try {
    $token = Get-AdminToken -baseUrl $KeycloakBaseUrl -user $AdminUser -pass $AdminPass
} catch {
    Write-Error "Failed to get admin token: $_"
    exit 3
}

$realmResp = Invoke-RestMethod -Headers @{ Authorization = "Bearer $token" } -Uri "$KeycloakBaseUrl/admin/realms/$Realm" -ErrorAction Stop

if ($realmResp.directGrantFlow -ne 'direct grant') {
    Write-Warning "Running realm has directGrantFlow='$($realmResp.directGrantFlow)'. Recommended alias is 'direct grant' (custom, builtIn=false)."
    Write-Output "If you rely on a custom flow, import the exported realm or update the realm via a controlled migration."
} else {
    Write-Output "Realm's directGrantFlow is already set to 'direct grant'."
}

Write-Output "Checks complete. See docs/KEYCLOAK_PROD.md for next steps to import and keep production parity."
