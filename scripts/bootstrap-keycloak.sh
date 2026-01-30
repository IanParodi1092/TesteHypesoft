#!/usr/bin/env bash
set -euo pipefail

# Idempotent Keycloak realm importer
# - waits for Keycloak admin API
# - checks if realm 'hypesoft' exists; if not, imports docker/keycloak/realm-export.json

HOST=${KEYCLOAK_URL:-http://localhost:8080}
ADMIN_USER=${KC_BOOTSTRAP_ADMIN_USERNAME:-admin}
ADMIN_PASS=${KC_BOOTSTRAP_ADMIN_PASSWORD:-admin}
REALM_FILE="$(dirname "$0")/../docker/keycloak/realm-export.json"

echo "Keycloak host: $HOST"
echo "Waiting Keycloak admin API..."

for i in $(seq 1 30); do
  if curl -s "$HOST/realms/master" >/dev/null; then
    echo "Keycloak reachable"
    break
  fi
  echo -n "."
  sleep 2
done

echo "Requesting admin token..."
TOKEN=$(curl -s -X POST "$HOST/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&client_id=admin-cli&username=${ADMIN_USER}&password=${ADMIN_PASS}" | jq -r .access_token)

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "Failed to obtain admin token" >&2
  exit 1
fi

echo "Checking if realm 'hypesoft' exists..."
HTTP=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" "$HOST/admin/realms/hypesoft")
if [ "$HTTP" = "200" ]; then
  echo "Realm 'hypesoft' already exists — skipping import"
  exit 0
fi

echo "Importing realm from $REALM_FILE..."
curl -s -X POST "$HOST/admin/realms" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" --data-binary "@$REALM_FILE"
echo "Import request sent."

echo "Done."
