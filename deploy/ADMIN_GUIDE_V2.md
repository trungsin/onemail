# HƯỚNG DẪN CÀI ĐẶT ONEMAIL MASTER V2 (CLEAN INSTALL)

Chào mừng bạn đến với OneMail V2. Đây là bộ cài đặt đã được tối ưu hóa toàn bộ (All-in-one) để giải quyết triệt để các lỗi về OnlyOffice, Mail Server và kết nối nội bộ.

## 1. Chuẩn bị (Trước khi chạy)
1.  Đảm bảo file `.env` của bạn đã có đầy đủ các biến môi trường:
    *   `DOMAIN=feelmagic.store`
    *   `NEXTCLOUD_ADMIN_USER`, `NEXTCLOUD_ADMIN_PASSWORD`
    *   `DB_ROOT_PASSWORD`, `DB_PASSWORD`
    *   `STALWART_ADMIN_PASSWORD`
    *   `ONLYOFFICE_JWT_SECRET` (Khuyên dùng: `OneMailSecret2025`)
2.  Trỏ DNS: Đảm bảo 3 subdomain `cloud`, `office`, `mail` đã trỏ về IP của VPS.

---

## 2. Quy trình Cài đặt Mới
Bạn chỉ cần chạy 1 lệnh duy nhất để thiết lập toàn bộ:

```bash
# Chạy bộ cài Master V2
bash install-v2.sh
```

**Bộ cài này sẽ tự động:**
*   Dọn dẹp hệ thống cũ.
*   Cài đặt Container với cấu hình `extra_hosts` (Thông mạng nội bộ).
*   Bật JWT bảo mật cho OnlyOffice.
*   Thiết lập Trusted Proxies cho Nextcloud.

---

## 3. Hoàn tất cấu hình (Làm 1 lần duy nhất)

### Bước A: Kích hoạt OnlyOffice
1.  Vào `https://cloud.feelmagic.store` -> Settings -> **ONLYOFFICE**.
2.  Bạn sẽ thấy địa chỉ và Secret Key đã được điền sẵn.
3.  Nhấn **Save**. Lúc này tài liệu sẽ mở được ngay lập tức.

### Bước B: Thiết lập SSO cho Mail
1.  Vào Nextcloud -> Settings -> **OIDC Identity Provider**.
2.  Nhấn biểu tượng con mắt để lấy **Client ID** và **Client Secret** (tạo mới nếu chưa có).
3.  Vào `https://mail.feelmagic.store` (Admin / Mật khẩu trong .env).
4.  Vào **Settings** -> **Authentication**.
5.  Thêm OIDC Directory (Nextcloud) với ID và Secret vừa lấy.
6.  Nhấn **Save & Reload**.

---

## 4. Cách sử dụng hàng ngày
*   **Tạo user**: Luôn tạo ở Nextcloud.
*   **Đăng nhập Mail**: Dùng nút "Login with Nextcloud" trên web.
*   **App Mail Nextcloud**: Thêm tài khoản thủ công (Manual) với Host: `mailserver`, Port: `143`, Security: `None`.

---
*Hệ thống V2 được thiết kế để tự phục hồi và ổn định cao nhất. Chúc bạn sử dụng hiệu quả!*
