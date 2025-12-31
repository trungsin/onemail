#!/bin/bash

# OneMail Master Installer V2
# This script performs a fresh, clean installation with all fixes pre-applied.

echo "--- OneMail Master Setup V2 Starting ---"

# 0. System Dependency Check & Installation
echo "[0/4] Checking system dependencies..."

install_dependencies() {
    echo "Installing missing dependencies (Docker, Curl, Git)..."
    if [ -f /etc/debian_version ]; then
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg git
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y yum-utils git curl
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo systemctl start docker
        sudo systemctl enable docker
    fi
}

if ! command -v docker &> /dev/null || ! docker compose version &> /dev/null; then
    install_dependencies
else
    echo "Docker and Docker Compose are already installed."
fi

# 0.1 Firewall Configuration (UFW)
echo "[0.1/4] Configuring Firewall (UFW)..."
if command -v ufw &> /dev/null; then
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow 25,143,465,587,993/tcp        # Mail Ports
    sudo ufw allow 8080/tcp                       # Stalwart Admin
    sudo ufw --force enable
    echo "Firewall rules updated and enabled."
else
    echo "UFW not found. Please ensure ports 80, 443, 25, 143, 465, 587, 993, 8080 are open manually."
fi

# 1. Configuration Setup
if [ ! -f .env ]; then
    echo "Error: .env file missing. Please create it first (using env.example as a template)."
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
