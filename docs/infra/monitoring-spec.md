# Monitoring Specification — Fundara Production

**Audience:** DevOps engineer, system administrator  
**Platform:** Ubuntu Server 24.04.4 LTS, ERPNext v16 / Frappe Framework, custom app `fundara`  
**Last updated:** 2026-06-19

---

## Overview

Monitoring for Fundara serves three purposes:

1. **Operational awareness** — catch resource exhaustion, application failures, and performance degradation before users are affected
2. **Business accountability** — surface Fundara-specific conditions (overdue advances, grant reporting deadlines, low fund balances) as proactive digests
3. **Security** — detect anomalous login behavior and unauthorized access attempts

This specification covers what to monitor, at what thresholds, with which tools, and how to alert.

---

## 1. Monitoring Stack Recommendation

### 1.1 Primary Option: Netdata (Recommended for NGO MVP)

**Why:** Zero-configuration system monitoring, minimal resource overhead (~1% CPU, ~100 MB RAM), beautiful real-time dashboard out of the box, free and open-source. Sufficient for single-server and small multi-server Fundara deployments.

| Aspect | Details |
|---|---|
| Installation | Single command, auto-detects services |
| Overhead | ~1% CPU, ~80–150 MB RAM |
| Retention | Default 1 hour real-time; configurable long-term via dbengine |
| Alerting | Built-in alert system with email, Slack, Telegram, webhook |
| MariaDB | Auto-monitored via mysql plugin |
| Nginx | Auto-monitored via nginx stub_status |
| Redis | Auto-monitored via redis plugin |
| Cost | Free and open-source |

**Limitation:** No long-term trend storage by default. For > 1 week trends, enable Netdata's DBENGINE or ship metrics to a Prometheus-compatible endpoint.

### 1.2 Secondary Option: Prometheus + Grafana

**Why:** Industry-standard, highly configurable, excellent long-term retention, rich ecosystem of exporters. More appropriate for Profile C/D deployments (Medium NGO, SaaS).

Required exporters:
- `node_exporter` — system metrics
- `mysqld_exporter` — MariaDB metrics
- `redis_exporter` — Redis metrics
- `nginx-prometheus-exporter` or nginx stub_status scraping

**Overhead:** ~200–400 MB RAM additional. Worth it at scale; overkill for a single-server pilot.

### 1.3 Uptime Monitoring

| Option | Type | Cost | Notes |
|---|---|---|---|
| Uptime Kuma | Self-hosted | Free | Recommended. Simple, supports HTTP, TCP, DNS, keyword checks, Telegram/email alerts |
| Better Uptime | SaaS | Free tier available | 10 monitors free; no credit card required |
| UptimeRobot | SaaS | Free tier (5 min interval) | Good backup option |

**Recommendation:** Deploy Uptime Kuma on a separate small VPS or monitoring server. Do not run it on the same server you are monitoring — if the production server goes down, your monitoring goes down with it.

### 1.4 Log Aggregation

For MVP single-server deployments: **structured log files are sufficient**. Use `logrotate` to manage retention. Monitor log files via Netdata's `go.d.plugin` log parsing or simple `fail2ban` rules.

For medium deployments where logs from multiple servers need to be centralized: **Loki + Promtail** (part of the Grafana stack, free, lightweight). Loki is far more resource-efficient than Elasticsearch for this use case.

---

## 2. Metrics to Monitor

### 2.1 System Metrics

| Metric | Tool | Warning | Critical |
|---|---|---|---|
| CPU usage | Netdata / node_exporter | > 80% for 5 min | > 95% for 2 min |
| RAM usage | Netdata / node_exporter | > 85% | > 95% |
| Swap usage | Netdata | > 20% | > 60% |
| Disk usage (root) | Netdata | > 80% | > 90% |
| Disk usage (data) | Netdata | > 75% | > 88% |
| Disk read IOPS | Netdata | Baseline + 200% | Baseline + 400% |
| Disk write IOPS | Netdata | Baseline + 200% | Baseline + 400% |
| Network in (Mbps) | Netdata | 80% of provisioned | 95% |
| Network out (Mbps) | Netdata | 80% of provisioned | 95% |
| Disk I/O await | Netdata | > 50ms | > 200ms |
| Load average (1m) | Netdata | > vCPU count | > 2x vCPU count |

**Disk space is the most common cause of Frappe/ERPNext outages.** Alert early at 75% on the partition holding `/home/frappe/frappe-bench/`.

### 2.2 Application Metrics (Frappe/ERPNext Specific)

| Metric | Source | Warning | Critical | Notes |
|---|---|---|---|---|
| Web worker response time | Nginx logs / Netdata | > 2s avg | > 5s avg | Measure p95, not just average |
| Background job queue depth | Redis `llen` | > 30 pending | > 100 pending | Per queue: short, long, default |
| Failed background jobs | Frappe error log | > 0 | > 5 | Any failed job in 15 min window |
| Scheduler last run | Frappe API | > 10 min ago | > 30 min ago | Scheduler silently stops sometimes |
| Redis memory usage | Redis INFO | > 70% maxmemory | > 90% | Also alert on evictions > 0 |
| Redis connected clients | Redis INFO | > 80 | > 150 | Default maxclients = 128 |
| MariaDB slow queries | Slow query log | > 5/min | > 20/min | Threshold: queries > 2 seconds |
| MariaDB connections | SHOW STATUS | > 75% of max_connections | > 90% | Default max_connections = 151 |
| MariaDB replication lag | SHOW SLAVE STATUS | > 10s | > 60s | Only if using replication |
| Nginx 5xx error rate | Nginx access log | > 1% of requests | > 5% | In any 5-min window |
| Nginx 4xx error rate | Nginx access log | > 10% of requests | > 20% | May indicate app errors |
| SSL certificate expiry | Certbot / external check | < 30 days | < 7 days | Let's Encrypt renews at 30 days |
| Supervisor process down | Supervisor status | Any process in STOPPED | Any process in FATAL | Immediate page |
| Disk space for backups | Filesystem | > 70% | > 85% | Backup disk separate from app |

### 2.3 Business Metrics (Fundara Specific)

These are not infrastructure alerts — they are daily digest items delivered via email or Telegram to the operations team.

| Metric | Query Source | Alert Type | Frequency |
|---|---|---|---|
| Failed login attempts (same IP) | Frappe `__Auth` table / Nginx log | Alert: > 10 in 5 min from same IP | Real-time |
| Overdue Cash Advance count | `tabAdvance` where `status='Pending Liquidation'` and `due_date < NOW()` | Info digest | Daily 08:00 |
| Overdue Grant Reporting Schedule | `tabReport Submission` where `due_date < NOW()` and `status != 'Submitted'` | Info digest | Daily 08:00 |
| Fund balance below 10% threshold | `tabFund Balance Snapshot` where `balance_pct < 10` | Info digest | Daily 08:00 |
| Background jobs failed in last 24h | Frappe error log | Warning digest | Daily 06:00 |
| Backup status (last 24h) | `/var/log/fundara-backup.log` | Alert: FAILED | After each backup run |

**Implementation:** A Frappe scheduled job (`daily`) can query these and push to a Telegram bot or email. See Section 8 (Health Check Endpoints) for the API structure.

---

## 3. Alert Thresholds Table

| Metric | Warning | Critical | Immediate Action |
|---|---|---|---|
| CPU usage | > 80% / 5 min | > 95% / 2 min | Check slow queries, background jobs |
| RAM usage | > 85% | > 95% | Restart workers, check for leak |
| Disk usage | > 80% | > 90% | Purge old backups, expand volume |
| Swap usage | > 20% | > 60% | Investigate RAM pressure |
| Load average | > vCPU count | > 2x vCPU | Identify CPU-intensive process |
| Disk I/O await | > 50ms | > 200ms | Check slow queries, disk health |
| Web response p95 | > 2s | > 5s | Check worker count, slow queries |
| Queue depth (any) | > 30 | > 100 | Scale workers, investigate stuck jobs |
| Failed jobs | > 0 (15 min) | > 5 | Check Frappe error log |
| Scheduler last run | > 10 min | > 30 min | Restart scheduler |
| Redis memory | > 70% | > 90% | Increase maxmemory or flush keys |
| MariaDB slow queries | > 5/min | > 20/min | Analyze slow query log |
| MariaDB connections | > 75% of max | > 90% of max | Increase max_connections or scale |
| Nginx 5xx rate | > 1% | > 5% | Check application errors |
| SSL expiry | < 30 days | < 7 days | Run certbot renew |
| Supervisor process | STOPPED | FATAL | Restart process, check logs |
| Backup failure | — | Any failure | Investigate immediately |
| Login brute force | > 10/5 min | > 50/5 min | Block IP via fail2ban |

---

## 4. Alert Channels

### 4.1 Email (Minimum Requirement)

Configure in Netdata (`/etc/netdata/health_alarm_notify.conf`):

```ini
SEND_EMAIL="YES"
DEFAULT_RECIPIENT_EMAIL="ops@yourorg.org"
EMAIL_SENDER="netdata@yourserver.hostname"
```

For Frappe-level alerts, configure SMTP in `site_config.json`:
```json
{
  "mail_server": "smtp.yourprovider.com",
  "mail_port": 587,
  "use_tls": 1,
  "mail_login": "alerts@yourorg.org",
  "mail_password": "...",
  "auto_email_id": "alerts@yourorg.org"
}
```

### 4.2 Telegram Bot (Recommended for NGO Ops Teams)

Telegram is widely used in Indonesian NGO operations. A Telegram bot alert is faster and more reliable than email for on-call notification.

Setup:
1. Create a bot via `@BotFather` — get the bot token
2. Add the bot to your ops group — get the chat ID
3. Configure in Netdata:

```ini
# /etc/netdata/health_alarm_notify.conf
SEND_TELEGRAM="YES"
TELEGRAM_BOT_TOKEN="1234567890:AAxxxxxxxxxxxx"
DEFAULT_RECIPIENT_TELEGRAM="-100xxxxxxxxxx"  # group chat ID (negative for groups)
```

For Fundara business metric digests, implement a Frappe scheduled job that calls:
```
https://api.telegram.org/bot{TOKEN}/sendMessage?chat_id={CHAT_ID}&text={MESSAGE}
```

### 4.3 Webhook (Slack, custom)

Netdata and Uptime Kuma both support generic webhooks. Point to your Slack incoming webhook or any HTTP endpoint.

```ini
# Netdata
SEND_SLACK="YES"
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T.../B.../..."
DEFAULT_RECIPIENT_SLACK="#ops-alerts"
```

---

## 5. Dashboard Specifications

### 5.1 Ops Dashboard (Netdata default + customization)

The Netdata built-in dashboard at `http://server-ip:19999` provides most of this out of the box. Pin these sections:

**Server Health Overview panel:**
- CPU usage gauge (last 1 hour)
- RAM usage gauge
- Disk usage bar (all mounted filesystems)
- Load average sparkline (1m, 5m, 15m)
- Network in/out sparkline

**Application Uptime panel (Uptime Kuma):**
- HTTP status for each site's URL
- Response time trend (24h)
- Downtime events (last 7 days)
- SSL expiry countdown

**Response Time Trend:**
- Nginx request processing time — p50, p95, p99 (24h chart)
- Requests per second (7-day trend)

**Disk Usage Trend:**
- Disk fill rate projection (days until full)
- Backup directory size trend

**Database Health panel:**
- MariaDB queries/second
- Slow query rate (last 1h)
- Active connections
- InnoDB buffer pool hit rate (should be > 95%)

**Background Job Status panel:**
- Redis queue depths (short, long, default)
- Failed jobs count (last 24h)
- Scheduler last heartbeat

### 5.2 Uptime Kuma Dashboard

Create monitors for:
- `https://<site-name>/` — HTTP 200 check (all active sites)
- `https://<site-name>/api/method/ping` — Frappe API alive check
- `https://<site-name>/api/method/fundara.health` — Custom health endpoint
- TCP port 3306 (internal, from monitoring server to DB server if separated)
- TCP port 6379 (Redis, internal check)

Group monitors by site in Uptime Kuma's status page.

---

## 6. Log Files to Monitor

| Log File | Path | Watch For |
|---|---|---|
| Frappe error log | `/home/frappe/frappe-bench/logs/error.log` | Python tracebacks, unhandled exceptions, DocType errors |
| Frappe worker log | `/home/frappe/frappe-bench/logs/worker.log` | Failed background jobs, job timeouts |
| Frappe scheduler log | `/home/frappe/frappe-bench/logs/schedule.log` | Missed scheduled jobs, scheduler crashes |
| Web worker log | `/home/frappe/frappe-bench/logs/web.error.log` | Gunicorn worker errors |
| Nginx access log | `/var/log/nginx/access.log` | 5xx errors, unusual traffic patterns, large response times |
| Nginx error log | `/var/log/nginx/error.log` | Upstream failures, SSL errors, bad gateway |
| MariaDB slow query log | `/var/log/mysql/mariadb-slow.log` | Queries exceeding `long_query_time` (set to 2s) |
| MariaDB error log | `/var/log/mysql/error.log` | InnoDB crashes, corruption warnings, failed connections |
| Supervisor log | `/var/log/supervisor/supervisord.log` | Process crashes, FATAL state |
| Auth log | `/var/log/auth.log` | SSH brute force, sudo usage |
| fail2ban log | `/var/log/fail2ban.log` | Banned IPs (if fail2ban is installed) |
| Backup log | `/var/log/fundara-backup.log` | Failed backup runs |

### 6.1 Enable MariaDB Slow Query Log

In `/etc/mysql/conf.d/mariadb.cnf`:

```ini
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/mariadb-slow.log
long_query_time = 2
log_queries_not_using_indexes = 1
```

Restart MariaDB: `sudo systemctl restart mariadb`

### 6.2 Log Rotation

Ensure `/etc/logrotate.d/` has entries for:
- `/home/frappe/frappe-bench/logs/*.log` (Frappe logs — rotate daily, keep 14 days)
- `/var/log/fundara-backup.log` (rotate weekly, keep 4 copies)

Frappe bench sets up its own logrotate config via `bench setup logrotate` — run this after installation.

---

## 7. Health Check Endpoints

### 7.1 Built-in Frappe Endpoints

| Endpoint | Method | Expected Response | Use |
|---|---|---|---|
| `/api/method/ping` | GET | `{"message": "pong"}` | Basic app alive check |
| `/api/method/frappe.utils.change_log.get_change_log` | GET | JSON with app versions | App alive + version check |
| `/` | GET | HTTP 200 | Nginx + web worker alive |

### 7.2 Custom Fundara Health Endpoint

Implement at `fundara/api.py`:

**Route:** `GET /api/method/fundara.api.health`  
**Authentication:** No authentication required (public endpoint)  
**Rate limit:** 60 requests/minute per IP (Frappe rate limiting)

**Response format:**

```json
{
  "status": "ok",
  "timestamp": "2026-06-19T10:00:00Z",
  "version": {
    "fundara": "1.0.0",
    "frappe": "16.x.x",
    "erpnext": "16.x.x"
  },
  "database": {
    "status": "ok",
    "response_time_ms": 5
  },
  "cache": {
    "status": "ok",
    "redis_memory_used_mb": 45
  },
  "scheduler": {
    "status": "ok",
    "last_heartbeat": "2026-06-19T09:58:00Z",
    "minutes_since_last_run": 2
  },
  "queue": {
    "default": 0,
    "short": 1,
    "long": 0
  },
  "backup": {
    "last_run": "2026-06-19T02:01:30Z",
    "last_status": "ok"
  }
}
```

**Status values:** `"ok"`, `"degraded"`, `"critical"`

If any component returns `"critical"`, the HTTP response code should be `503 Service Unavailable`. Uptime Kuma and other monitors can treat non-200 as down.

**Implementation sketch (`fundara/api.py`):**

```python
import frappe
import redis
from datetime import datetime

@frappe.whitelist(allow_guest=True)
def health():
    result = {
        "status": "ok",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "version": get_versions(),
        "database": check_database(),
        "cache": check_redis(),
        "scheduler": check_scheduler(),
        "queue": check_queue(),
        "backup": check_backup_status(),
    }
    
    # Aggregate status
    component_statuses = [
        result["database"]["status"],
        result["cache"]["status"],
        result["scheduler"]["status"],
    ]
    if "critical" in component_statuses:
        result["status"] = "critical"
        frappe.local.response["http_status_code"] = 503
    elif "degraded" in component_statuses:
        result["status"] = "degraded"
    
    return result
```

---

## 8. Alert Thresholds for Business Metrics (Frappe Scheduled Jobs)

Implement these as Frappe scheduled jobs in `fundara/tasks.py`, wired via `hooks.py`:

```python
# hooks.py
scheduler_events = {
    "daily": [
        "fundara.tasks.send_operations_digest",
    ],
    "all": [
        "fundara.tasks.check_scheduler_health",
    ],
}
```

**Daily digest job (`fundara/tasks.py`):**

```python
def send_operations_digest():
    issues = []
    
    # Overdue advances
    overdue_advances = frappe.db.count("Advance", {
        "status": "Pending Liquidation",
        "due_date": ["<", frappe.utils.today()]
    })
    if overdue_advances > 0:
        issues.append(f"Overdue Advances: {overdue_advances}")
    
    # Overdue grant reports
    overdue_reports = frappe.db.count("Report Submission", {
        "status": ["not in", ["Submitted", "Cancelled"]],
        "due_date": ["<", frappe.utils.today()]
    })
    if overdue_reports > 0:
        issues.append(f"Overdue Grant Reports: {overdue_reports}")
    
    # Low fund balances (< 10% of allocation)
    # Query Fund Balance Snapshot for funds below threshold
    
    if issues:
        message = "Fundara Daily Digest:\n" + "\n".join(f"- {i}" for i in issues)
        # Send to Telegram / email
        send_telegram(message)
```

---

## 9. Monitoring Setup Script

The complete setup script is at:

**`/home/bagong/Fundara/docs/infra/setup-monitoring.sh`**

See that file for the full implementation. Summary of what it does:

1. Installs Netdata via the official kickstart script
2. Configures Netdata alert channels (email, Telegram)
3. Creates custom Netdata health alert rules for Frappe/Fundara-specific metrics
4. Installs Docker (if not present) and deploys Uptime Kuma via Docker Compose
5. Configures Nginx to proxy Uptime Kuma at `http://localhost:3001` (or a subdomain)
6. Enables the MariaDB slow query log
7. Sets up logrotate for Frappe logs

---

## Appendix A: Netdata Custom Alert Rules for Fundara

Place in `/etc/netdata/health.d/fundara.conf`:

```yaml
# Disk space — alert early (Frappe crashes when disk fills)
alarm: disk_space_fundara
on: disk.space
lookup: average -10m unaligned of used
units: %
every: 1m
warn: $this > 75
crit: $this > 88
info: Disk usage on Fundara server
delay: up 5m down 10m multiplier 1.5 max 1h

# MariaDB connection saturation
alarm: mariadb_connections
on: mysql.connections_active
lookup: average -5m unaligned of active
units: connections
every: 1m
warn: $this > ($mysql_max_connections * 0.75)
crit: $this > ($mysql_max_connections * 0.90)
info: MariaDB connections approaching limit

# Redis memory
alarm: redis_memory
on: redis.mem
lookup: average -5m unaligned of used
units: MB
every: 1m
warn: $this > ($redis_maxmemory * 0.70)
crit: $this > ($redis_maxmemory * 0.90)
info: Redis memory usage
```

---

## Appendix B: Quick Reference — Monitoring Commands

```bash
# Check Supervisor process status
sudo supervisorctl status

# Check Frappe worker queue depth
redis-cli -n 0 llen rq:queue:short
redis-cli -n 0 llen rq:queue:long
redis-cli -n 0 llen rq:queue:default

# Check scheduler last run
bench --site <site> scheduler status

# Check MariaDB connections
mysql -u root -p -e "SHOW STATUS LIKE 'Threads_connected';"

# Check Nginx status (if stub_status enabled)
curl http://localhost/nginx_status

# View recent Frappe errors
tail -50 /home/frappe/frappe-bench/logs/error.log

# Check SSL certificate expiry
echo | openssl s_client -connect <site>:443 2>/dev/null | openssl x509 -noout -dates

# View Netdata alerts
curl -s http://localhost:19999/api/v1/alarms?active=true | python3 -m json.tool
```
