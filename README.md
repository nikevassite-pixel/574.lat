# n8n Automation Workflows Collection

A comprehensive collection of production-ready n8n automation workflows for various business use cases. This repository contains 8 fully implemented workflows covering social media analytics, content generation, e-commerce, customer support, financial data, IoT monitoring, project management, and chatbot integration.

## 🚀 Features

- **Production-Ready**: All workflows are fully implemented with error handling and logging
- **Comprehensive Coverage**: 8 different automation categories
- **API Integrations**: 30+ API integrations including OpenAI, social media platforms, e-commerce systems, and more
- **Database Support**: PostgreSQL schemas included for data persistence
- **Real-Time Processing**: MQTT, webhooks, and polling triggers
- **AI-Powered**: Leverages GPT-4, DALL-E, and NLP models
- **Scalable Architecture**: Modular design with reusable components

## 📋 Workflow Catalog

### 1. Social Media Analytics Dashboard
**File**: `workflows/social-media/social-media-analytics-dashboard.json`

Collects and analyzes engagement metrics from multiple social media platforms.

**Features**:
- Twitter/X API integration for tweet analysis
- Facebook Page insights collection
- Instagram business account metrics
- Automated data processing and normalization
- Google Sheets export for visualization
- Runs every 6 hours

**APIs Used**: Twitter OAuth2, Facebook Graph API, Instagram Graph API, Google Sheets

**Setup Requirements**:
- Twitter Developer Account with OAuth2 credentials
- Facebook App with Page and Instagram permissions
- Google Cloud Project with Sheets API enabled

---

### 2. AI-Powered Content Generation Pipeline
**File**: `workflows/content-generation/ai-content-pipeline.json`

Automates content creation from RSS feeds using AI for rewriting and image generation.

**Features**:
- RSS feed monitoring and article extraction
- OpenAI GPT-4 for content rewriting and SEO optimization
- DALL-E 3 for featured image generation
- Automatic publishing to WordPress and Medium
- Content tracking in database
- Runs every 4 hours

**APIs Used**: OpenAI (GPT-4, DALL-E), WordPress REST API, Medium API

**Setup Requirements**:
- OpenAI API key
- WordPress site with REST API enabled
- Medium integration token
- PostgreSQL database

---

### 3. E-commerce Inventory Sync
**File**: `workflows/ecommerce/inventory-sync.json`

Synchronizes inventory levels across multiple e-commerce platforms with low stock alerts.

**Features**:
- Shopify product inventory monitoring
- WooCommerce stock synchronization
- Custom database integration
- Automated stock level updates
- Slack alerts for low stock (< 10 units)
- Conflict resolution logic
- Runs every 15 minutes

**APIs Used**: Shopify Admin API, WooCommerce REST API, Slack Web API

**Setup Requirements**:
- Shopify store with Admin API access
- WooCommerce site with REST API credentials
- Slack workspace and webhook
- PostgreSQL for sync logging

---

### 4. Customer Support Ticket Routing
**File**: `workflows/customer-support/ticket-routing.json`

AI-powered email classification and automated routing to support queues.

**Features**:
- Gmail inbox monitoring
- Hugging Face NLP for ticket categorization (8 categories)
- Sentiment analysis for priority assignment
- Automatic Zendesk ticket creation
- Smart routing to appropriate teams
- Automated email responses
- PagerDuty escalation for critical issues
- Real-time processing

**APIs Used**: Gmail API, Hugging Face Inference API, Zendesk API, Slack

**Categories**: Technical Support, Billing, Account Issues, Feature Requests, Bug Reports, General Inquiry, Complaints, Refund Requests

**Setup Requirements**:
- Gmail API with OAuth2
- Hugging Face API token
- Zendesk account with API access
- Slack workspace

---

### 5. Financial Data Aggregation Tool
**File**: `workflows/financial/data-aggregation.json`

Comprehensive financial market data aggregation with analysis and reporting.

**Features**:
- Stock market data from Yahoo Finance and Alpha Vantage
- Cryptocurrency tracking (CoinGecko, Binance)
- Technical analysis and trend detection
- Alert generation for significant movements (±5% stocks, ±10% crypto)
- HTML email reports with charts
- Google Sheets export
- Database archiving
- Hourly updates

**APIs Used**: Yahoo Finance, Alpha Vantage, CoinGecko, Binance, SMTP

**Setup Requirements**:
- Alpha Vantage API key
- Email server (SMTP) credentials
- Google Sheets OAuth2
- PostgreSQL database

---

### 6. IoT Device Monitoring System
**File**: `workflows/iot/device-monitoring.json`

Real-time IoT sensor data processing with anomaly detection and automated responses.

**Features**:
- MQTT broker integration for sensor data
- Multi-metric monitoring (temperature, humidity, pressure, battery)
- Anomaly detection with configurable thresholds
- Automated response actions via MQTT
- InfluxDB time-series storage
- Slack notifications for warnings
- PagerDuty incidents for critical alerts
- Real-time processing

**Metrics Monitored**:
- Temperature: -10°C to 50°C
- Humidity: 0% to 100%
- Pressure: 950 to 1050 hPa
- Battery Level: 0% to 100%

**Setup Requirements**:
- MQTT broker (e.g., Mosquitto)
- InfluxDB instance
- Slack workspace
- PagerDuty account
- PostgreSQL database

---

### 7. Project Management Task Sync
**File**: `workflows/project-management/task-sync.json`

Bi-directional task synchronization across project management platforms.

**Features**:
- Trello card synchronization
- Asana task management
- Jira issue tracking
- Conflict detection with MD5 hashing
- "Most recent wins" resolution strategy
- Slack notifications for conflicts
- Sync state tracking
- Runs every 5 minutes

**APIs Used**: Trello API, Asana OAuth2, Jira Cloud API, Slack

**Setup Requirements**:
- Trello API key and token
- Asana Personal Access Token
- Jira Cloud API credentials
- PostgreSQL for sync state
- Slack workspace

---

### 8. Real-Time Chatbot Integration
**File**: `workflows/iot/chatbot-integration.json`

Multi-platform chatbot with AI-powered conversations and command handling.

**Features**:
- Telegram bot integration
- Slack bot integration
- OpenAI GPT-4 for natural conversations
- Command system (/help, /status, /weather, etc.)
- Weather data integration
- Text analysis capabilities
- Interaction logging
- Real-time webhooks

**Commands**:
- `/start` - Welcome message
- `/help` - Show available commands
- `/status` - System status check
- `/weather <city>` - Get weather information
- `/news <topic>` - Fetch latest news
- `/reminder <text>` - Set reminders
- `/analyze <text>` - Text analysis

**Setup Requirements**:
- Telegram Bot Token (via BotFather)
- Slack App with Bot Token
- OpenAI API key
- OpenWeatherMap API key
- PostgreSQL database

---

## 🛠️ Installation & Setup

### Prerequisites

1. **n8n Instance** (v1.0.0 or higher)
   ```bash
   npm install -g n8n
   # or
   docker pull n8nio/n8n
   ```

2. **PostgreSQL Database** (v13 or higher)
   ```bash
   # Install PostgreSQL
   sudo apt-get install postgresql

   # Create database
   createdb n8n_workflows
   ```

3. **Required API Keys** (see each workflow's requirements)

### Quick Start

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/574.lat.git
   cd 574.lat
   ```

2. **Set Up Database**
   ```bash
   psql -U postgres -d n8n_workflows -f scripts/database-schema.sql
   ```

3. **Configure Environment Variables**
   ```bash
   cp config/env.template .env
   # Edit .env with your API keys and credentials
   ```

4. **Import Workflows into n8n**
   - Open n8n interface
   - Go to Workflows → Import from File
   - Select JSON files from `workflows/` directory
   - Configure credentials for each workflow

5. **Configure Credentials in n8n**
   For each workflow, set up the required credentials:
   - API keys
   - OAuth2 tokens
   - Database connections
   - SMTP settings

### Detailed Setup Guide

See `docs/SETUP.md` for comprehensive setup instructions for each workflow.

---

## 📊 Database Setup

All workflows use PostgreSQL for data persistence. Run the schema creation script:

```bash
psql -U postgres -d n8n_workflows -f scripts/database-schema.sql
```

This creates tables for:
- Social media analytics
- Content pipeline tracking
- Inventory sync logs
- Support ticket logs
- Financial data
- IoT sensor data
- Task sync state
- Chatbot interactions

---

## 🔑 API Credentials Required

### Social Media Workflows
- **Twitter**: OAuth 2.0 Client ID & Secret
- **Facebook/Instagram**: Facebook App ID & Secret
- **Google Sheets**: OAuth 2.0 credentials

### AI & NLP
- **OpenAI**: API key (for GPT-4 and DALL-E)
- **Hugging Face**: API token

### E-commerce
- **Shopify**: Admin API access token
- **WooCommerce**: Consumer Key & Secret

### Communication
- **Slack**: Bot User OAuth Token
- **Telegram**: Bot Token (from @BotFather)
- **Zendesk**: API token

### Financial APIs
- **Alpha Vantage**: API key (free tier available)
- **OpenWeatherMap**: API key

### Infrastructure
- **MQTT Broker**: Host, port, credentials
- **InfluxDB**: Token, org, bucket
- **PagerDuty**: API key

---

## 📁 Project Structure

```
574.lat/
├── workflows/
│   ├── social-media/
│   │   └── social-media-analytics-dashboard.json
│   ├── content-generation/
│   │   └── ai-content-pipeline.json
│   ├── ecommerce/
│   │   └── inventory-sync.json
│   ├── customer-support/
│   │   └── ticket-routing.json
│   ├── financial/
│   │   └── data-aggregation.json
│   ├── iot/
│   │   ├── device-monitoring.json
│   │   └── chatbot-integration.json
│   └── project-management/
│       └── task-sync.json
├── scripts/
│   ├── database-schema.sql
│   └── utils/
├── config/
│   └── env.template
├── docs/
│   └── SETUP.md
├── LICENSE
└── README.md
```

---

## 🔧 Configuration

### Environment Variables

Copy `config/env.template` to `.env` and configure:

```env
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=n8n_workflows
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password

# OpenAI
OPENAI_API_KEY=sk-...

# Alpha Vantage
ALPHA_VANTAGE_KEY=your_key

# Weather
WEATHER_API_KEY=your_key

# MQTT
MQTT_BROKER=mqtt://localhost:1883
MQTT_USERNAME=admin
MQTT_PASSWORD=password

# InfluxDB
INFLUXDB_URL=http://localhost:8086
INFLUXDB_TOKEN=your_token
INFLUXDB_ORG=your_org
INFLUXDB_BUCKET=iot-sensors
```

---

## 📖 Usage Examples

### Importing a Workflow

1. Open n8n web interface
2. Click "Workflows" in the left sidebar
3. Click "Import from File"
4. Select the JSON file (e.g., `social-media-analytics-dashboard.json`)
5. Review and configure credentials
6. Activate the workflow

### Testing a Workflow

1. Open the imported workflow
2. Click "Execute Workflow" for manual testing
3. Check execution logs for errors
4. Verify data in output nodes

### Monitoring Workflows

- Check n8n execution logs
- Review database tables for stored data
- Monitor Slack channels for alerts
- Check email for reports

---

## 🎯 Use Cases

### Business Intelligence
- Social media performance tracking
- Financial market analysis
- Customer sentiment analysis

### Operations
- Inventory management across platforms
- IoT device fleet monitoring
- Project management synchronization

### Customer Experience
- Automated support ticket routing
- AI-powered chatbot assistance
- Proactive low-stock alerts

### Content & Marketing
- Automated content generation
- Multi-platform publishing
- SEO-optimized article creation

---

## 🔒 Security Best Practices

1. **Credentials Management**
   - Use n8n's built-in credential encryption
   - Never commit API keys to git
   - Rotate API keys regularly

2. **Database Security**
   - Use strong passwords
   - Enable SSL connections
   - Restrict network access

3. **API Rate Limiting**
   - Implement exponential backoff
   - Monitor API usage
   - Cache responses when possible

4. **Data Privacy**
   - Comply with GDPR/CCPA
   - Encrypt sensitive data
   - Implement data retention policies

---

## 🐛 Troubleshooting

### Common Issues

**Workflow not triggering**
- Check trigger configuration (schedule, webhook URL)
- Verify workflow is activated
- Review execution logs

**API authentication errors**
- Verify credentials are correct
- Check if tokens have expired
- Ensure proper API permissions

**Database connection errors**
- Verify PostgreSQL is running
- Check connection parameters
- Ensure database and tables exist

**Rate limit errors**
- Reduce polling frequency
- Implement caching
- Use pagination for large datasets

---

## 📈 Performance Optimization

### Recommended Settings

1. **Execution Settings**
   - Set appropriate timeouts
   - Enable error workflows
   - Configure retry logic

2. **Database Optimization**
   - Create indexes on frequently queried columns
   - Archive old data regularly
   - Use connection pooling

3. **API Optimization**
   - Cache API responses
   - Batch API calls when possible
   - Use webhooks instead of polling

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Development Guidelines

- Follow n8n workflow best practices
- Document all custom code nodes
- Include error handling
- Add logging for debugging
- Test with sample data

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🆘 Support

For issues and questions:

1. Check the [documentation](docs/SETUP.md)
2. Search existing [GitHub issues](https://github.com/yourusername/574.lat/issues)
3. Create a new issue with detailed information
4. Join the [n8n community](https://community.n8n.io)

---

## 🌟 Acknowledgments

- [n8n](https://n8n.io) - Workflow automation platform
- [OpenAI](https://openai.com) - AI models (GPT-4, DALL-E)
- [Hugging Face](https://huggingface.co) - NLP models
- All the amazing API providers

---

## 📊 Statistics

- **Total Workflows**: 8
- **API Integrations**: 30+
- **Database Tables**: 8
- **Supported Platforms**: 20+
- **Lines of Code (nodes)**: 150+
- **Documentation Pages**: 10+

---

## 🗺️ Roadmap

### Coming Soon
- [ ] Webhook-based triggers for all workflows
- [ ] Enhanced error handling and retry logic
- [ ] Docker Compose setup for easy deployment
- [ ] Workflow templates for customization
- [ ] Advanced analytics dashboards
- [ ] More AI integrations (Claude, Gemini)
- [ ] Mobile app notifications

### Future Considerations
- Kubernetes deployment guides
- Terraform infrastructure as code
- CI/CD pipeline integration
- Performance monitoring with Grafana
- Cost optimization recommendations

---

## 📞 Contact

- **GitHub**: [@yourusername](https://github.com/yourusername)
- **Email**: contact@574.lat
- **Website**: https://574.lat

---

Made with ❤️ using n8n workflow automation
