# Guía de Despliegue - n8n Automation Workflows

## Tabla de Contenidos

1. [Opciones de Despliegue](#opciones-de-despliegue)
2. [Despliegue con Docker](#despliegue-con-docker)
3. [Despliegue en la Nube](#despliegue-en-la-nube)
4. [Despliegue con PM2](#despliegue-con-pm2)
5. [Configuración de Producción](#configuración-de-producción)
6. [SSL/HTTPS](#sslhttps)
7. [Backup y Recuperación](#backup-y-recuperación)
8. [Monitoreo](#monitoreo)

---

## Opciones de Despliegue

### Comparación Rápida

| Método | Complejidad | Escalabilidad | Costo | Mejor Para |
|--------|-------------|---------------|-------|------------|
| Docker Compose | Baja | Media | Bajo | Desarrollo, Small teams |
| Kubernetes | Alta | Alta | Alto | Empresas, Alto tráfico |
| Cloud (AWS/GCP) | Media | Alta | Medio-Alto | Producción escalable |
| VPS + PM2 | Media | Baja-Media | Bajo | Startups, MVP |
| n8n Cloud | Muy Baja | Alta | Medio | Equipos sin DevOps |

---

## Despliegue con Docker

### Opción 1: Docker Compose (Recomendado)

**Paso 1: Crear docker-compose.yml**

```yaml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=${N8N_HOST}
      - N8N_PORT=5678
      - N8N_PROTOCOL=${N8N_PROTOCOL}
      - NODE_ENV=production
      - WEBHOOK_URL=${WEBHOOK_URL}
      - GENERIC_TIMEZONE=${TIMEZONE}

      # Base de datos
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=${POSTGRES_DB}
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}

      # Autenticación
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD}

      # Ejecución
      - EXECUTIONS_PROCESS=main
      - EXECUTIONS_TIMEOUT=300
      - EXECUTIONS_TIMEOUT_MAX=3600

      # Encriptación
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}

    volumes:
      - n8n_data:/home/node/.n8n
      - ./workflows:/workflows
      - ./backups:/backups
    depends_on:
      - postgres
      - redis
    networks:
      - n8n-network

  postgres:
    image: postgres:15-alpine
    container_name: n8n-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_DB=${POSTGRES_DB}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/database-schema.sql:/docker-entrypoint-initdb.d/01-schema.sql
    ports:
      - "5432:5432"
    networks:
      - n8n-network

  redis:
    image: redis:7-alpine
    container_name: n8n-redis
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    networks:
      - n8n-network

  mosquitto:
    image: eclipse-mosquitto:2
    container_name: n8n-mosquitto
    restart: unless-stopped
    ports:
      - "1883:1883"
      - "9001:9001"
    volumes:
      - ./config/mosquitto.conf:/mosquitto/config/mosquitto.conf
      - mosquitto_data:/mosquitto/data
      - mosquitto_logs:/mosquitto/log
    networks:
      - n8n-network

  influxdb:
    image: influxdb:2.7-alpine
    container_name: n8n-influxdb
    restart: unless-stopped
    ports:
      - "8086:8086"
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_USERNAME=${INFLUXDB_USER}
      - DOCKER_INFLUXDB_INIT_PASSWORD=${INFLUXDB_PASSWORD}
      - DOCKER_INFLUXDB_INIT_ORG=${INFLUXDB_ORG}
      - DOCKER_INFLUXDB_INIT_BUCKET=${INFLUXDB_BUCKET}
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=${INFLUXDB_TOKEN}
    volumes:
      - influxdb_data:/var/lib/influxdb2
    networks:
      - n8n-network

  nginx:
    image: nginx:alpine
    container_name: n8n-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./config/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - n8n
    networks:
      - n8n-network

volumes:
  n8n_data:
  postgres_data:
  redis_data:
  mosquitto_data:
  mosquitto_logs:
  influxdb_data:

networks:
  n8n-network:
    driver: bridge
```

**Paso 2: Crear archivo .env**

```bash
# n8n Configuration
N8N_HOST=n8n.tudominio.com
N8N_PROTOCOL=https
N8N_PORT=5678
WEBHOOK_URL=https://n8n.tudominio.com/
TIMEZONE=America/Mexico_City

# Autenticación n8n
N8N_USER=admin
N8N_PASSWORD=tu_password_seguro_aqui
N8N_ENCRYPTION_KEY=tu_clave_encriptacion_32_caracteres

# PostgreSQL
POSTGRES_DB=n8n
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=postgres_password_seguro

# Redis
REDIS_PASSWORD=redis_password_seguro

# InfluxDB
INFLUXDB_USER=admin
INFLUXDB_PASSWORD=influx_password_seguro
INFLUXDB_ORG=mi-organizacion
INFLUXDB_BUCKET=iot-sensors
INFLUXDB_TOKEN=tu_influxdb_token_aqui
```

**Paso 3: Configurar NGINX**

```nginx
# config/nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream n8n {
        server n8n:5678;
    }

    server {
        listen 80;
        server_name n8n.tudominio.com;

        # Redirect HTTP to HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name n8n.tudominio.com;

        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        client_max_body_size 16M;

        location / {
            proxy_pass http://n8n;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            # Timeouts
            proxy_connect_timeout 600s;
            proxy_send_timeout 600s;
            proxy_read_timeout 600s;
        }
    }
}
```

**Paso 4: Configurar Mosquitto**

```conf
# config/mosquitto.conf
listener 1883
allow_anonymous false
password_file /mosquitto/config/passwd

# Logging
log_dest file /mosquitto/log/mosquitto.log
log_type all

# Persistence
persistence true
persistence_location /mosquitto/data/

# Security
acl_file /mosquitto/config/acl
```

**Paso 5: Iniciar Stack**

```bash
# Crear usuarios MQTT
docker run -it --rm \
  -v $(pwd)/config:/config \
  eclipse-mosquitto:2 \
  mosquitto_passwd -c /config/passwd admin

# Iniciar servicios
docker-compose up -d

# Verificar logs
docker-compose logs -f n8n

# Verificar estado
docker-compose ps
```

**Paso 6: Importar Workflows**

```bash
# Copiar workflows al contenedor
docker cp workflows/ n8n:/workflows/

# O desde UI de n8n
# http://n8n.tudominio.com
# Workflows → Import from File
```

---

## Despliegue en la Nube

### AWS (Amazon Web Services)

#### Arquitectura Recomendada

```
┌─────────────────────────────────────────┐
│              Route 53 (DNS)              │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│     CloudFront (CDN) + WAF              │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│  Application Load Balancer (ALB)        │
└──────┬───────────────────────┬──────────┘
       │                       │
┌──────▼──────┐        ┌───────▼────────┐
│  EC2 (n8n)  │        │  EC2 (n8n)     │
│  Auto Scaling│        │  Auto Scaling  │
└──────┬──────┘        └───────┬────────┘
       │                       │
       └───────────┬───────────┘
                   │
┌──────────────────▼──────────────────────┐
│     RDS PostgreSQL (Multi-AZ)           │
│     ElastiCache Redis                   │
│     S3 (Backups)                        │
└─────────────────────────────────────────┘
```

#### Terraform Configuration

```hcl
# main.tf
provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "n8n_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "n8n-vpc"
  }
}

# Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.n8n_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "n8n-public-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.n8n_vpc.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "n8n-private-${count.index}"
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "n8n_db" {
  identifier           = "n8n-postgres"
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = var.db_instance_class
  allocated_storage    = 100
  storage_type         = "gp3"
  storage_encrypted    = true

  db_name  = "n8n"
  username = var.db_username
  password = var.db_password

  multi_az               = true
  publicly_accessible    = false
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.n8n.name

  tags = {
    Name = "n8n-postgres"
  }
}

# ElastiCache Redis
resource "aws_elasticache_cluster" "n8n_redis" {
  cluster_id           = "n8n-redis"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name    = aws_elasticache_subnet_group.n8n.name
  security_group_ids   = [aws_security_group.redis.id]

  tags = {
    Name = "n8n-redis"
  }
}

# EC2 Launch Template
resource "aws_launch_template" "n8n" {
  name_prefix   = "n8n-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    db_host     = aws_db_instance.n8n_db.address
    redis_host  = aws_elasticache_cluster.n8n_redis.cache_nodes[0].address
    n8n_version = var.n8n_version
  }))

  vpc_security_group_ids = [aws_security_group.n8n.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.n8n.name
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "n8n-worker"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "n8n" {
  name                = "n8n-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.n8n.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 2
  max_size         = 10
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.n8n.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "n8n-worker"
    propagate_at_launch = true
  }
}

# Application Load Balancer
resource "aws_lb" "n8n" {
  name               = "n8n-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = true
  enable_http2              = true

  tags = {
    Name = "n8n-alb"
  }
}

# S3 Bucket para Backups
resource "aws_s3_bucket" "backups" {
  bucket = "n8n-backups-${var.account_id}"

  tags = {
    Name = "n8n-backups"
  }
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "n8n-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.n8n.name
  }
}
```

**user-data.sh**:
```bash
#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

# Create n8n directory
mkdir -p /opt/n8n
cd /opt/n8n

# Clone repository
git clone https://github.com/yourusername/574.lat.git .

# Configure environment
cat > .env <<EOF
N8N_HOST=n8n.tudominio.com
N8N_PROTOCOL=https
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=${db_host}
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=${db_username}
DB_POSTGRESDB_PASSWORD=${db_password}
QUEUE_MODE=redis
QUEUE_REDIS_HOST=${redis_host}
QUEUE_REDIS_PORT=6379
EXECUTIONS_PROCESS=worker
EOF

# Start n8n
docker-compose up -d

# Configure CloudWatch logs
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/n8n/config/cloudwatch-config.json
```

**Deploy**:
```bash
# Inicializar Terraform
terraform init

# Planificar deployment
terraform plan -out=tfplan

# Aplicar cambios
terraform apply tfplan

# Output
terraform output alb_dns_name
```

---

### Google Cloud Platform (GCP)

#### Con Cloud Run

```bash
# Dockerfile optimizado
FROM n8nio/n8n:latest

# Variables de entorno de producción
ENV NODE_ENV=production
ENV N8N_DIAGNOSTICS_ENABLED=false
ENV N8N_PERSONALIZATION_ENABLED=false

# Exponer puerto
EXPOSE 5678

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:5678/ || exit 1

# Comando de inicio
CMD ["n8n"]
```

```bash
# Build y push a GCR
gcloud builds submit --tag gcr.io/${PROJECT_ID}/n8n

# Deploy a Cloud Run
gcloud run deploy n8n \
  --image gcr.io/${PROJECT_ID}/n8n \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2 \
  --timeout 3600 \
  --concurrency 80 \
  --min-instances 1 \
  --max-instances 10 \
  --set-env-vars="N8N_HOST=n8n.tudominio.com,N8N_PROTOCOL=https" \
  --set-secrets="DB_PASSWORD=db-password:latest,N8N_ENCRYPTION_KEY=encryption-key:latest"

# Configurar Cloud SQL
gcloud sql instances create n8n-postgres \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1

# Conectar Cloud Run a Cloud SQL
gcloud run services update n8n \
  --add-cloudsql-instances=${PROJECT_ID}:us-central1:n8n-postgres
```

---

### DigitalOcean (Simple y Económico)

```bash
# Crear Droplet
doctl compute droplet create n8n \
  --image ubuntu-22-04-x64 \
  --size s-2vcpu-4gb \
  --region nyc1 \
  --ssh-keys YOUR_SSH_KEY_ID

# Configurar Managed PostgreSQL
doctl databases create n8n-db \
  --engine pg \
  --version 15 \
  --size db-s-1vcpu-1gb \
  --region nyc1

# Configurar Managed Redis
doctl databases create n8n-redis \
  --engine redis \
  --version 7 \
  --size db-s-1vcpu-1gb \
  --region nyc1

# SSH al droplet
ssh root@DROPLET_IP

# Instalar Docker y desplegar
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
git clone https://github.com/yourusername/574.lat.git
cd 574.lat
cp config/env.template .env
# Editar .env con credenciales de bases de datos
docker-compose up -d
```

---

## Despliegue con PM2

### Instalación

```bash
# Instalar n8n globalmente
npm install -g n8n pm2

# Crear archivo de configuración
cat > ecosystem.config.js <<EOF
module.exports = {
  apps: [{
    name: 'n8n',
    script: 'n8n',
    instances: 2,
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      N8N_HOST: 'n8n.tudominio.com',
      N8N_PROTOCOL: 'https',
      N8N_PORT: 5678,
      DB_TYPE: 'postgresdb',
      DB_POSTGRESDB_HOST: 'localhost',
      DB_POSTGRESDB_PORT: 5432,
      DB_POSTGRESDB_DATABASE: 'n8n',
      DB_POSTGRESDB_USER: 'n8n_user',
      DB_POSTGRESDB_PASSWORD: process.env.DB_PASSWORD,
      EXECUTIONS_PROCESS: 'main',
      QUEUE_MODE: 'memory',
      N8N_ENCRYPTION_KEY: process.env.N8N_ENCRYPTION_KEY
    },
    error_file: './logs/n8n-error.log',
    out_file: './logs/n8n-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    max_memory_restart: '1G',
    restart_delay: 4000,
    kill_timeout: 3000
  }]
};
EOF

# Iniciar n8n
pm2 start ecosystem.config.js

# Guardar configuración
pm2 save

# Configurar inicio automático
pm2 startup

# Monitorear
pm2 monit
```

---

## Configuración de Producción

### Optimizaciones de Rendimiento

```env
# n8n.env
# Ejecución
EXECUTIONS_PROCESS=worker
QUEUE_MODE=redis
N8N_CONCURRENCY_PRODUCTION_LIMIT=10

# Timeouts
EXECUTIONS_TIMEOUT=300
EXECUTIONS_TIMEOUT_MAX=3600

# Memoria
N8N_PAYLOAD_SIZE_MAX=16

# Workers
QUEUE_WORKER_TIMEOUT=60
QUEUE_HEALTH_CHECK_INTERVAL=60

# Logs
N8N_LOG_LEVEL=info
N8N_LOG_OUTPUT=console,file
N8N_LOG_FILE_LOCATION=/var/log/n8n/

# Seguridad
N8N_BASIC_AUTH_ACTIVE=true
N8N_JWT_AUTH_ACTIVE=true
N8N_SECURE_COOKIE=true

# Métricas
N8N_METRICS=true
N8N_DIAGNOSTICS_ENABLED=false
```

### Configuración de Base de Datos

```sql
-- Optimizaciones PostgreSQL
-- postgresql.conf

-- Memory
shared_buffers = 4GB
effective_cache_size = 12GB
maintenance_work_mem = 1GB
work_mem = 256MB

-- Checkpoint
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100

-- Connections
max_connections = 200
superuser_reserved_connections = 3

-- Performance
random_page_cost = 1.1
effective_io_concurrency = 200

-- Logging
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_statement = 'all'
log_duration = on
log_min_duration_statement = 1000

-- Autovacuum
autovacuum = on
log_autovacuum_min_duration = 0
autovacuum_max_workers = 4
autovacuum_naptime = 30s
```

---

## SSL/HTTPS

### Opción 1: Let's Encrypt (Gratis)

```bash
# Instalar Certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtener certificado
sudo certbot --nginx -d n8n.tudominio.com

# Renovación automática
sudo certbot renew --dry-run

# Agregar a crontab
0 0 * * * certbot renew --quiet
```

### Opción 2: Cloudflare (Recomendado)

```bash
# 1. Agregar sitio a Cloudflare
# 2. Actualizar nameservers en registrar
# 3. SSL/TLS mode: Full (strict)
# 4. Crear Page Rule:
#    - URL: n8n.tudominio.com/*
#    - SSL: Full (strict)
#    - Always Use HTTPS: On
#    - HTTP/2: On
```

---

## Backup y Recuperación

### Script de Backup Automático

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RETENTION_DAYS=30

# Backup PostgreSQL
docker exec n8n-postgres pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} > \
  ${BACKUP_DIR}/db_${TIMESTAMP}.sql

# Backup n8n data
docker cp n8n:/home/node/.n8n ${BACKUP_DIR}/n8n_data_${TIMESTAMP}
tar -czf ${BACKUP_DIR}/n8n_data_${TIMESTAMP}.tar.gz -C ${BACKUP_DIR} n8n_data_${TIMESTAMP}
rm -rf ${BACKUP_DIR}/n8n_data_${TIMESTAMP}

# Backup workflows
docker exec n8n n8n export:workflow --backup --output=/backups/workflows_${TIMESTAMP}.json

# Upload to S3
aws s3 sync ${BACKUP_DIR} s3://n8n-backups/ --storage-class GLACIER

# Cleanup old backups
find ${BACKUP_DIR} -name "*.sql" -mtime +${RETENTION_DAYS} -delete
find ${BACKUP_DIR} -name "*.tar.gz" -mtime +${RETENTION_DAYS} -delete
find ${BACKUP_DIR} -name "*.json" -mtime +${RETENTION_DAYS} -delete

# Send notification
curl -X POST https://hooks.slack.com/services/YOUR/WEBHOOK/URL \
  -H 'Content-Type: application/json' \
  -d "{\"text\":\"✅ Backup completado: ${TIMESTAMP}\"}"
```

```bash
# Agregar a crontab
0 2 * * * /opt/n8n/backup.sh >> /var/log/n8n-backup.log 2>&1
```

### Procedimiento de Recuperación

```bash
# Restaurar base de datos
docker exec -i n8n-postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} < backup.sql

# Restaurar n8n data
tar -xzf n8n_data_backup.tar.gz
docker cp n8n_data n8n:/home/node/.n8n

# Reimportar workflows
docker exec n8n n8n import:workflow --input=/backups/workflows_backup.json

# Reiniciar servicios
docker-compose restart n8n
```

---

## Monitoreo

### Prometheus + Grafana

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'n8n'
    static_configs:
      - targets: ['n8n:5678']
    metrics_path: '/metrics'

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
```

```yaml
# docker-compose monitoring
services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"

  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
```

### Dashboards Recomendados

Importar en Grafana:
- Node Exporter Full (ID: 1860)
- PostgreSQL Database (ID: 9628)
- Redis Dashboard (ID: 763)

---

**Última Actualización**: 2025-11-11
