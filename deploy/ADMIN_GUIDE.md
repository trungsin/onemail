# Admin Guide - OneMail Collaboration Platform

Welcome to your self-hosted collaboration platform. This guide explains how to manage your Nextcloud + OnlyOffice instance.

## 🔑 1. Initial Login
- **URL**: `http://localhost:8080` (Local) or `https://cloud.yourdomain.com` (VPS)
- **User**: `admin` (or what you set in `.env`)
- **Password**: (Check `NEXTCLOUD_ADMIN_PASSWORD` in `.env`)

## 💾 2. Managing User Quota
By default, the system is configured to **1GB per user** via the install script.
To change this manually:
1. Click your profile icon (top right) -> **Administration settings**.
2. Go to **Users** (left sidebar).
3. Find the user you want to edit.
4. Click the **...** (three dots) or looking for the **Quota** column.
5. Select "1 GB" or enter a custom value.

## ➕ 3. Creating & Deleting Users
1. Go to your profile icon -> **Users**.
2. **Create**: Click "+ New user" at the top. Enter Username, Display Name, and Password. Assign to a group if needed.
3. **Delete**: Click the trash icon or the three dots menu next to the user name and select "Delete user".

## 📝 4. Enabling OnlyOffice Integration
The install script attempts to enable this automatically, but follow these steps to verify or manually configure:
1. Go to **Administration settings** -> **ONLYOFFICE** (bottom of the left sidebar).
2. **Document Editing Service address**:
   - Local: `http://localhost:8081`
   - VPS: `https://office.yourdomain.com`
3. **Document Editing Service address for internal requests from server**:
   - Both: `http://onlyoffice/` (This uses the internal Docker network).
4. **Secret Key**: Copy the `ONLYOFFICE_JWT_SECRET` from your `.env` file.
5. Click **Save**.
6. Check the file types (DOCX, XLSX, PPTX) you want to open with OnlyOffice.

## 🇻🇳 5. Vietnamese Support & PDF Preview
- **Vietnamese**: Nextcloud supports UTF-8 by default. You can upload files with Vietnamese names (e.g., `Báo cáo quý 1.docx`) without issues.
- **PDF Preview**: The system is configured to generate previews for PDF files automatically.

## 🔧 Troubleshooting
- **OnlyOffice not opening**: 
  - Ensure the "Internal requests" address is set to `http://onlyoffice/`.
  - Check if the JWT Secret matches the one in `.env`.
  - Check browser console for "Mixed Content" errors (if using HTTP on local vs HTTPS on VPS).
- **Nextcloud not starting**:
  - Check logs: `docker compose logs -f app`
  - Ensure the database is healthy: `docker compose ps`
- **Mailcow Conflict**: 
  - If you have Mailcow on the same server, change `HTTP_PORT` in `.env` to something other than 80 (e.g., 8080) and use a different Nginx configuration or a common reverse proxy.

## 🚀 Deployment Commands (Reminder)
- **Start**: `docker compose up -d`
- **Stop**: `docker compose down`
- **Restart**: `docker compose restart`
- **View Logs**: `docker compose logs -f`
