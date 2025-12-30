#!/bin/bash

# One-command setup for Local (WSL2 / Docker Desktop)
# No sudo required if docker is configured correctly

set -e

echo "🚀 Starting Local Installation of OneMail Collaboration Platform..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "📄 Creating .env file from template..."
    cp env.example .env
    # Generate a random JWT secret
    JWT_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    sed -i "s/change_me_jwt/$JWT_SECRET/g" .env
    echo "✅ .env created. You can edit it to change ports."
else
    echo "ℹ️ .env file already exists. Skipping creation."
fi

# Load environment variables
export $(cat .env | grep -v '#' | xargs)

echo "📦 Pulling and starting containers..."
docker compose up -d

echo "⏳ Waiting for Nextcloud to initialize (this may take a minute)..."
# Simple wait loop for Nextcloud
until docker compose exec -u www-data app php occ status > /dev/null 2>&1; do
    echo -n "."
    sleep 5
done
echo " "

echo "🔧 Configuring Nextcloud..."
# Add localhost and IP to trusted domains
docker compose exec -u www-data app php occ config:system:set trusted_domains 1 --value="localhost"
docker compose exec -u www-data app php occ config:system:set trusted_domains 2 --value="${DOMAIN}"
docker compose exec -u www-data app php occ config:system:set redis host --value="redis"
docker compose exec -u www-data app php occ config:system:set redis port --value="6379"
docker compose exec -u www-data app php occ config:system:set redis password --value="${REDIS_PASSWORD}"
docker compose exec -u www-data app php occ config:system:set memcache.local --value="\OC\Memcache\APCu"
docker compose exec -u www-data app php occ config:system:set memcache.distributed --value="\OC\Memcache\Redis"
docker compose exec -u www-data app php occ config:system:set memcache.locking --value="\OC\Memcache\Redis"

echo "🎨 Setting default quota to 1GB..."
docker compose exec -u www-data app php occ config:system:set default_quota --value="1 GB"

echo "🧩 Enabling OnlyOffice and Preview support..."
# These might take a while as they download apps
docker compose exec -u www-data app php occ app:install onlyoffice || true
docker compose exec -u www-data app php occ app:enable onlyoffice || true

# PDF and Vietnamese support (Nextcloud default is usually good, but we can ensure preview generators)
docker compose exec -u www-data app php occ config:system:set preview_max_x --value=2048
docker compose exec -u www-data app php occ config:system:set preview_max_y --value=2048

echo "✅ Installation Complete!"
echo "-------------------------------------------------------"
echo "🌐 Nextcloud: http://localhost:${HTTP_PORT}"
echo "📝 OnlyOffice: http://localhost:${ONLYOFFICE_PORT}"
echo "👤 Admin User: ${NEXTCLOUD_ADMIN_USER}"
echo "🔑 Admin Pass: ${NEXTCLOUD_ADMIN_PASSWORD}"
echo "-------------------------------------------------------"
echo "Next Step: Log in to Nextcloud, go to Administration Settings -> ONLYOFFICE,"
echo "and set Document Editing Service address to http://localhost:${ONLYOFFICE_PORT}"
echo "Set Service address for internal requests from server to http://onlyoffice/"
echo "JWT Secret: $JWT_SECRET"
