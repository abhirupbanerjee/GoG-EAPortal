# Password Reference Guide - GoG-EAPortal

## Overview
This document explains every password/credential in your `.env` file and where it's used.

---

## 🔐 Credential Categories

### 1. **MinIO (Object Storage)**

| Variable | Purpose | Used By | Access |
|----------|---------|---------|--------|
| `MINIO_ROOT_USER` | Admin username | MinIO Console, Backend | Console login |
| `MINIO_ROOT_PASSWORD` | Admin password | MinIO Console, Backend | Console login |

**Login URL:** https://minio-console.gea.abhirup.app
**Used for:** Accessing object storage console, managing buckets and files

---

### 2. **MySQL/MariaDB (Drupal CMS Database)**

| Variable | Purpose | Used By | Access |
|----------|---------|---------|--------|
| `MYSQL_ROOT_PASSWORD` | Database root password | MariaDB container | Database admin |
| `MYSQL_DATABASE` | Database name | Drupal | Default: `drupal` |
| `MYSQL_USER` | Database username | Drupal | Default: `drupal` |
| `MYSQL_PASSWORD` | Database user password | Drupal | Database access |

**Used for:** Drupal CMS data storage
**Direct access:** Via phpMyAdmin or mysql CLI (not exposed by default)

---

### 3. **PostgreSQL (Backend/Login System)**

| Variable | Purpose | Used By | Access |
|----------|---------|---------|--------|
| `POSTGRES_USER` | Database username | Backend, pgAdmin | Default: `postgres` |
| `POSTGRES_PASSWORD` | Database password | Backend, pgAdmin | Database access |
| `POSTGRES_DB` | Database name | Backend | Default: `postgres` |
| `DB_PASSWORD` | Alternative DB password | Backend login system | Same as POSTGRES_PASSWORD |

**Login URL (pgAdmin):** https://db.gea.abhirup.app
**Used for:** User authentication, service requests, backend data

---

### 4. **Traefik Dashboard**

| Variable | Purpose | Used By | Access |
|----------|---------|---------|--------|
| `TRAEFIK_DASHBOARD_USER` | Dashboard username | Traefik | Default: `admin` |
| `TRAEFIK_DASHBOARD_PASSWORD` | Dashboard password (htpasswd hash) | Traefik | Dashboard login |

**Login URL:** https://traefik.gea.abhirup.app
**Used for:** Monitoring reverse proxy, SSL certificates, routing

**Important:** The password in `.env` is a **hash**, not plain text. The script outputs both the plain password and hash.

---

### 5. **Backend JWT Authentication**

| Variable | Purpose | Used By | Access |
|----------|---------|---------|--------|
| `SECRET_KEY` | JWT signing key | Backend API | Internal only |
| `ALGORITHM` | JWT algorithm | Backend API | Default: `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Token lifetime | Backend API | Default: `30` |

**Used for:** Securing API authentication tokens
**Note:** SECRET_KEY should never be shared or exposed

---

### 6. **Wiki.js Database**

| Variable | Purpose | Used By | Access |
|----------|---------|---------|--------|
| `WIKI_DB_USER` | Database username | Wiki.js | Default: `wikijs` |
| `WIKI_DB_PASSWORD` | Database password | Wiki.js | Database access |
| `WIKI_DB_NAME` | Database name | Wiki.js | Default: `wiki` |

**Login URL (Wiki.js):** https://wiki.gea.abhirup.app
**Used for:** Wiki.js content storage
**Admin Account:** Created during first-time setup wizard

---

### 7. **Paperless-ngx Stack**

| Variable | Purpose | Used By | Access |
|----------|---------|---------|--------|
| `PAPERLESS_DBUSER` | Database username | Paperless | Default: `paperless` |
| `PAPERLESS_DBPASS` | Database password | Paperless | Database access |
| `PAPERLESS_DBNAME` | Database name | Paperless | Default: `paperless` |
| `PAPERLESS_ADMIN_USER` | Web admin username | Paperless | Default: `admin` |
| `PAPERLESS_ADMIN_PASSWORD` | Web admin password | Paperless | Web login |
| `PAPERLESS_SECRET_KEY` | Django secret key | Paperless | Internal security |

**Login URL:** https://dms.gea.abhirup.app
**Used for:** Document management system
**Change password:** Immediately after first login!

---

## 🎯 Password Usage Matrix

### What Passwords Do You Actually Need to Remember?

| Service | Login Required? | Credentials to Remember |
|---------|----------------|------------------------|
| **Frontend (gea.abhirup.app)** | Yes (user accounts) | Your user account |
| **MinIO Console** | Yes | MINIO_ROOT_USER + PASSWORD |
| **Traefik Dashboard** | Yes | TRAEFIK_USER + plain password |
| **Paperless** | Yes | PAPERLESS_ADMIN_USER + PASSWORD |
| **Wiki.js** | Yes | Account from setup wizard |
| **pgAdmin** | Yes | Email + POSTGRES_PASSWORD |
| **Drupal** | Admin only | Configured separately |

**Database passwords** are only needed for:
- Server maintenance
- Database backups
- Direct database access

---

## 🔒 Security Best Practices

### Passwords You Should Change Regularly
1. ✅ **Paperless Admin Password** - Change after first login
2. ✅ **Wiki.js Admin Password** - Set strong password during setup
3. ✅ **Frontend User Passwords** - Users should change periodically
4. ⚠️ **Traefik Dashboard Password** - Change every 90 days

### Passwords You Should NOT Change (without planning)
1. ❌ **Database Passwords** - Requires redeployment
2. ❌ **SECRET_KEY** - Invalidates all JWT tokens
3. ❌ **PAPERLESS_SECRET_KEY** - Breaks existing sessions

---

## 📝 Where Each Password is Used

### In Configuration Files
```
.env.dev
├─ All passwords stored here
├─ Used by docker-compose.yml
└─ Never committed to git

docker-compose.yml
├─ References .env variables
├─ Passes to containers as environment variables
└─ Does not store actual passwords

backend/.env (generated from root .env)
├─ POSTGRES_USER, POSTGRES_PASSWORD
├─ SECRET_KEY, ALGORITHM
└─ MINIO credentials
```

### In Running Containers
```
MinIO Container
└─ Uses: MINIO_ROOT_USER, MINIO_ROOT_PASSWORD

MariaDB Container
└─ Uses: MYSQL_ROOT_PASSWORD, MYSQL_USER, MYSQL_PASSWORD

PostgreSQL Containers (3 instances)
├─ Backend DB: POSTGRES_USER, POSTGRES_PASSWORD
├─ Wiki DB: WIKI_DB_USER, WIKI_DB_PASSWORD
└─ Paperless DB: PAPERLESS_DBUSER, PAPERLESS_DBPASS

Paperless Container
└─ Uses: All PAPERLESS_* variables

Wiki Container
└─ Uses: All WIKI_* variables

Backend Container
└─ Uses: SECRET_KEY, DB credentials, MINIO credentials
```

---

## 🚨 Password Recovery Scenarios

### Lost Traefik Dashboard Password
```bash
# Regenerate password
./generate-passwords.sh
# Copy new TRAEFIK_DASHBOARD_PASSWORD to .env
# Restart Traefik
docker-compose restart traefik
```

### Lost Paperless Admin Password
```bash
# Access container
docker exec -it paperless python3 manage.py changepassword admin
# Follow prompts to set new password
```

### Lost Wiki.js Admin Password
```bash
# Reset via database or use password reset email
# Or create new admin via CLI
docker exec -it wiki node wiki reset-admin
```

### Lost Database Password
```bash
# Must redeploy with new password
# Update .env with new password
./scripts/deploy.sh
# This will recreate database container
```

---

## 📊 Password Complexity Requirements

### Generated by Script (Secure by Default)
- **Length:** 24-50 characters
- **Character set:** Base64 (alphanumeric + some symbols)
- **Entropy:** ~144-300 bits
- **Method:** OpenSSL cryptographic random

### You Should Set (During Setup)
- **Wiki.js Admin:** Minimum 12 characters, mixed case, numbers, symbols
- **Paperless (after first login):** Minimum 12 characters, mixed case, numbers, symbols

---

## 🎯 Quick Reference: First Login Credentials

After deployment, you'll need these for first-time logins:

```bash
# 1. MinIO Console
URL: https://minio-console.gea.abhirup.app
User: minioadmin (or value from MINIO_ROOT_USER)
Pass: <from MINIO_ROOT_PASSWORD>

# 2. Traefik Dashboard
URL: https://traefik.gea.abhirup.app
User: admin (or value from TRAEFIK_DASHBOARD_USER)
Pass: <plain password from script output, not the hash>

# 3. Paperless
URL: https://dms.gea.abhirup.app
User: admin (or value from PAPERLESS_ADMIN_USER)
Pass: <from PAPERLESS_ADMIN_PASSWORD>
Action: CHANGE PASSWORD IMMEDIATELY!

# 4. Wiki.js
URL: https://wiki.gea.abhirup.app
Action: Complete setup wizard, create admin account

# 5. pgAdmin
URL: https://db.gea.abhirup.app
Email: <your CONTACT_EMAIL from .env>
Pass: <from POSTGRES_PASSWORD>
```

---

## 💾 Backup Recommendations

### What to Backup
1. ✅ `.env` file (encrypted backup only!)
2. ✅ Password manager export
3. ✅ Script output (stored securely)
4. ✅ Database dumps (contain no passwords)

### Where to Store
- ✅ Password manager (KeePass, 1Password, Bitwarden)
- ✅ Encrypted USB drive
- ✅ Secure cloud storage (encrypted)
- ❌ Plain text files
- ❌ Email
- ❌ Chat messages
- ❌ Git repository

---

## 🔄 Password Rotation Schedule

| Credential | Rotation Frequency | Priority |
|-----------|-------------------|----------|
| Paperless Admin | After first login + Every 90 days | HIGH |
| Wiki.js Admin | Every 90 days | HIGH |
| Traefik Dashboard | Every 90 days | MEDIUM |
| MinIO Root | Every 180 days | MEDIUM |
| Database Passwords | Every 365 days or on compromise | LOW |
| JWT SECRET_KEY | On compromise only | CRITICAL |

---

## 📞 Support

If you lose passwords and cannot recover:
1. Check password manager
2. Check secure backup location
3. Regenerate with `./generate-passwords.sh`
4. Redeploy affected services

**Remember:** Changing database passwords requires service redeployment!

---

## ✅ Security Checklist

- [ ] All passwords generated using script
- [ ] All passwords stored in password manager
- [ ] `.env` file not committed to git
- [ ] Secure backup of credentials created
- [ ] Paperless admin password changed after first login
- [ ] Wiki.js admin account created with strong password
- [ ] Test login to all services successful
- [ ] Old passwords removed from terminal history
- [ ] Team members have only passwords they need
- [ ] Password rotation schedule documented
