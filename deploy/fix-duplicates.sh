#!/bin/bash

# ==========================================================
# STALWART CONFIG CLEAN & FIX SCRIPT
# This script removes duplicate entries and applies a clean config.
# ==========================================================

STALWART_CONTAINER="deploy-mailserver-1"

echo "--- ĐANG DỌN DẸP VÀ SỬA LỖI CẤU HÌNH STALWART ---"

# 1. Tìm file config
CONF_FILE=$(docker exec $STALWART_CONTAINER find / -name "config.toml" 2>/dev/null | grep -v "/proc" | head -n 1)
if [ -z "$CONF_FILE" ]; then CONF_FILE="/opt/stalwart-mail/etc/config.toml"; fi

echo "Đang xử lý file: $CONF_FILE"

# 2. Tạo bản sao lưu (Backup)
docker exec $STALWART_CONTAINER cp $CONF_FILE "${CONF_FILE}.bak"

# 3. Sử dụng sed để xóa toàn bộ các dòng liên quan đến OIDC cũ (để bắt đầu sạch)
# Chúng ta sẽ xóa từ dòng có [directory.nextcloud] cho đến hết hoặc xóa các block cụ thể.
# Cách an toàn nhất là xóa các dòng có chứa các từ khóa gây trùng lặp.

docker exec $STALWART_CONTAINER bash -c "sed -i '/\[directory.nextcloud\]/,\$d' $CONF_FILE"
docker exec $STALWART_CONTAINER bash -c "sed -i '/\[authentication.oidc.nextcloud\]/,\$d' $CONF_FILE"

# 4. Ghi lại cấu hình chuẩn duy nhất 1 lần
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

[authentication.oidc.nextcloud]
directory = \"nextcloud\"
EOF"

# 5. Khởi động lại
echo "Đang khởi động lại Mailserver..."
docker restart $STALWART_CONTAINER

echo "--- HOÀN TẤT! ---"
echo "Bạn hãy kiểm tra lại trang https://mail.feelmagic.store xem đã hết lỗi 502 chưa."
