#!/bin/bash

# OneMail OnlyOffice Auto-Fix Script
# This script configures Nextcloud to work with OnlyOffice in a Docker environment.

echo "--- Starting OnlyOffice Auto-Fix ---"

# 1. Get Container Information
APP_CONTAINER="deploy-app-1"
OO_CONTAINER="deploy-onlyoffice-1"

# 2. Configure Nextcloud System Settings
echo "[1/4] Configuring Nextcloud System Settings..."
docker exec -u www-data $APP_CONTAINER php occ config:system:set overwriteprotocol --value="https"
docker exec -u www-data $APP_CONTAINER php occ config:system:set overwritehost --value="cloud.feelmagic.store"
docker exec -u www-data $APP_CONTAINER php occ config:system:set overwrite.cli.url --value="https://cloud.feelmagic.store"
docker exec -u www-data $APP_CONTAINER php occ config:system:set allow_local_remote_servers --value=true --type=bool

# 3. Handle Trusted Domains
echo "[2/4] Updating Trusted Domains..."
# Add 'app' as a trusted domain for internal requests
docker exec -u www-data $APP_CONTAINER php occ config:system:set trusted_domains 5 --value="app"
# Add 'onlyoffice' just in case
docker exec -u www-data $APP_CONTAINER php occ config:system:set trusted_domains 6 --value="onlyoffice"

# 4. Configure OnlyOffice App Settings directly
echo "[3/4] Configuring OnlyOffice App Connector..."
# Set public URL
docker exec -u www-data $APP_CONTAINER php occ config:app:set onlyoffice DocumentServerUrl --value="https://office.feelmagic.store/"
# Set internal URL for Nextcloud to call OnlyOffice
docker exec -u www-data $APP_CONTAINER php occ config:app:set onlyoffice DocumentServerInternalUrl --value="http://onlyoffice/"
# Set internal URL for OnlyOffice to call Nextcloud
docker exec -u www-data $APP_CONTAINER php occ config:app:set onlyoffice StorageUrl --value="http://app/"
# Disable certificate verification for internal requests
docker exec -u www-data $APP_CONTAINER php occ config:app:set onlyoffice verify_peer_off --value="true"
# Disable JWT if not used (standard for this setup)
docker exec -u www-data $APP_CONTAINER php occ config:app:set onlyoffice jwt_secret --value=""

# 5. Refresh OnlyOffice
echo "[4/4] Refreshing configuration..."
# No restart needed for NC config changes via OCC, but checking connectivity
docker exec -u www-data $APP_CONTAINER php occ onlyoffice:check

echo "--- OnlyOffice Fix Applied Successfully! ---"
echo "Please try opening your document now in Nextcloud."
