#!/bin/bash

# OneMail Master Installer V2
# This script performs a fresh, clean installation with all fixes pre-applied.

echo "--- OneMail Master Setup V2 Starting ---"

# 1. Configuration Setup
if [ ! -f .env ]; then
    echo "Error: .env file missing. Please create it first."
    exit 1
fi

# Load variables
export $(grep -v '^#' .env | xargs)

# 2. Cleanup (Optional but recommended for fresh start)
echo "[1/4] Cleaning up old containers..."
docker compose down -v 2>/dev/null

# 3. Launch Services
echo "[2/4] Launching OneMail Stack V2..."
docker compose -f docker-compose.v2.yml up -d

# 4. Post-check & Automated Fixies
echo "[3/4] Waiting for services to stabilize..."
sleep 20

echo "[4/4] Applying Master Connectivity Fixes..."

# Nextcloud internal security
docker exec -u www-data deploy-app-1 php occ config:system:set allow_local_remote_servers --value=true --type=bool
docker exec -u www-data deploy-app-1 php occ config:system:set trusted_proxies 0 --value="172.16.0.0/12"
docker exec -u www-data deploy-app-1 php occ config:system:set trusted_proxies 1 --value="10.0.0.0/8"
docker exec -u www-data deploy-app-1 php occ config:system:set overwriteprotocol --value="https"

# OnlyOffice JWT Auto-Config
JWT_SECRET=${ONLYOFFICE_JWT_SECRET:-OneMailSecret2025}
docker exec -u www-data deploy-app-1 php occ config:app:set onlyoffice DocumentServerUrl --value="https://office.$DOMAIN/"
docker exec -u www-data deploy-app-1 php occ config:app:set onlyoffice jwt_secret --value="$JWT_SECRET"
docker exec -u www-data deploy-app-1 php occ config:app:set onlyoffice jwt_header --value="Authorization"

echo "=========================================================="
echo "ONEMAIL V2 SETUP COMPLETE!"
echo "URL Nextcloud: https://cloud.$DOMAIN"
echo "URL OnlyOffice: https://office.$DOMAIN"
echo "URL Mailserver: https://mail.$DOMAIN"
echo "=========================================================="
echo "TIẾP THEO (TRONG LẦN ĐẦU CÀI ĐẶT):"
echo "1. Vào Nextcloud cài app OIDC Provider."
echo "2. Lấy Client ID/Secret như đã hướng dẫn."
echo "3. Dùng Management UI của Stalwart để thêm OIDC Directory."
echo "=========================================================="
