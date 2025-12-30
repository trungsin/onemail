#!/bin/bash

# One-command setup for Ubuntu VPS
# Must be run as root or with sudo

set -e

echo "🚀 Starting VPS Installation of OneMail Collaboration Platform..."

# 1. Update and Install Docker if missing
if ! [ -x "$(command -v docker)" ]; then
    echo "📦 Installing Docker..."
    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

# 2. Check for .env
if [ ! -f .env ]; then
    echo "📄 Creating .env file from template..."
    cp env.example .env
    # Generate secrets
    JWT_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    DB_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    REDIS_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    
    sed -i "s/change_me_jwt/$JWT_SECRET/g" .env
    sed -i "s/change_me_db/$DB_PASS/g" .env
    sed -i "s/change_me_redis/$REDIS_PASS/g" .env
    sed -i "s/DEPLOY_MODE=local/DEPLOY_MODE=vps/g" .env
    
    echo "⚠️  Please edit .env now to set your DOMAIN, OFFICE_DOMAIN, and MAIL_DOMAIN!"
    echo "Example: DOMAIN=cloud.example.com OFFICE_DOMAIN=office.example.com MAIL_DOMAIN=mail.example.com"
    read -p "Press Enter after you have edited .env (or I will use defaults)..."
else
    echo "ℹ️ .env file already exists."
fi

# Load variables
export $(cat .env | grep -v '#' | xargs)

# 3. SSL Setup (Optional but recommended)
echo "🔒 Preparing SSL with Certbot..."
apt-get install -y certbot
# Note: This requires ports 80/443 to be open and domains pointing to this IP
# certbot certonly --standalone -d $DOMAIN -d $OFFICE_DOMAIN --non-interactive --agree-tos -m $ADMIN_EMAIL || true

# 4. Configure Nginx
echo "⚙️ Configuring Nginx..."
mkdir -p certs
# Replace variables in nginx.conf (using sed for broad compatibility)
sed -i "s/\${DOMAIN}/$DOMAIN/g" nginx/nginx.conf
sed -i "s/\${OFFICE_DOMAIN}/$OFFICE_DOMAIN/g" nginx/nginx.conf
sed -i "s/\${MAIL_DOMAIN}/$MAIL_DOMAIN/g" nginx/nginx.conf

# 5. Start Platform
echo "📦 Starting containers in VPS mode..."
docker compose --profile vps up -d

echo "⏳ Waiting for initialization..."
sleep 20

echo "🔧 Configuring Nextcloud..."
docker compose exec -u www-data app php occ config:system:set trusted_domains 1 --value="$DOMAIN"
docker compose exec -u www-data app php occ config:system:set trusted_domains 2 --value="$OFFICE_DOMAIN"
docker compose exec -u www-data app php occ config:system:set trusted_domains 3 --value="$MAIL_DOMAIN"
docker compose exec -u www-data app php occ config:system:set overwrite.cli.url --value="https://$DOMAIN"
docker compose exec -u www-data app php occ config:system:set overwriteprotocol --value="https"

echo "🎨 Setting default quota to 1GB..."
docker compose exec -u www-data app php occ config:system:set default_quota --value="1 GB"

echo "🧩 Enabling OnlyOffice..."
docker compose exec -u www-data app php occ app:install onlyoffice || true
docker compose exec -u www-data app php occ app:enable onlyoffice || true

echo "✅ VPS Installation Complete!"
echo "-------------------------------------------------------"
echo "🌐 Nextcloud:   https://${DOMAIN}"
echo "📝 OnlyOffice:  https://${OFFICE_DOMAIN}"
echo "📧 Mail Admin:  https://${MAIL_DOMAIN}"
echo "-------------------------------------------------------"
