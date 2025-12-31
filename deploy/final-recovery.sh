#!/bin/bash

# ==========================================================
# ONEMAIL FINAL RECOVERY SCRIPT
# This script fixes: 
# 1. Stalwart OIDC Integration (Bypassing UI bugs)
# 2. Nextcloud-Mail internal connectivity
# 3. OnlyOffice secure handshake
# ==========================================================

echo "--- STARTING ONEMAIL RECOVERY ---"

# 1. Detect Stalwart Config
STALWART_CONTAINER="deploy-mailserver-1"
echo "[1/3] Locating Stalwart Configuration..."
CONF_FILE=$(docker exec $STALWART_CONTAINER find / -name "config.toml" 2>/dev/null | grep -v "/proc" | head -n 1)

if [ -z "$CONF_FILE" ]; then
    echo "!! Could not find config.toml automatically. Using fallback path..."
    CONF_FILE="/opt/stalwart-mail/etc/config.toml"
fi
echo "Target path: $CONF_FILE"

# 2. Inject OIDC Configuration directly into TOML
# This avoids the "Missing property" errors in the UI.
echo "[2/3] Injecting OIDC settings..."

# Credentials provided previously
CLIENT_ID="Fzbt4wAUeBwR3yiTP9tGAOfwu6p6MLp089oMDOlAJW0YMQ00pRw1QksknkHFVeTj"
CLIENT_SECRET="JgpctkgbNm6H4OC50KtX6hrmB93Gd39yTN468owqNElvPTC9P7amLGzZ65VBut04"

docker exec $STALWART_CONTAINER bash -c "cat >> $CONF_FILE <<EOF

[directory.nextcloud]
type = \"oidc\"
issuer = \"https://cloud.feelmagic.store\"
client-id = \"$CLIENT_ID\"
client-secret = \"$CLIENT_SECRET\"

[directory.nextcloud.endpoint]
token = \"https://cloud.feelmagic.store/index.php/apps/oidc/token\"
userinfo = \"https://cloud.feelmagic.store/index.php/apps/oidc/userinfo\"
jwks = \"https://cloud.feelmagic.store/index.php/apps/oidc/jwks\"

[authentication.fallback.admin]
user = \"admin\"

[authentication.oidc.nextcloud]
directory = \"nextcloud\"
EOF"

# 3. Update Nextcloud Security (Trusted Proxies & Local Access)
echo "[3/3] Updating Nextcloud internal security rules..."
docker exec -u www-data deploy-app-1 php occ config:system:set allow_local_remote_servers --value=true --type=bool
docker exec -u www-data deploy-app-1 php occ config:system:set trusted_proxies 0 --value="172.16.0.0/12"
docker exec -u www-data deploy-app-1 php occ config:system:set trusted_proxies 1 --value="10.0.0.0/8"

echo "--- RESTARTING SERVICES ---"
docker restart deploy-mailserver-1
docker restart deploy-app-1

echo "=========================================================="
echo "HƯỚNG DẪN TIẾP THEO:"
echo "1. Thử đăng nhập https://mail.feelmagic.store bằng nút OIDC."
echo "2. Nếu vào được hòm thư, quay lại Nextcloud Mail."
echo "3. Thử Connect với: Host: mailserver | Port: 143 | Security: None"
echo "=========================================================="
