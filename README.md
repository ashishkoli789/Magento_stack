# Magento 2 Production-Style Docker Stack

## Project Overview

This project provides a production-style Magento 2.4 Dockerized deployment stack designed for AWS EC2 environments.

The stack includes:

* Magento 2
* PHP-FPM 8.3
* NGINX reverse proxy
* Varnish full-page cache
* Redis cache/session storage
* MySQL 8
* OpenSearch
* phpMyAdmin
* Dedicated cron container

The environment is designed to simulate a real-world production deployment with:

* HTTPS support
* reverse proxy caching
* container isolation
* non-root application execution
* persistent storage volumes
* Redis-backed caching and sessions
* automated provisioning

The repository is reproducible on a fresh EC2 instance using Docker Compose.

---

# Architecture Diagram

```text
Internet
    ↓
NGINX (TLS termination)
    ↓
Varnish
    ↓
nginx-app
    ↓
PHP-FPM
    ↓
Magento 2
    ↓
--------------------------------
↓              ↓              ↓
Redis        MySQL       OpenSearch
(cache)      (DB)        (search)
```

---

# Services

## nginx

Acts as the public reverse proxy and TLS termination layer.

Responsibilities:

* HTTPS termination
* HTTP → HTTPS redirects
* phpMyAdmin routing
* basic authentication for phpMyAdmin
* forwarding requests to Varnish

Exposed ports:

* 80
* 443

---

## varnish

Provides Magento full-page caching.

Responsibilities:

* cacheable category/product pages
* response acceleration
* reduced PHP load

Configured using Magento-generated VCL with custom backend adjustments.

---

## nginx-app

Internal application web server used behind Varnish.

Responsibilities:

* serving Magento static/media files
* forwarding PHP requests to PHP-FPM

Not publicly exposed.

---

## php

Custom PHP-FPM 8.3 container for Magento.

Responsibilities:

* Magento application runtime
* Composer execution
* CLI operations
* PHP extensions

Runs application processes as:

```text
User: test-ssh
Group: clp
```

---

## cron

Dedicated Magento cron container.

Responsibilities:

* scheduled Magento jobs
* indexers
* email queues
* cleanup tasks

Runs Magento cron every minute.

---

## redis

Used for:

* Magento cache
* Magento sessions

Database usage:

* DB0 → Magento cache
* DB2 → Magento sessions

---

## mysql

MySQL 8.0 database backend for Magento.

Persistent volume storage enabled.

---

## opensearch

OpenSearch 2.x backend used for:

* catalog search
* layered navigation
* product indexing

Configured as a single-node deployment.

---

## phpmyadmin

Database administration interface.

Accessible only through:

* HTTPS
* HTTP Basic Authentication

---

# Setup Instructions

## Clone Repository

```bash
git clone <repository-url>
cd magento-stack
```

---

## Start Environment

```bash
docker compose up -d --build
```

---

## Verify Running Containers

```bash
docker ps
```

---

## Access URLs

| Service       | URL                                      |
| ------------- | ---------------------------------------- |
| Storefront    | https://test.dyna.com                    |
| Magento Admin | https://test.dyna.com/secureAdmin |
| phpMyAdmin    | https://test.dyna.com/phpmyadmin         |

---

# Acceptance Test Demonstrations

## 1. Verify Varnish HIT

Run twice:

```bash
curl -k -I https://test.dyna.com/women/tops-women.html
```

Expected header:

```text
X-Magento-Cache-Debug: HIT
```

---

## 2. Verify Redis Keys

Open Redis CLI:

```bash
docker exec -it redis redis-cli
```

Check Magento cache:

```bash
SELECT 0
DBSIZE
KEYS *
```

Check Magento sessions:

```bash
SELECT 2
DBSIZE
KEYS *
```

---

## 3. Verify Magento Cron

Check cron container:

```bash
docker ps | grep cron
```

Verify cron jobs:

```bash
docker exec -it mysql mysql -u root -p
```

Inside MySQL:

```sql
USE magento;

SELECT job_code, status, scheduled_at
FROM cron_schedule
ORDER BY schedule_id DESC
LIMIT 10;
```

---

## 4. Verify Non-Root User

Open PHP container:

```bash
docker exec -it php bash
```

Check user:

```bash
whoami
id
```

Expected:

```text
test-ssh
group clp
```

---

## 5. Verify Persistence

Stop environment:

```bash
docker compose down
```

Restart:

```bash
docker compose up -d
```

Verify:

* Magento database preserved
* media files preserved
* sessions preserved (re-login may be required)

---

# Security Decisions

## HTTPS Enforcement

All traffic redirected to HTTPS.

TLS termination handled by NGINX.

---

## Non-Root Containers

Magento application processes run as:

```text
test-ssh:clp
```

instead of root.

---

## phpMyAdmin Protection

phpMyAdmin secured using:

* HTTPS
* HTTP Basic Authentication

Authentication required before reaching login screen.

---

## Custom Magento Admin URL

Magento admin is configured using a non-default admin URI.

Default `/admin` endpoint is not used.

---

# Provisioning

Provisioning script included:

```text
scripts/bootstrap.sh
```

Responsibilities:

* Docker installation
* Docker Compose installation
* firewall setup
* swap creation
* user/group provisioning

---

# Design Decisions

## Dedicated nginx-app Container

Application web server separated from public NGINX for:

* cleaner architecture
* Varnish integration
* production-style layering

---

## Varnish Frontend Caching

Full-page cache handled by Varnish instead of Redis for:

* improved performance
* real-world production similarity

---

## Dedicated Cron Container

Cron isolated from PHP-FPM runtime to:

* avoid process contention
* improve operational clarity

---

# Known Limitations

* Self-signed TLS certificates used for demo purposes
* Single-node deployment only
* No auto-scaling
* No CI/CD pipeline included
* Resource limits optimized for demo-scale EC2 instance
* Secrets stored locally for demonstration purposes

---
