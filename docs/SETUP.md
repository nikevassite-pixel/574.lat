# n8n Automation Workflows - Setup Guide

Complete setup guide for all workflows in this collection.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Database Configuration](#database-configuration)
4. [API Credentials Setup](#api-credentials-setup)
5. [Workflow-Specific Setup](#workflow-specific-setup)
6. [Testing & Verification](#testing--verification)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

- **n8n** (v1.0.0 or higher)
  ```bash
  npm install -g n8n
  # or using Docker
  docker pull n8nio/n8n
  ```

- **PostgreSQL** (v13 or higher)
  ```bash
  # Ubuntu/Debian
  sudo apt-get install postgresql postgresql-contrib

  # macOS
  brew install postgresql
  ```

- **Node.js** (v18 or higher)
  ```bash
  # Using nvm
  nvm install 18
  nvm use 18
  ```

### Optional Software

- **Redis** (for queue mode)
- **MQTT Broker** (Mosquitto for IoT workflows)
- **InfluxDB** (for time-series data)

---

## Initial Setup

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/574.lat.git
cd 574.lat
```

### 2. Environment Configuration

```bash
# Copy environment template
cp config/env.template .env

# Edit with your credentials
nano .env
```

### 3. Database Setup

```bash
# Create database
createdb n8n_workflows

# Run schema
psql -U postgres -d n8n_workflows -f scripts/database-schema.sql

# Verify tables
psql -U postgres -d n8n_workflows -c "\dt"
```

### 4. Start n8n

```bash
# Using npm
n8n start

# Using Docker
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n

# Using Docker Compose (create docker-compose.yml first)
docker-compose up -d
```

---

## Database Configuration

### PostgreSQL Connection

1. **Update .env file:**
   ```env
   DATABASE_HOST=localhost
   DATABASE_PORT=5432
   DATABASE_NAME=n8n_workflows
   DATABASE_USER=postgres
   DATABASE_PASSWORD=your_password
   ```

2. **Test connection:**
   ```bash
   psql -h localhost -U postgres -d n8n_workflows -c "SELECT version();"
   ```

3. **Create n8n user (optional but recommended):**
   ```sql
   CREATE USER n8n_user WITH PASSWORD 'secure_password';
   GRANT ALL PRIVILEGES ON DATABASE n8n_workflows TO n8n_user;
   GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO n8n_user;
   GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO n8n_user;
   ```

---

## API Credentials Setup

### 1. OpenAI (Required for AI workflows)

1. Visit https://platform.openai.com/api-keys
2. Create new API key
3. Add to `.env`:
   ```env
   OPENAI_API_KEY=sk-proj-xxxxx
   ```
4. In n8n:
   - Credentials → Add Credential → OpenAI
   - Paste API key
   - Test connection

### 2. Twitter/X API

1. Visit https://developer.twitter.com/
2. Create new App
3. Enable OAuth 2.0
4. Get Client ID and Secret
5. Add to `.env` and configure in n8n

### 3. Facebook/Instagram

1. Visit https://developers.facebook.com/
2. Create new App
3. Add Instagram Basic Display
4. Add Facebook Login
5. Get App ID and Secret
6. Configure OAuth in n8n

### 4. Google Services (Sheets, Gmail)

1. Visit https://console.cloud.google.com/
2. Create new project
3. Enable APIs:
   - Google Sheets API
   - Gmail API
4. Create OAuth 2.0 credentials
5. Configure in n8n with OAuth flow

### 5. Shopify

1. Shopify Admin → Apps → Develop apps
2. Create new app
3. Configure Admin API scopes:
   - read_products
   - write_products
   - read_inventory
   - write_inventory
4. Install app and get access token

### 6. Other Services

See `config/env.template` for complete list of API credentials needed.

---

## Workflow-Specific Setup

### Workflow 1: Social Media Analytics

**Prerequisites:**
- Twitter Developer Account
- Facebook Business Account
- Google Cloud Project

**Setup Steps:**

1. **Import workflow:**
   ```
   n8n → Workflows → Import from File
   Select: workflows/social-media/social-media-analytics-dashboard.json
   ```

2. **Configure credentials:**
   - Twitter OAuth2 API
   - Facebook Graph API
   - Google Sheets OAuth2 API

3. **Update workflow variables:**
   - Twitter search query
   - Facebook Page ID
   - Instagram Business Account ID
   - Google Spreadsheet ID

4. **Test execution:**
   - Click "Execute Workflow"
   - Verify data in Google Sheets

### Workflow 2: AI Content Generation

**Prerequisites:**
- OpenAI API key
- WordPress site with REST API
- Medium integration token

**Setup Steps:**

1. **Import workflow**

2. **Configure RSS feeds:**
   - Edit "Configuration" node
   - Add your RSS feed URLs

3. **Setup WordPress:**
   ```bash
   # Enable REST API
   # Create application password
   # Update .env with credentials
   ```

4. **Configure Medium:**
   - Get integration token from Medium settings
   - Add to workflow

5. **Database setup:**
   - Ensure `content_pipeline` table exists
   - Test database connection

### Workflow 3: E-commerce Inventory Sync

**Prerequisites:**
- Shopify store
- WooCommerce site
- Slack workspace

**Setup Steps:**

1. **Shopify configuration:**
   ```
   - Admin API access token
   - Note your store name
   - Enable inventory tracking
   ```

2. **WooCommerce setup:**
   ```bash
   # Install WooCommerce REST API
   # Generate API keys
   # Test endpoint: /wp-json/wc/v3/products
   ```

3. **Slack webhook:**
   - Create incoming webhook
   - Select channel (#inventory-alerts)
   - Copy webhook URL

4. **Configure thresholds:**
   - Low stock: < 10 units
   - Critical: 0 units
   - Edit in workflow if needed

### Workflow 4: Customer Support Routing

**Prerequisites:**
- Gmail account with API access
- Hugging Face API token
- Zendesk account

**Setup Steps:**

1. **Gmail API setup:**
   ```
   - Enable Gmail API in Google Cloud
   - Create OAuth credentials
   - Authorize in n8n
   - Configure label filters
   ```

2. **Hugging Face:**
   ```bash
   # Get API token from https://huggingface.co/settings/tokens
   # Add to n8n credentials
   ```

3. **Zendesk configuration:**
   ```
   - Get API token
   - Configure group IDs in workflow
   - Map categories to groups
   ```

4. **Test classification:**
   - Send test email
   - Check Zendesk ticket creation
   - Verify routing

### Workflow 5: Financial Data Aggregation

**Prerequisites:**
- Alpha Vantage API key
- SMTP email account
- Google Sheets access

**Setup Steps:**

1. **Alpha Vantage:**
   ```
   - Sign up at https://www.alphavantage.co/
   - Get free API key (500 requests/day)
   - Add to .env
   ```

2. **Configure stock symbols:**
   - Edit "Configure Symbols" node
   - Add your watchlist

3. **Email setup:**
   ```env
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASSWORD=app_password
   ```

4. **Test report generation:**
   - Execute workflow manually
   - Check email inbox
   - Verify Google Sheets data

### Workflow 6: IoT Device Monitoring

**Prerequisites:**
- MQTT broker (Mosquitto)
- InfluxDB instance
- PagerDuty account

**Setup Steps:**

1. **MQTT Broker:**
   ```bash
   # Install Mosquitto
   sudo apt-get install mosquitto mosquitto-clients

   # Configure
   sudo nano /etc/mosquitto/mosquitto.conf

   # Start service
   sudo systemctl start mosquitto
   ```

2. **InfluxDB:**
   ```bash
   # Install InfluxDB 2.x
   # Create organization and bucket
   # Generate API token
   ```

3. **Configure topic structure:**
   ```
   sensors/{category}/{location}/{device_id}/{metric}
   Example: sensors/temperature/warehouse/device001/temp
   ```

4. **Test with sample data:**
   ```bash
   mosquitto_pub -h localhost -t "sensors/temperature/test/dev001/data" \
     -m '{"temperature":25.5,"humidity":60,"battery":85}'
   ```

### Workflow 7: Project Management Sync

**Prerequisites:**
- Trello account
- Asana account
- Jira Cloud instance

**Setup Steps:**

1. **Trello:**
   ```
   - Get API key from https://trello.com/app-key
   - Generate token
   - Note Board ID and List IDs
   ```

2. **Asana:**
   ```
   - Generate Personal Access Token
   - Get Workspace ID
   - Get Project ID
   ```

3. **Jira:**
   ```
   - Create API token
   - Note project key
   - Configure issue types
   ```

4. **Sync state table:**
   ```sql
   -- Verify table exists
   SELECT * FROM task_sync_state LIMIT 1;
   ```

### Workflow 8: Chatbot Integration

**Prerequisites:**
- Telegram Bot Token
- Slack App
- OpenWeatherMap API key

**Setup Steps:**

1. **Create Telegram Bot:**
   ```
   - Message @BotFather on Telegram
   - Send /newbot
   - Follow instructions
   - Copy bot token
   ```

2. **Slack App:**
   ```
   - Visit https://api.slack.com/apps
   - Create new app
   - Add Bot Token Scopes:
     - chat:write
     - channels:history
     - im:history
   - Install to workspace
   - Copy Bot User OAuth Token
   ```

3. **Configure webhooks:**
   ```
   - Set Telegram webhook URL
   - Configure Slack Event Subscriptions
   - Add n8n webhook URLs
   ```

4. **Test bot:**
   ```
   - Send /start to Telegram bot
   - Message Slack bot
   - Try commands
   ```

---

## Testing & Verification

### 1. Test Database Connection

```bash
# Run test query
psql -U postgres -d n8n_workflows -c "SELECT COUNT(*) FROM workflow_config;"
```

### 2. Test API Credentials

In n8n:
- Go to Credentials
- Select credential
- Click "Test"
- Verify success message

### 3. Manual Workflow Execution

For each workflow:
1. Open in n8n
2. Click "Execute Workflow"
3. Check execution log
4. Verify output data
5. Check database for stored data

### 4. Automated Testing

```bash
# Test workflow endpoints
curl -X POST http://localhost:5678/webhook/test

# Check logs
tail -f ~/.n8n/logs/n8n.log
```

---

## Troubleshooting

### Common Issues

#### 1. Database Connection Failed

**Error:** "Connection terminated unexpectedly"

**Solution:**
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check connection
psql -h localhost -U postgres -c "SELECT version();"

# Verify credentials in .env
```

#### 2. API Authentication Errors

**Error:** "401 Unauthorized"

**Solution:**
- Verify API key is correct
- Check if key has expired
- Ensure proper permissions/scopes
- Test API key with curl

#### 3. Workflow Execution Timeout

**Error:** "Execution timed out"

**Solution:**
```javascript
// Increase timeout in workflow settings
// Or in .env
N8N_EXECUTION_TIMEOUT=600
```

#### 4. Rate Limit Errors

**Error:** "429 Too Many Requests"

**Solution:**
- Reduce polling frequency
- Implement exponential backoff
- Cache API responses
- Upgrade API plan

#### 5. MQTT Connection Issues

**Error:** "Connection refused"

**Solution:**
```bash
# Check Mosquitto
sudo systemctl status mosquitto

# Test connection
mosquitto_sub -h localhost -t "#" -v

# Check firewall
sudo ufw status
```

### Debug Mode

Enable detailed logging:

```env
# In .env
LOG_LEVEL=debug
DEBUG_MODE=true
```

View logs:
```bash
# n8n logs
tail -f ~/.n8n/logs/n8n.log

# Workflow execution logs
# Check in n8n UI → Executions
```

---

## Performance Optimization

### 1. Database Indexing

Already included in schema, but verify:
```sql
-- Check indexes
SELECT tablename, indexname FROM pg_indexes
WHERE schemaname = 'public';
```

### 2. Connection Pooling

Configure in .env:
```env
DATABASE_POOL_MIN=2
DATABASE_POOL_MAX=10
```

### 3. Caching

Implement Redis caching (optional):
```bash
# Install Redis
sudo apt-get install redis-server

# Configure in .env
QUEUE_MODE=redis
QUEUE_REDIS_HOST=localhost
```

### 4. Workflow Optimization

- Use batch operations
- Minimize API calls
- Cache responses
- Use webhooks instead of polling

---

## Security Checklist

- [ ] All API keys in .env (not in workflows)
- [ ] .env added to .gitignore
- [ ] Database password changed from default
- [ ] n8n basic auth enabled
- [ ] HTTPS enabled for production
- [ ] Firewall configured
- [ ] Regular backups enabled
- [ ] API keys rotated regularly
- [ ] Minimal API permissions granted
- [ ] Audit logs enabled

---

## Backup & Maintenance

### Database Backup

```bash
# Manual backup
pg_dump -U postgres n8n_workflows > backup_$(date +%Y%m%d).sql

# Automated backup (cron)
0 2 * * * pg_dump -U postgres n8n_workflows > /backups/db_$(date +\%Y\%m\%d).sql
```

### Workflow Backup

```bash
# Export workflows from n8n UI
# Or backup ~/.n8n directory
tar -czf n8n_backup_$(date +%Y%m%d).tar.gz ~/.n8n
```

### Cleanup Old Data

```sql
-- Run cleanup function
SELECT cleanup_old_logs();

-- Or schedule with pg_cron
SELECT cron.schedule('cleanup-logs', '0 2 * * 0', 'SELECT cleanup_old_logs();');
```

---

## Next Steps

1. Review all workflow configurations
2. Set up monitoring alerts
3. Configure backup schedules
4. Test disaster recovery
5. Document custom modifications
6. Train team members

---

## Support Resources

- **n8n Documentation**: https://docs.n8n.io/
- **Community Forum**: https://community.n8n.io/
- **GitHub Issues**: https://github.com/yourusername/574.lat/issues
- **API Documentation**: See each provider's docs

---

**Last Updated**: 2025-11-11
