$ErrorActionPreference = 'Continue'
Set-Location 'C:\Users\ianpa\Desktop\Nova pasta (2)\TesteHypesoft'

Write-Output 'Recreating mongo and mongo-express (no deps)'
docker-compose up -d --force-recreate --no-deps mongo mongo-express
Start-Sleep -Seconds 6

function Check-Url($url, $name) {
    Write-Output "--- $name ($url) ---"
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        Write-Output "StatusCode: $($r.StatusCode)"
        return $r
    } catch {
        Write-Output "Check failed: $($_.Exception.Message)"
        return $null
    }
}

# Mongo UI
$me = Check-Url 'http://localhost:8081' 'Mongo Express'

# Swagger UI
$sw = Check-Url 'http://localhost:5000/swagger' 'Swagger UI'

# Keycloak
$kc = Check-Url 'http://localhost:8080' 'Keycloak'
if ($kc -ne $null) {
    if ($kc.Content -match 'Local access required') {
        Write-Output 'Keycloak shows: Local access required (admin not created via env/bootstrap).'
    } else {
        Write-Output 'Keycloak root page looks OK.'
    }
}

Write-Output '--- checks complete ---'
