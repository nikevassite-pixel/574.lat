# Arquitectura del Sistema n8n Automation Workflows

## Tabla de Contenidos

1. [Visión General](#visión-general)
2. [Arquitectura Técnica](#arquitectura-técnica)
3. [Componentes del Sistema](#componentes-del-sistema)
4. [Flujo de Datos](#flujo-de-datos)
5. [Patrones de Diseño](#patrones-de-diseño)
6. [Seguridad](#seguridad)
7. [Escalabilidad](#escalabilidad)
8. [Monitoreo](#monitoreo)

---

## Visión General

Este sistema está compuesto por 8 workflows de automatización independientes pero complementarios que procesan datos de múltiples fuentes, los transforman usando IA y los distribuyen a varios destinos.

### Principios de Diseño

1. **Modularidad**: Cada workflow es independiente y puede ejecutarse sin otros
2. **Escalabilidad**: Diseñado para manejar grandes volúmenes de datos
3. **Resiliencia**: Manejo de errores y reintentos automáticos
4. **Observabilidad**: Logging completo y métricas de rendimiento
5. **Seguridad**: Credenciales encriptadas y principio de mínimo privilegio

---

## Arquitectura Técnica

```
┌─────────────────────────────────────────────────────────────┐
│                     CAPA DE ENTRADA                         │
├─────────────────────────────────────────────────────────────┤
│  • Triggers (Schedule, Webhook, MQTT, Email)                │
│  • API Polling (Social Media, E-commerce, Financial)        │
│  • Real-time Events (IoT Sensors, Chat Messages)            │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                  CAPA DE PROCESAMIENTO                      │
├─────────────────────────────────────────────────────────────┤
│  • Normalización de Datos                                   │
│  • Validación y Limpieza                                    │
│  • Transformación con IA (GPT-4, NLP)                       │
│  • Análisis y Agregación                                    │
│  • Detección de Anomalías                                   │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    CAPA DE NEGOCIO                          │
├─────────────────────────────────────────────────────────────┤
│  • Lógica de Enrutamiento                                   │
│  • Resolución de Conflictos                                 │
│  • Generación de Alertas                                    │
│  • Toma de Decisiones Automatizada                          │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                  CAPA DE PERSISTENCIA                       │
├─────────────────────────────────────────────────────────────┤
│  • PostgreSQL (Datos relacionales)                          │
│  • InfluxDB (Series temporales)                             │
│  • Cache (Redis - opcional)                                 │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    CAPA DE SALIDA                           │
├─────────────────────────────────────────────────────────────┤
│  • APIs Externas (Zendesk, Shopify, WordPress)              │
│  • Notificaciones (Slack, Email, PagerDuty)                 │
│  • Publicación de Datos (Google Sheets, Medium)             │
│  • Acciones MQTT (IoT Devices)                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Componentes del Sistema

### 1. n8n Core

**Rol**: Motor de ejecución de workflows
- Gestión de triggers y programación
- Ejecución de nodos
- Manejo de credenciales
- Cola de ejecución

**Configuración**:
```yaml
Modo de Ejecución: main (o worker para distribución)
Cola: memory (o redis para producción)
Timeout: 300s (configurable por workflow)
Concurrencia: 10 workflows simultáneos
```

### 2. PostgreSQL Database

**Rol**: Almacenamiento de datos estructurados

**Esquema**:
- 8 tablas principales
- 3 vistas materializadas
- 2 funciones almacenadas
- 15+ índices para optimización

**Rendimiento**:
- Connection pooling (2-10 conexiones)
- Índices en columnas de búsqueda frecuente
- Limpieza automática de datos antiguos

### 3. APIs de Terceros

**Categorías**:

**IA y NLP** (3 servicios):
- OpenAI: GPT-4, DALL-E 3
- Hugging Face: Modelos NLP
- Google Dialogflow (opcional)

**Redes Sociales** (3 plataformas):
- Twitter/X API v2
- Facebook Graph API
- Instagram Graph API

**E-commerce** (2 plataformas):
- Shopify Admin API
- WooCommerce REST API

**Comunicación** (3 servicios):
- Slack Web API
- Telegram Bot API
- Gmail API

**Soporte** (1 servicio):
- Zendesk API

**Financiero** (4 fuentes):
- Yahoo Finance
- Alpha Vantage
- CoinGecko
- Binance

**IoT** (2 servicios):
- MQTT Broker
- InfluxDB

**Gestión de Proyectos** (3 herramientas):
- Trello API
- Asana API
- Jira Cloud API

### 4. Servicios de Infraestructura

**MQTT Broker (Mosquitto)**:
- Protocolo: MQTT v3.1.1/v5
- Puerto: 1883 (o 8883 con SSL)
- QoS: 0-2 (configurable)
- Retención de mensajes: Configurable

**InfluxDB**:
- Versión: 2.x
- Bucket: iot-sensors
- Retención: 90 días (configurable)
- Downsampling: Automático

**Redis (Opcional)**:
- Uso: Cache y cola de mensajes
- TTL: Configurable por tipo de dato
- Persistencia: RDB + AOF

---

## Flujo de Datos

### Workflow 1: Social Media Analytics

```
┌──────────┐      ┌─────────┐      ┌──────────┐      ┌────────┐
│ Schedule │─────▶│ Twitter │─────▶│ Process  │─────▶│ Google │
│ (6 horas)│      │Facebook │      │ & Analyze│      │ Sheets │
│          │      │Instagram│      │          │      │        │
└──────────┘      └─────────┘      └──────────┘      └────────┘
                                          │
                                          ▼
                                    ┌──────────┐
                                    │PostgreSQL│
                                    └──────────┘
```

**Características**:
- Trigger: Schedule (0 */6 * * *)
- Procesamiento paralelo de 3 APIs
- Normalización de métricas
- Cálculo de engagement rate
- Exportación a Google Sheets

### Workflow 2: AI Content Generation

```
┌──────────┐      ┌─────────┐      ┌─────────┐      ┌──────────┐
│ Schedule │─────▶│RSS Feed │─────▶│ OpenAI  │─────▶│WordPress │
│ (4 horas)│      │ Reader  │      │ GPT-4   │      │ Medium   │
│          │      │         │      │ DALL-E  │      │          │
└──────────┘      └─────────┘      └─────────┘      └──────────┘
                                          │
                                          ▼
                                    ┌──────────┐
                                    │PostgreSQL│
                                    └──────────┘
```

**Características**:
- Trigger: Schedule (0 */4 * * *)
- Filtrado de artículos recientes
- Reescritura con GPT-4
- Generación de imágenes con DALL-E
- Publicación dual (WordPress + Medium)

### Workflow 3: E-commerce Inventory Sync

```
┌──────────┐      ┌─────────┐      ┌──────────┐      ┌────────┐
│ Schedule │─────▶│ Shopify │─────▶│ Compare  │─────▶│ Update │
│(15 mins) │      │WooCommer│      │ Detect   │      │ Slack  │
│          │      │ ce      │      │ Conflicts│      │ Alert  │
└──────────┘      │Database │      │          │      │        │
                  └─────────┘      └──────────┘      └────────┘
                                          │
                                          ▼
                                    ┌──────────┐
                                    │PostgreSQL│
                                    └──────────┘
```

**Características**:
- Trigger: Schedule (*/15 * * * *)
- Sincronización bidireccional
- Detección de conflictos
- Alertas de stock bajo
- Logging completo

### Workflow 4: Customer Support Routing

```
┌──────────┐      ┌─────────┐      ┌──────────┐      ┌────────┐
│  Gmail   │─────▶│ Hugging │─────▶│ Zendesk  │─────▶│ Slack  │
│ Trigger  │      │  Face   │      │ Create   │      │PagerDuty│
│          │      │ NLP     │      │ Route    │      │        │
└──────────┘      └─────────┘      └──────────┘      └────────┘
                                          │
                                          ▼
                                    ┌──────────┐
                                    │PostgreSQL│
                                    └──────────┘
```

**Características**:
- Trigger: Gmail (polling cada minuto)
- Clasificación con IA (8 categorías)
- Análisis de sentimiento
- Enrutamiento automático
- Respuestas automáticas
- Escalación a PagerDuty

### Workflow 5: Financial Data Aggregation

```
┌──────────┐      ┌─────────┐      ┌──────────┐      ┌────────┐
│ Schedule │─────▶│ Yahoo   │─────▶│ Analyze  │─────▶│ Email  │
│ (1 hora) │      │ Alpha V.│      │ Generate │      │ Sheets │
│          │      │CoinGecko│      │ Alerts   │      │        │
└──────────┘      │ Binance │      │          │      │        │
                  └─────────┘      └──────────┘      └────────┘
                                          │
                                          ▼
                                    ┌──────────┐
                                    │PostgreSQL│
                                    └──────────┘
```

**Características**:
- Trigger: Schedule (0 * * * *)
- Múltiples fuentes de datos
- Análisis técnico
- Detección de movimientos significativos
- Reportes HTML por email

### Workflow 6: IoT Device Monitoring

```
┌──────────┐      ┌─────────┐      ┌──────────┐      ┌────────┐
│   MQTT   │─────▶│ Validate│─────▶│ InfluxDB │─────▶│ Slack  │
│ Trigger  │      │ Detect  │      │          │      │PagerDuty│
│ (tiempo  │      │Anomalies│      │PostgreSQL│      │ MQTT   │
│  real)   │      │         │      │          │      │ Action │
└──────────┘      └─────────┘      └──────────┘      └────────┘
```

**Características**:
- Trigger: MQTT (tiempo real)
- Validación de umbrales
- Detección de anomalías
- Almacenamiento en InfluxDB
- Acciones automatizadas vía MQTT

### Workflow 7: Project Management Sync

```
┌──────────┐      ┌─────────┐      ┌──────────┐      ┌────────┐
│ Schedule │─────▶│ Trello  │─────▶│ Detect   │─────▶│ Update │
│ (5 mins) │      │ Asana   │      │ Conflicts│      │ Notify │
│          │      │ Jira    │      │ Sync     │      │        │
└──────────┘      └─────────┘      └──────────┘      └────────┘
                                          │
                                          ▼
                                    ┌──────────┐
                                    │PostgreSQL│
                                    └──────────┘
```

**Características**:
- Trigger: Schedule (*/5 * * * *)
- Sincronización 3-vías
- Hash MD5 para cambios
- Resolución "más reciente gana"

### Workflow 8: Real-Time Chatbot

```
┌──────────┐      ┌─────────┐      ┌──────────┐      ┌────────┐
│ Telegram │─────▶│ OpenAI  │─────▶│ Weather  │─────▶│Response│
│  Slack   │      │ GPT-4   │      │ News API │      │        │
│ Webhook  │      │ Dialog  │      │          │      │        │
└──────────┘      └─────────┘      └──────────┘      └────────┘
                                          │
                                          ▼
                                    ┌──────────┐
                                    │PostgreSQL│
                                    └──────────┘
```

**Características**:
- Trigger: Webhook (tiempo real)
- Procesamiento de comandos
- Conversaciones con IA
- Integración con APIs externas

---

## Patrones de Diseño

### 1. Event-Driven Architecture

**Aplicación**: Workflows de tiempo real (IoT, Chatbot, Email)

**Ventajas**:
- Baja latencia
- Escalabilidad horizontal
- Desacoplamiento de componentes

### 2. Pipeline Pattern

**Aplicación**: Procesamiento de datos (Social Media, Financial, Content)

**Etapas**:
1. Ingesta de datos
2. Normalización
3. Transformación
4. Agregación
5. Salida

### 3. Retry Pattern

**Implementación**:
```javascript
// Configuración de reintentos
{
  maxRetries: 3,
  backoffStrategy: 'exponential',
  initialDelay: 2000,
  maxDelay: 16000
}
```

**Aplicado en**:
- Llamadas a APIs externas
- Operaciones de base de datos
- Publicación de mensajes MQTT

### 4. Circuit Breaker Pattern

**Propósito**: Prevenir cascadas de fallos

**Estados**:
- Cerrado: Funcionamiento normal
- Abierto: Bloqueo de llamadas
- Semi-abierto: Prueba de recuperación

**Aplicado en**:
- APIs de terceros con rate limiting
- Servicios externos inestables

### 5. Fan-Out/Fan-In Pattern

**Aplicación**: Procesamiento paralelo en Social Media Analytics

```
        ┌─────────┐
        │ Trigger │
        └────┬────┘
             │
    ┌────────┼────────┐
    ▼        ▼        ▼
┌────────┐ ┌────┐ ┌────────┐
│Twitter │ │FB  │ │Instagram│
└────┬───┘ └──┬─┘ └───┬────┘
     └────────┼────────┘
              ▼
         ┌─────────┐
         │  Merge  │
         └─────────┘
```

### 6. Saga Pattern

**Aplicación**: Inventory Sync (transacciones distribuidas)

**Compensación**:
- Si falla actualización en Shopify → Revertir cambios en DB
- Si falla notificación → Reintentar o loggear

---

## Seguridad

### Autenticación y Autorización

**Gestión de Credenciales**:
- Almacenamiento encriptado en n8n
- Variables de entorno para secretos
- Rotación regular de API keys

**OAuth 2.0**:
- Twitter, Facebook, Google, Asana
- Refresh tokens automáticos
- Scopes mínimos necesarios

**API Keys**:
- OpenAI, Alpha Vantage, Weather
- Límites de tasa configurados
- Monitoreo de uso

### Protección de Datos

**En Tránsito**:
- HTTPS/TLS para todas las APIs
- MQTTS para MQTT en producción
- SSL para PostgreSQL

**En Reposo**:
- Encriptación de base de datos
- Backups encriptados
- Credenciales en variables de entorno

**Datos Sensibles**:
- No loggear credenciales
- Ofuscar información personal
- Cumplimiento GDPR/CCPA

### Network Security

**Firewall**:
```bash
# Ejemplo de reglas
- Allow: 5678/tcp (n8n UI)
- Allow: 5432/tcp (PostgreSQL - localhost only)
- Allow: 1883/tcp (MQTT)
- Allow: 8086/tcp (InfluxDB)
```

**Rate Limiting**:
- A nivel de API (configurado por proveedor)
- A nivel de n8n (workflow timeout)
- A nivel de base de datos (connection pool)

---

## Escalabilidad

### Escalado Horizontal

**Worker Mode**:
```env
# Configuración de múltiples workers
EXECUTIONS_PROCESS=worker
QUEUE_MODE=redis
QUEUE_REDIS_HOST=redis-cluster
```

**Beneficios**:
- Distribución de carga
- Tolerancia a fallos
- Incremento de throughput

### Escalado Vertical

**Optimizaciones**:
- Aumentar recursos de n8n (CPU, RAM)
- Optimizar consultas de base de datos
- Incrementar connection pool

### Optimización de Base de Datos

**Índices**:
```sql
-- Ejemplos de índices críticos
CREATE INDEX idx_sensor_timestamp ON iot_sensor_data(timestamp DESC);
CREATE INDEX idx_tickets_category ON support_tickets_log(category);
CREATE INDEX idx_financial_symbol ON financial_data(symbol, timestamp DESC);
```

**Particionamiento**:
```sql
-- Particionamiento por fecha (ejemplo)
CREATE TABLE iot_sensor_data_2025_01 PARTITION OF iot_sensor_data
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

### Caching

**Redis Cache**:
```javascript
// Ejemplo de cache de API responses
const cacheKey = `weather:${city}`;
const cachedData = await redis.get(cacheKey);
if (cachedData) return cachedData;

const freshData = await fetchWeather(city);
await redis.set(cacheKey, freshData, 'EX', 3600); // 1 hora
return freshData;
```

---

## Monitoreo

### Métricas Clave (KPIs)

**Rendimiento**:
- Tiempo de ejecución de workflows
- Tasa de éxito/fallo
- Latencia de API calls
- Throughput (items/minuto)

**Recursos**:
- Uso de CPU/RAM
- Conexiones de base de datos
- Espacio en disco
- Ancho de banda

**Negocio**:
- Tickets procesados/hora
- Contenido generado/día
- Alertas enviadas
- Tareas sincronizadas

### Logging

**Niveles**:
```javascript
ERROR   // Errores críticos
WARN    // Advertencias
INFO    // Información operacional
DEBUG   // Información de depuración
```

**Estructura**:
```json
{
  "timestamp": "2025-11-11T10:30:00Z",
  "level": "INFO",
  "workflow": "inventory-sync",
  "message": "Synced 25 products",
  "metadata": {
    "duration_ms": 1250,
    "items_processed": 25,
    "errors": 0
  }
}
```

### Alertas

**Condiciones de Alerta**:
- Workflow falla 3 veces consecutivas
- Tiempo de ejecución > 5 minutos
- API rate limit alcanzado
- Base de datos desconectada
- Disco > 90% lleno

**Canales**:
- Email (alertas críticas)
- Slack (alertas operacionales)
- PagerDuty (incidentes críticos)

### Dashboards

**Métricas en Tiempo Real**:
```
- Workflows activos: 8
- Ejecuciones/hora: 250
- Tasa de éxito: 98.5%
- API calls/minuto: 45
- Latencia promedio: 350ms
```

**Herramientas Sugeridas**:
- Grafana (visualización)
- Prometheus (métricas)
- ELK Stack (logs)
- n8n built-in monitoring

---

## Disaster Recovery

### Backups

**Frecuencia**:
- Base de datos: Diario (2 AM)
- Workflows: Semanal
- Credenciales: Manual (encriptado)

**Retención**:
- Backups diarios: 7 días
- Backups semanales: 4 semanas
- Backups mensuales: 12 meses

### Recuperación

**RTO (Recovery Time Objective)**: 1 hora
**RPO (Recovery Point Objective)**: 24 horas

**Procedimiento**:
1. Restaurar base de datos
2. Reimportar workflows
3. Configurar credenciales
4. Verificar conectividad
5. Activar workflows
6. Monitorear ejecuciones

---

## Mantenimiento

### Tareas Regulares

**Diarias**:
- Revisar logs de errores
- Verificar alertas
- Monitorear uso de APIs

**Semanales**:
- Analizar métricas de rendimiento
- Revisar backups
- Actualizar documentación

**Mensuales**:
- Rotación de API keys
- Limpieza de datos antiguos
- Actualización de dependencias
- Revisión de seguridad

---

## Conclusión

Esta arquitectura proporciona una base sólida, escalable y mantenible para automatización empresarial. Los patrones de diseño implementados aseguran resiliencia y extensibilidad, mientras que las prácticas de seguridad protegen datos sensibles.

**Última Actualización**: 2025-11-11
