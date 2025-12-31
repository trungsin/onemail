# HƯỚNG DẪN QUẢN TRỊ VIÊN ONEMAIL (DAILY ADMIN GUIDE)

Chào mừng bạn đã hoàn tất tích hợp hệ thống OneMail. Dưới đây là quy trình chuẩn để bạn vận hành hệ thống hàng ngày.

## 1. Quy trình tạo Tài khoản Người dùng (SSO)
Hệ thống sử dụng Nextcloud làm trung tâm lưu trữ danh tính. **Luôn tạo người dùng mới tại Nextcloud.**

1.  Truy cập: `https://cloud.feelmagic.store` (Đăng nhập bằng Admin).
2.  Vào mục **Users** (Người dùng).
3.  Tạo người dùng mới với thông tin:
    *   **Username**: Tên đăng nhập (ví dụ: `nguyenvana`).
    *   **Display Name**: Tên hiển thị.
    *   **Password**: Mật khẩu ban đầu.
    *   **Email**: Địa chỉ email họ sẽ sử dụng (ví dụ: `vana@feelmagic.store`).

> [!TIP]
> Ngay sau khi bạn tạo ở Nextcloud, người dùng này có thể dùng chính tài khoản đó để đăng nhập vào Mailserver.

---

## 2. Cấu hình Mail cho Người dùng mới
Người dùng không cần cấu hình phức tạp, họ chỉ cần làm theo các bước sau trong lần đầu tiên:

### Cách A: Dùng trực tiếp trong Nextcloud (Khuyên dùng)
1.  Người dùng đăng nhập vào `https://cloud.feelmagic.store`.
2.  Click vào biểu tượng **Mail** trên thanh menu.
3.  Nextcloud sẽ tự động nhận diện tài khoản. Nếu được hỏi, hãy điền:
    *   **IMAP Host**: `mail.feelmagic.store` (Port 993, SSL/TLS).
    *   **SMTP Host**: `mail.feelmagic.store` (Port 465, SSL/TLS).
    *   **User/Password**: Chính là tài khoản Nextcloud vừa tạo.

### Cách B: Cấu hình Thủ công (Nếu bị lỗi "Not reachable")
Nếu dùng cách tự động bị báo "Not reachable", bạn hãy chuyển sang tab **Manual** và điền:
*   **IMAP Server**: `mailserver` (Đây là tên container nôi bộ) | **Port**: `143` | **Security**: `None` (hoặc STARTTLS)
*   **SMTP Server**: `mailserver` | **Port**: `587` | **Security**: `None` (hoặc STARTTLS)
*   **Username**: Địa chỉ email đầy đủ (ví dụ: `tpnhansu@feelmagic.store`).
*   **Password**: Mật khẩu Nextcloud.

> [!IMPORTANT]
> Việc dùng `mailserver` giúp Nextcloud kết nối trực tiếp trong mạng Docker, bỏ qua tường lửa của VPS.

---

## 3. Quản lý Tài liệu với OnlyOffice
Hệ thống đã được cấu hình tự động nhận diện các file văn phòng.

*   Để tạo mới: Click nút **[+]** -> Chọn Document/Spreadsheet/Presentation.
*   Để chỉnh sửa: Chỉ cần click chuột trái vào file `.docx`, `.xlsx`, hoặc `.pptx`. Trình soạn thảo sẽ mở ra ngay trong tab trình duyệt.
*   **Lưu tự động**: Mọi thay đổi sẽ được lưu ngay lập tức vào Nextcloud.

---

## 4. Xử lý sự cố nhanh
Nếu thấy OnlyOffice báo lỗi kết nối:
1.  Đảm bảo container đang chạy: `docker compose ps`.
2.  Chạy lại kịch bản sửa lỗi nếu cần: `bash fix-onlyoffice-pro.sh`.

---
*Chúc bạn có những trải nghiệm làm việc tuyệt vời cùng OneMail!*
