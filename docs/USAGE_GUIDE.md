# Guía de Uso - n8n Automation Workflows

## Tabla de Contenidos

1. [Inicio Rápido](#inicio-rápido)
2. [Guías por Workflow](#guías-por-workflow)
3. [Casos de Uso Comunes](#casos-de-uso-comunes)
4. [Personalización](#personalización)
5. [Best Practices](#best-practices)
6. [Solución de Problemas](#solución-de-problemas)

---

## Inicio Rápido

### Requisitos Previos

Asegúrate de haber completado:
- ✅ Instalación de n8n
- ✅ Configuración de PostgreSQL
- ✅ Configuración de archivo `.env`
- ✅ Creación de tablas de base de datos

### Primer Workflow en 5 Minutos

**Ejemplo: Chatbot de Telegram**

1. **Crear el Bot en Telegram**:
   ```
   - Abrir Telegram y buscar @BotFather
   - Enviar /newbot
   - Seguir instrucciones
   - Copiar el token
   ```

2. **Importar Workflow**:
   ```
   - Abrir n8n (http://localhost:5678)
   - Ir a Workflows → Import from File
   - Seleccionar: workflows/iot/chatbot-integration.json
   ```

3. **Configurar Credenciales**:
   ```
   - Ir a Credentials → Add Credential
   - Seleccionar "Telegram API"
   - Pegar el bot token
   - Guardar
   ```

4. **Activar Webhook**:
   ```
   - En el workflow, hacer clic en el nodo "Telegram Bot Trigger"
   - Copiar la URL del webhook
   - Configurar webhook en Telegram
   ```

5. **Activar y Probar**:
   ```
   - Activar workflow (toggle en la parte superior)
   - Enviar /start a tu bot en Telegram
   - ¡Deberías recibir una respuesta!
   ```

---

## Guías por Workflow

### 1. Social Media Analytics Dashboard

#### Configuración Inicial

**Paso 1: Credenciales de Twitter**
```
1. Ir a https://developer.twitter.com/
2. Crear una App
3. Generar OAuth 2.0 Client ID y Secret
4. En n8n:
   - Credentials → Twitter OAuth2 API
   - Ingresar Client ID y Secret
   - Completar flujo OAuth
```

**Paso 2: Credenciales de Facebook**
```
1. Ir a https://developers.facebook.com/
2. Crear App → Tipo: Business
3. Agregar producto: Facebook Login
4. Configurar OAuth Redirect URI
5. En n8n:
   - Credentials → Facebook Graph API
   - Ingresar App ID y Secret
   - Completar flujo OAuth
```

**Paso 3: Google Sheets**
```
1. Crear una nueva hoja de cálculo
2. Copiar el ID del spreadsheet (de la URL)
3. En n8n:
   - Credentials → Google Sheets OAuth2
   - Autorizar acceso
4. En el workflow:
   - Actualizar el nodo "Google Sheets"
   - Pegar el Spreadsheet ID
```

#### Personalización

**Cambiar consulta de Twitter**:
```javascript
// En el nodo "Twitter API - Search"
// Actualizar el campo searchText:

// Búsqueda simple
"#n8n OR #automation"

// Búsqueda avanzada
"(automation OR workflow) -spam lang:es"

// Por usuario
"from:n8n_io"
```

**Ajustar frecuencia**:
```javascript
// En el nodo "Schedule Trigger"
// Cambiar interval:

// Cada 3 horas
{ hours: 3 }

// Cada día a las 9 AM
{ hour: 9, minute: 0 }

// Dos veces al día
{ hours: 12 } // y duplicar el workflow
```

**Métricas personalizadas**:
```javascript
// En el nodo "Process Twitter Data"
// Agregar nuevas métricas:

processedTwitter.metrics.avg_likes =
  processedTwitter.metrics.total_likes /
  processedTwitter.metrics.tweets_analyzed;

processedTwitter.metrics.viral_threshold =
  processedTwitter.metrics.total_retweets > 1000;
```

#### Uso Diario

1. **Ver Dashboard**:
   - Abrir Google Sheets
   - Pestaña "Analytics"
   - Crear gráficos con los datos

2. **Exportar Datos**:
   ```sql
   -- Consultar datos históricos
   SELECT * FROM social_media_metrics
   WHERE platform = 'twitter'
   AND timestamp > NOW() - INTERVAL '7 days';
   ```

3. **Generar Reportes**:
   - Usar Google Data Studio
   - Conectar a la hoja de cálculo
   - Crear visualizaciones

---

### 2. AI-Powered Content Generation

#### Configuración Inicial

**Paso 1: OpenAI API**
```bash
# Obtener API key
1. Visitar https://platform.openai.com/api-keys
2. Crear nueva clave
3. Copiar la clave (empieza con sk-proj-)

# Configurar en n8n
1. Credentials → OpenAI
2. Pegar API Key
3. Test Connection
```

**Paso 2: Configurar RSS Feeds**
```javascript
// En el nodo "Configuration"
// Actualizar feedUrl con tus feeds favoritos:

{
  feedUrl: 'https://techcrunch.com/feed/',
  // o múltiples feeds
  feeds: [
    'https://techcrunch.com/feed/',
    'https://www.theverge.com/rss/index.xml',
    'https://www.wired.com/feed/rss'
  ]
}
```

**Paso 3: WordPress**
```bash
# Habilitar REST API
1. WordPress Admin → Settings → Permalinks
2. Seleccionar "Post name"
3. Guardar

# Crear Application Password
1. Users → Profile
2. Application Passwords → Add New
3. Nombre: "n8n Integration"
4. Copiar password generado

# Configurar en n8n
1. Credentials → HTTP Basic Auth
2. Username: tu_usuario_wp
3. Password: application_password
```

#### Personalización

**Modificar Prompt de GPT-4**:
```javascript
// En el nodo "OpenAI - Rewrite Content"
// Personalizar el prompt del sistema:

{
  role: "system",
  content: `Eres un escritor profesional especializado en ${niche}.
            Tu estilo es ${style}.
            Tu audiencia es ${audience}.

            Reglas:
            - Usa tono ${tone}
            - Incluye ${keywords} naturalmente
            - Longitud: ${wordCount} palabras
            - Formato: ${format}`
}

// Ejemplos de valores:
niche: "tecnología empresarial"
style: "informativo pero accesible"
audience: "profesionales de IT"
tone: "profesional pero amigable"
keywords: ["cloud computing", "devops"]
wordCount: 500
format: "introducción + 3 puntos clave + conclusión"
```

**Configurar Categorías de WordPress**:
```javascript
// En el nodo "WordPress - Create Post"
// Agregar al body:

bodyParameters: {
  parameters: [
    ...existingParams,
    {
      name: "categories",
      value: [1, 5, 12] // IDs de categorías
    },
    {
      name: "tags",
      value: [23, 45] // IDs de tags
    },
    {
      name: "author",
      value: 2 // ID del autor
    }
  ]
}
```

**Filtrar Contenido**:
```javascript
// En el nodo "Filter Recent Articles"
// Agregar filtros adicionales:

const filtered = items.filter(item => {
  const pubDate = new Date(item.json.pubDate);
  const isRecent = pubDate > fourHoursAgo;

  // Filtro adicional: solo artículos con ciertas palabras clave
  const hasKeywords = ['AI', 'automation', 'n8n'].some(keyword =>
    item.json.title.includes(keyword)
  );

  // Filtro: longitud mínima
  const minLength = (item.json.content || '').length > 500;

  return isRecent && hasKeywords && minLength;
});
```

#### Uso Diario

**Revisar Contenido Generado**:
```bash
# Consultar artículos pendientes
SELECT
  generated_headline,
  wordpress_post_id,
  status,
  created_at
FROM content_pipeline
WHERE status = 'draft'
ORDER BY created_at DESC;
```

**Aprobar y Publicar**:
```bash
# En WordPress
1. Ir a Posts → Drafts
2. Revisar contenido generado
3. Editar si es necesario
4. Publicar

# O programáticamente
UPDATE wp_posts
SET post_status = 'publish'
WHERE ID = 123;
```

**Analizar Rendimiento**:
```sql
SELECT
  DATE(created_at) as fecha,
  COUNT(*) as articulos_generados,
  COUNT(CASE WHEN status = 'published' THEN 1 END) as publicados
FROM content_pipeline
GROUP BY DATE(created_at)
ORDER BY fecha DESC
LIMIT 30;
```

---

### 3. E-commerce Inventory Sync

#### Configuración Inicial

**Paso 1: Shopify**
```bash
# Obtener Access Token
1. Shopify Admin → Apps → Develop apps
2. Create an app
3. Configure Admin API scopes:
   ☑ read_products
   ☑ write_products
   ☑ read_inventory
   ☑ write_inventory
4. Install app
5. Copiar Admin API access token

# Configurar en n8n
1. Credentials → Shopify API
2. Shop Subdomain: tu-tienda
3. Access Token: shpat_xxxxx
4. Test Connection
```

**Paso 2: WooCommerce**
```bash
# Generar API Keys
1. WordPress Admin → WooCommerce → Settings
2. Advanced → REST API → Add Key
3. Description: "n8n Sync"
4. User: (tu usuario)
5. Permissions: Read/Write
6. Generate API Key
7. Copiar Consumer Key y Consumer Secret

# Configurar en n8n
1. Credentials → HTTP Basic Auth
2. Username: Consumer Key
3. Password: Consumer Secret

# En el workflow
1. Actualizar nodo "WooCommerce - Get Products"
2. URL: https://tu-tienda.com
```

**Paso 3: Slack Webhook**
```bash
# Crear Incoming Webhook
1. Ir a https://api.slack.com/apps
2. Create New App → From Scratch
3. Features → Incoming Webhooks → Activate
4. Add New Webhook to Workspace
5. Seleccionar canal: #inventory-alerts
6. Copiar Webhook URL

# Configurar en n8n
1. Credentials → Slack API
2. Pegar Bot Token
```

#### Personalización

**Ajustar Umbrales**:
```javascript
// En el nodo "Consolidate and Analyze Inventory"
// Modificar thresholds:

// Stock bajo
const LOW_STOCK_THRESHOLD = 10; // Cambiar a tu valor

// Crítico (out of stock)
const CRITICAL_THRESHOLD = 0;

// Advertencia temprana
const WARNING_THRESHOLD = 25;

if (masterStock < WARNING_THRESHOLD) {
  alerts.push({
    level: masterStock === 0 ? 'CRITICAL' :
           masterStock < LOW_STOCK_THRESHOLD ? 'WARNING' :
           'INFO',
    // ...
  });
}
```

**Configurar Reglas de Sincronización**:
```javascript
// En el nodo "Detect Conflicts and Changes"
// Personalizar lógica de resolución:

// Opción 1: Siempre usar base de datos maestra
const masterStock = dbRecord ? dbRecord.stock_quantity : 0;

// Opción 2: Usar el valor más alto
const masterStock = Math.max(
  dbRecord?.stock_quantity || 0,
  shopifyStock,
  woocommerceStock
);

// Opción 3: Promedio
const masterStock = Math.round(
  (shopifyStock + woocommerceStock) / 2
);

// Opción 4: Reglas por producto
if (sku.startsWith('PREMIUM-')) {
  // Productos premium: usar Shopify como fuente
  masterStock = shopifyStock;
} else {
  // Otros: usar WooCommerce
  masterStock = woocommerceStock;
}
```

**Formato de Alertas Slack**:
```javascript
// En el nodo "Format Slack Alert Message"
// Personalizar mensaje:

let message = `🚨 *Alerta de Inventario*\n\n`;
message += `*Tienda:* ${storeName}\n`;
message += `*Fecha:* ${new Date().toLocaleDateString('es-ES')}\n\n`;

// Agregar información adicional
if (critical.length > 0) {
  message += `*🔴 CRÍTICO - Sin Stock (${critical.length}):*\n`;
  critical.forEach(alert => {
    message += `• ${alert.title}\n`;
    message += `  SKU: ${alert.sku}\n`;
    message += `  Acción: Reabastecer URGENTE\n`;
    message += `  Última venta: ${alert.last_sale}\n\n`;
  });
}

// Agregar link a reorden
message += `\n<https://tu-tienda.com/admin/purchase-orders|Crear Orden de Compra>`;
```

#### Uso Diario

**Monitorear Sincronización**:
```sql
-- Ver últimas sincronizaciones
SELECT
  sku,
  platform,
  previous_stock,
  new_stock,
  synced_at,
  status
FROM inventory_sync_log
WHERE synced_at > NOW() - INTERVAL '1 day'
ORDER BY synced_at DESC
LIMIT 50;

-- Detectar productos con problemas
SELECT
  sku,
  COUNT(*) as sync_failures
FROM inventory_sync_log
WHERE status = 'error'
  AND synced_at > NOW() - INTERVAL '1 week'
GROUP BY sku
HAVING COUNT(*) > 3
ORDER BY sync_failures DESC;
```

**Sincronización Manual**:
```bash
# En n8n UI
1. Abrir workflow "E-commerce Inventory Sync"
2. Click "Execute Workflow"
3. Esperar resultados
4. Verificar en logs

# O programáticamente
curl -X POST \
  http://localhost:5678/webhook/inventory-sync-manual \
  -H 'Content-Type: application/json'
```

---

### 4. Customer Support Ticket Routing

#### Configuración Inicial

**Paso 1: Gmail API**
```bash
# Habilitar API
1. Ir a https://console.cloud.google.com/
2. Crear proyecto o seleccionar existente
3. APIs & Services → Library
4. Buscar "Gmail API" → Enable

# Crear credenciales OAuth
1. Credentials → Create Credentials → OAuth client ID
2. Application type: Web application
3. Authorized redirect URIs:
   - http://localhost:5678/rest/oauth2-credential/callback
4. Copiar Client ID y Client Secret

# Configurar en n8n
1. Credentials → Gmail OAuth2
2. Pegar Client ID y Secret
3. Authorize → Completar flujo OAuth
```

**Paso 2: Hugging Face**
```bash
# Obtener API Token
1. Ir a https://huggingface.co/settings/tokens
2. New token
3. Name: "n8n NLP"
4. Role: Read
5. Copiar token (empieza con hf_)

# Configurar en n8n
1. Credentials → HTTP Header Auth
2. Name: Authorization
3. Value: Bearer hf_xxxxx
```

**Paso 3: Zendesk**
```bash
# Obtener API Token
1. Admin Center → Apps and integrations → APIs
2. Zendesk API → Add API token
3. Copiar token

# Configurar en n8n
1. Credentials → Zendesk API
2. Subdomain: tu-company
3. Email: admin@tu-company.com
4. API Token: tu_token

# Configurar Group IDs
1. En Zendesk, ir a Admin → Groups
2. Anotar IDs de cada grupo
3. Actualizar en el workflow (nodo "Process and Determine Routing")
```

#### Personalización

**Ajustar Categorías**:
```javascript
// En el nodo "Hugging Face - Classify Ticket"
// Modificar candidate_labels:

const categories = [
  "soporte_tecnico",
  "facturacion",
  "cuenta_bloqueada",
  "solicitud_caracteristica",
  "reporte_bug",
  "pregunta_general",
  "queja",
  "solicitud_reembolso",
  // Agregar tus categorías
  "problema_entrega",
  "cambio_producto",
  "consulta_precompra"
];
```

**Configurar Enrutamiento**:
```javascript
// En el nodo "Process and Determine Routing"
// Actualizar routingMap con tus grupos de Zendesk:

const routingMap = {
  'soporte_tecnico': {
    group_id: 123456,  // Tu ID de grupo
    tags: ['tecnico', 'soporte'],
    priority: 'normal',
    assignee_id: null  // o ID específico
  },
  'facturacion': {
    group_id: 123457,
    tags: ['billing', 'finanzas'],
    priority: 'high',
    assignee_id: 999  // Asignar a contador específico
  },
  // ... agregar más mapeos
};
```

**Personalizar Respuestas Automáticas**:
```javascript
// En el nodo "Generate Auto-Response"
// Modificar templates:

const responseTemplates = {
  'soporte_tecnico': `
    Hola {{customer_name}},

    Gracias por contactar soporte técnico de {{company_name}}.

    Hemos recibido tu consulta sobre: {{issue_summary}}

    Un especialista revisará tu caso en las próximas 2 horas.

    Mientras tanto, te recomendamos:
    - Revisar nuestra base de conocimiento: {{kb_link}}
    - Verificar el estado del sistema: {{status_page}}

    Ticket ID: {{ticket_id}}

    Saludos,
    Equipo de Soporte
  `,
  // ... más templates
};
```

**Ajustar Prioridades**:
```javascript
// En el nodo "Process and Determine Routing"
// Lógica de prioridad personalizada:

let priority = 'normal';

// Por sentimiento
if (sentimentLabel === 'NEGATIVE' && sentimentScore > 0.9) {
  priority = 'urgent';
} else if (sentimentLabel === 'NEGATIVE' && sentimentScore > 0.7) {
  priority = 'high';
}

// Por categoría
if (['cuenta_bloqueada', 'sistema_caido'].includes(topCategory)) {
  priority = 'urgent';
}

// Por cliente
if (isVIPCustomer(email)) {
  priority = priority === 'normal' ? 'high' : priority;
}

// Por hora del día
const hour = new Date().getHours();
if (hour < 6 || hour > 22) {
  // Fuera de horario: reducir prioridad no urgente
  if (priority === 'high') priority = 'normal';
}

// Por palabras clave
const urgentKeywords = ['urgente', 'crítico', 'bloqueado', 'no puedo'];
if (urgentKeywords.some(kw => subject.toLowerCase().includes(kw))) {
  priority = 'high';
}
```

#### Uso Diario

**Dashboard de Tickets**:
```sql
-- Resumen diario
SELECT
  category,
  priority,
  COUNT(*) as total_tickets,
  AVG(sentiment_score) as avg_sentiment,
  COUNT(CASE WHEN auto_response_sent THEN 1 END) as auto_responded
FROM support_tickets_log
WHERE DATE(created_at) = CURRENT_DATE
GROUP BY category, priority
ORDER BY total_tickets DESC;

-- Tickets sin responder
SELECT
  sender_email,
  subject,
  category,
  priority,
  created_at,
  EXTRACT(EPOCH FROM (NOW() - created_at))/3600 as hours_waiting
FROM support_tickets_log
WHERE zendesk_ticket_id IS NOT NULL
  AND escalated = false
  AND created_at > NOW() - INTERVAL '24 hours'
ORDER BY hours_waiting DESC;
```

**Analizar Rendimiento**:
```sql
-- Precisión de clasificación (necesita verificación manual)
SELECT
  category,
  AVG(category_confidence) as avg_confidence,
  COUNT(*) as total
FROM support_tickets_log
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY category
ORDER BY avg_confidence DESC;

-- Distribución de sentimiento
SELECT
  sentiment,
  COUNT(*) as count,
  ROUND(COUNT(*)::numeric / SUM(COUNT(*)) OVER () * 100, 2) as percentage
FROM support_tickets_log
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY sentiment;
```

---

### 5. Financial Data Aggregation

#### Configuración Inicial

**Paso 1: Alpha Vantage**
```bash
# Obtener API Key
1. Ir a https://www.alphavantage.co/support/#api-key
2. Ingresar email
3. Recibir API key por email
4. Free tier: 500 requests/day, 5/minute

# Configurar
export ALPHA_VANTAGE_KEY=tu_api_key
```

**Paso 2: Configurar Símbolos**
```javascript
// En el nodo "Configure Symbols"
// Personalizar tu watchlist:

const config = {
  // Acciones
  stocks: [
    'AAPL',   // Apple
    'GOOGL',  // Google
    'MSFT',   // Microsoft
    'AMZN',   // Amazon
    'TSLA',   // Tesla
    // Agregar más...
  ],

  // Criptomonedas
  crypto: [
    'bitcoin',
    'ethereum',
    'cardano',
    // Agregar más...
  ],

  // Índices (opcional)
  indices: [
    '^GSPC',  // S&P 500
    '^DJI',   // Dow Jones
    '^IXIC',  // NASDAQ
  ]
};
```

**Paso 3: SMTP Email**
```bash
# Gmail App Password
1. Google Account → Security
2. 2-Step Verification (activar si no está)
3. App passwords
4. Select app: Mail
5. Select device: Other (n8n)
6. Generate
7. Copiar password de 16 caracteres

# Configurar en n8n
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu-email@gmail.com
SMTP_PASSWORD=xxxx xxxx xxxx xxxx
```

#### Personalización

**Ajustar Umbrales de Alerta**:
```javascript
// En el nodo "Analyze and Generate Insights"
// Modificar thresholds:

// Para acciones
const STOCK_ALERT_MEDIUM = 5;   // ±5%
const STOCK_ALERT_HIGH = 10;    // ±10%

// Para cripto
const CRYPTO_ALERT_MEDIUM = 10;  // ±10%
const CRYPTO_ALERT_HIGH = 20;    // ±20%

// Alertas personalizadas por símbolo
const customThresholds = {
  'TSLA': { medium: 7, high: 15 },  // Tesla más volátil
  'BTC': { medium: 5, high: 10 },   // Bitcoin
  // ...
};
```

**Personalizar Reporte HTML**:
```javascript
// En el nodo "Generate Email Report"
// Modificar template:

const htmlReport = `
<!DOCTYPE html>
<html>
<head>
  <style>
    /* Tus estilos personalizados */
    .logo { width: 200px; }
    .header {
      background: ${brandColor};
      color: white;
    }
    /* ... */
  </style>
</head>
<body>
  <div class="header">
    <img src="${logoUrl}" class="logo">
    <h1>📊 Reporte Financiero Diario</h1>
    <p>${companyName} - ${date}</p>
  </div>

  <!-- Tu contenido personalizado -->
  <div class="summary">
    <h2>Resumen Ejecutivo</h2>
    <p>${executiveSummary}</p>
  </div>

  <!-- Gráficos (usando Chart.js o similar) -->
  <div class="charts">
    <canvas id="stockChart"></canvas>
  </div>

  <!-- ... -->
</body>
</html>
`;
```

**Agregar Indicadores Técnicos**:
```javascript
// En el nodo "Analyze and Generate Insights"
// Calcular indicadores:

// Simple Moving Average (SMA)
function calculateSMA(prices, period = 20) {
  const sma = [];
  for (let i = period - 1; i < prices.length; i++) {
    const sum = prices.slice(i - period + 1, i + 1)
      .reduce((a, b) => a + b, 0);
    sma.push(sum / period);
  }
  return sma;
}

// Relative Strength Index (RSI)
function calculateRSI(prices, period = 14) {
  const changes = [];
  for (let i = 1; i < prices.length; i++) {
    changes.push(prices[i] - prices[i-1]);
  }

  const gains = changes.map(c => c > 0 ? c : 0);
  const losses = changes.map(c => c < 0 ? -c : 0);

  const avgGain = gains.slice(0, period).reduce((a,b) => a+b) / period;
  const avgLoss = losses.slice(0, period).reduce((a,b) => a+b) / period;

  const rs = avgGain / avgLoss;
  const rsi = 100 - (100 / (1 + rs));

  return rsi;
}

// Usar en el análisis
stocks.forEach(stock => {
  const sma20 = calculateSMA(stock.historicalPrices, 20);
  const rsi = calculateRSI(stock.historicalPrices);

  stock.technical = {
    sma20: sma20[sma20.length - 1],
    rsi: rsi,
    signal: rsi > 70 ? 'OVERBOUGHT' :
            rsi < 30 ? 'OVERSOLD' :
            'NEUTRAL'
  };
});
```

#### Uso Diario

**Consultar Histórico**:
```sql
-- Rendimiento de símbolos
SELECT
  symbol,
  DATE(timestamp) as fecha,
  AVG(current_price) as precio_promedio,
  MIN(current_price) as precio_min,
  MAX(current_price) as precio_max,
  AVG(change_percent) as cambio_promedio
FROM financial_data
WHERE timestamp > NOW() - INTERVAL '30 days'
GROUP BY symbol, DATE(timestamp)
ORDER BY symbol, fecha DESC;

-- Alertas generadas
SELECT
  symbol,
  alert_type,
  severity,
  message,
  triggered_value,
  created_at
FROM financial_alerts
WHERE created_at > NOW() - INTERVAL '7 days'
ORDER BY created_at DESC;
```

**Backtesting de Estrategias**:
```sql
-- Simular estrategia: comprar en caídas > 5%
WITH signals AS (
  SELECT
    symbol,
    timestamp,
    current_price,
    change_percent,
    CASE
      WHEN change_percent < -5 THEN 'BUY'
      WHEN change_percent > 10 THEN 'SELL'
      ELSE 'HOLD'
    END as signal
  FROM financial_data
  WHERE timestamp > NOW() - INTERVAL '90 days'
)
SELECT
  symbol,
  COUNT(CASE WHEN signal = 'BUY' THEN 1 END) as buy_signals,
  COUNT(CASE WHEN signal = 'SELL' THEN 1 END) as sell_signals
FROM signals
GROUP BY symbol;
```

---

## Casos de Uso Comunes

### Caso 1: Startup Tech

**Necesidad**: Monitoreo de marca en redes sociales + contenido automatizado

**Workflows**:
1. Social Media Analytics (cada 6 horas)
2. AI Content Generation (diario)
3. Chatbot Integration (24/7)

**Configuración**:
- Monitorear menciones de la marca
- Generar contenido educativo
- Soporte inicial automatizado

**ROI Estimado**:
- 10 horas/semana ahorradas
- Mayor presencia online
- Respuesta 24/7 a clientes

### Caso 2: E-commerce Mediano

**Necesidad**: Sincronización multi-canal + soporte eficiente

**Workflows**:
1. Inventory Sync (cada 15 min)
2. Customer Support Routing (tiempo real)
3. Financial Data (para decisiones de pricing)

**Configuración**:
- Sync Shopify ↔ Amazon ↔ eBay
- Auto-routing de tickets
- Análisis de precios de competencia

**ROI Estimado**:
- 90% reducción en sobreventa
- 60% más rápido en responder tickets
- Mejor pricing strategy

### Caso 3: Agencia de Marketing

**Necesidad**: Reportes automáticos para clientes

**Workflows**:
1. Social Media Analytics (por cliente)
2. AI Content Generation (contenido masivo)
3. Project Management Sync (coordinación)

**Configuración**:
- Duplicar workflow por cliente
- Templates de contenido personalizados
- Dashboard centralizado

**ROI Estimado**:
- 20 horas/semana en reportes
- 3x más contenido generado
- Mejor coordinación de equipo

### Caso 4: Empresa IoT

**Necesidad**: Monitoreo de dispositivos + alertas

**Workflows**:
1. IoT Device Monitoring (tiempo real)
2. Financial Data (para inversores)
3. Customer Support (para usuarios finales)

**Configuración**:
- MQTT para todos los dispositivos
- Dashboard en InfluxDB/Grafana
- Escalación automática de incidentes

**ROI Estimado**:
- 99.9% uptime
- Respuesta < 5 min a incidentes
- Satisfacción de cliente +40%

---

## Best Practices

### 1. Seguridad

✅ **Hacer**:
- Rotar API keys cada 90 días
- Usar variables de entorno
- Habilitar 2FA en todas las cuentas
- Encriptar backups
- Auditar accesos regularmente

❌ **No Hacer**:
- Hardcodear credenciales en workflows
- Compartir API keys
- Usar cuentas admin para integraciones
- Desactivar SSL/TLS
- Ignorar alertas de seguridad

### 2. Rendimiento

✅ **Hacer**:
- Cachear respuestas de APIs
- Usar indices en base de datos
- Implementar rate limiting
- Monitorear uso de recursos
- Optimizar consultas SQL

❌ **No Hacer**:
- Polling muy frecuente sin necesidad
- Procesar datos sin filtrar
- Cargar datos completos sin paginación
- Ignorar timeouts
- Ejecutar workflows manualmente para prod

### 3. Mantenibilidad

✅ **Hacer**:
- Documentar cambios en workflows
- Usar nombres descriptivos de nodos
- Comentar código JavaScript
- Versionar workflows (export)
- Mantener changelog

❌ **No Hacer**:
- Modificar sin probar
- Duplicar lógica en múltiples workflows
- Ignorar errores en logs
- Desactivar workflows sin documentar por qué
- Mezclar entornos (dev/prod)

### 4. Monitoreo

✅ **Hacer**:
- Configurar alertas proactivas
- Revisar logs diariamente
- Trackear métricas clave
- Hacer auditorías mensuales
- Documentar incidentes

❌ **No Hacer**:
- Asumir que todo funciona
- Ignorar warnings
- Esperar a que usuarios reporten problemas
- No tener plan de rollback
- Descuidar métricas de negocio

---

## Solución de Problemas

### Problema: Workflow no se ejecuta

**Síntomas**:
- No aparece en executions
- Trigger no responde
- Webhook devuelve 404

**Soluciones**:
1. Verificar que workflow está activado (toggle verde)
2. Comprobar schedule syntax
3. Verificar webhook URL
4. Revisar logs de n8n:
   ```bash
   tail -f ~/.n8n/logs/n8n.log
   ```
5. Test manual: Click "Execute Workflow"

### Problema: API Error 401/403

**Síntomas**:
- "Unauthorized"
- "Forbidden"
- "Invalid credentials"

**Soluciones**:
1. Verificar credenciales en n8n Credentials
2. Comprobar que API key no expiró
3. Verificar permisos/scopes
4. Test con curl:
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://api.example.com/test
   ```
5. Regenerar API key si es necesario

### Problema: Workflow muy lento

**Síntomas**:
- Timeout errors
- Execution > 2 minutos
- Queue de ejecuciones

**Soluciones**:
1. Reducir número de items procesados
2. Agregar paginación
3. Usar procesamiento paralelo
4. Optimizar JavaScript code:
   ```javascript
   // Lento
   items.forEach(item => {
     // operación costosa por item
   });

   // Rápido
   const results = items.map(item => {
     // operación optimizada
   }).filter(r => r !== null);
   ```
5. Aumentar timeout en workflow settings

### Problema: Datos duplicados

**Síntomas**:
- Múltiples inserts del mismo registro
- Emails duplicados
- Alertas repetidas

**Soluciones**:
1. Agregar constraint UNIQUE en DB:
   ```sql
   ALTER TABLE tabla
   ADD CONSTRAINT unique_campo UNIQUE (campo);
   ```
2. Usar "Remove Duplicates" node
3. Implementar deduplicación:
   ```javascript
   const seen = new Set();
   const unique = items.filter(item => {
     const key = item.json.id;
     if (seen.has(key)) return false;
     seen.add(key);
     return true;
   });
   ```
4. Agregar validación en workflow

---

## Recursos Adicionales

**Documentación**:
- [SETUP.md](SETUP.md) - Guía de instalación
- [ARCHITECTURE.md](ARCHITECTURE.md) - Arquitectura técnica
- [API_REFERENCE.md](API_REFERENCE.md) - Referencia de APIs

**Comunidad**:
- [n8n Community Forum](https://community.n8n.io/)
- [GitHub Issues](https://github.com/yourusername/574.lat/issues)
- [Stack Overflow - n8n tag](https://stackoverflow.com/questions/tagged/n8n)

**Videos y Tutoriales**:
- [n8n YouTube Channel](https://www.youtube.com/@n8n_io)
- [Workflow Examples](https://n8n.io/workflows/)

---

**Última Actualización**: 2025-11-11
**Versión**: 1.0.0
