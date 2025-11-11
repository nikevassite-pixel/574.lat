# 🚀 Inicio Rápido - 15 Minutos

Esta guía te ayudará a tener tu primer workflow funcionando en 15 minutos.

## Prerequisitos (5 minutos)

```bash
# Verificar requisitos
node --version  # >= 18
docker --version  # Cualquier versión reciente
psql --version  # >= 13

# Si falta algo
# Ubuntu/Debian:
sudo apt-get update
sudo apt-get install nodejs npm postgresql docker.io docker-compose

# macOS:
brew install node postgresql docker docker-compose
```

## Paso 1: Clonar y Configurar (3 minutos)

```bash
# Clonar repositorio
git clone https://github.com/yourusername/574.lat.git
cd 574.lat

# Copiar template de configuración
cp config/env.template .env

# Editar .env (mínimo requerido):
# - POSTGRES_PASSWORD=tu_password
# - N8N_PASSWORD=tu_password_admin
nano .env
```

## Paso 2: Base de Datos (2 minutos)

```bash
# Opción A: Docker PostgreSQL (recomendado)
docker-compose up -d postgres

# Opción B: PostgreSQL local
createdb n8n_workflows

# Crear esquema
psql -U postgres -d n8n_workflows -f scripts/database-schema.sql
```

## Paso 3: Iniciar n8n (2 minutos)

```bash
# Con Docker (recomendado)
docker-compose up -d n8n

# O sin Docker
npm install -g n8n
n8n start
```

Abrir navegador: http://localhost:5678

## Paso 4: Primer Workflow - Chatbot Simple (3 minutos)

### 4.1 Obtener Token de Telegram

1. Abrir Telegram
2. Buscar: @BotFather
3. Enviar: `/newbot`
4. Seguir instrucciones
5. Copiar token

### 4.2 Configurar Credenciales en n8n

```
1. n8n UI → Credentials → Add Credential
2. Buscar "Telegram"
3. Pegar token
4. Save
```

### 4.3 Importar Workflow

```
1. Workflows → Import from File
2. Seleccionar: workflows/iot/chatbot-integration.json
3. Activar workflow (toggle verde)
```

### 4.4 Probar

```
1. Abrir Telegram
2. Buscar tu bot (nombre que elegiste)
3. Enviar: /start
4. Deberías recibir respuesta!
```

## ¡Listo! 🎉

**Tienes tu primer workflow funcionando.**

---

## Siguientes Pasos (Opcional)

### Agregar IA al Chatbot

```bash
# Obtener API key de OpenAI
# 1. Ir a https://platform.openai.com/api-keys
# 2. Create new secret key
# 3. Copiar (empieza con sk-proj-)

# Configurar en n8n
1. Credentials → Add Credential → OpenAI
2. Pegar API Key
3. Test → Success!

# Ahora el bot tiene conversaciones inteligentes con GPT-4
```

### Segundo Workflow: Financial Data

```bash
# No requiere API keys (usa Yahoo Finance)
1. Import: workflows/financial/data-aggregation.json
2. Actualizar símbolos en nodo "Configure Symbols"
3. Configurar email SMTP (Gmail)
4. Execute Workflow → Recibir reporte!
```

### Tercer Workflow: Social Media

```bash
# Requiere Twitter Developer Account
1. Aplicar en: https://developer.twitter.com/
2. Configurar OAuth2 en n8n
3. Import workflow
4. Conectar Google Sheets
5. Activar!
```

---

## Troubleshooting Rápido

### n8n no inicia

```bash
# Ver logs
docker-compose logs n8n

# Problemas comunes:
# 1. Puerto 5678 ocupado
lsof -i :5678
# Cambiar puerto en .env: N8N_PORT=5679

# 2. Base de datos no conecta
docker-compose ps postgres
# Verificar PASSWORD en .env
```

### Workflow no se ejecuta

```bash
# Checklist:
1. ¿Workflow activado? (toggle verde)
2. ¿Credenciales configuradas?
3. ¿Test manual funciona?
   - Click "Execute Workflow"
4. Ver logs: Executions → Ver detalles
```

### Bot no responde

```bash
# Verificar webhook
1. Abrir workflow
2. Nodo "Telegram Bot Trigger"
3. Ver "Webhook URLs"
4. Debe mostrar URL activa

# Si no aparece:
- Activar workflow
- Esperar 10 segundos
- Refrescar página
```

---

## Recursos de Aprendizaje

### Documentación Completa

- **[README.md](README.md)** - Visión general del proyecto
- **[SETUP.md](docs/SETUP.md)** - Setup detallado por workflow
- **[USAGE_GUIDE.md](docs/USAGE_GUIDE.md)** - Guías de uso avanzadas
- **[FAQ.md](docs/FAQ.md)** - Preguntas frecuentes
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Arquitectura técnica
- **[DEPLOYMENT.md](docs/DEPLOYMENT.md)** - Deploy en producción

### Tutoriales Recomendados

**YouTube:**
- [n8n Basics](https://www.youtube.com/watch?v=RpjQTGKm-ok) - 20 min
- [JavaScript in n8n](https://www.youtube.com/watch?v=Prz5gtPLHk8) - 15 min
- [API Integrations](https://www.youtube.com/watch?v=3w7xIMKLVAg) - 25 min

**Lecturas:**
- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [Workflow Examples](https://n8n.io/workflows/)

---

## Personalización Rápida

### Cambiar Idioma del Bot

```javascript
// En nodo "Handle Bot Commands"
// Cambiar responseTemplates:

const responseTemplates = {
  'start': `¡Hola! 👋 Soy tu asistente...`,
  'help': `📚 Comandos disponibles...`,
  // ...
};
```

### Agregar Nuevo Comando

```javascript
// En el mismo nodo:

'clima': {
  response: 'Consultando el clima...',
  action: 'fetch_weather',
  requires_args: true
},

// Luego agregar handler en siguiente nodo
```

### Notificar a Email en Vez de Slack

```javascript
// Reemplazar nodo "Slack - Send Alert" con "Send Email"
// Configurar SMTP en .env:

SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu-email@gmail.com
SMTP_PASSWORD=app_password
```

---

## Próximos 30 Días

### Semana 1: Familiarización
- ✅ Día 1-2: Setup básico (¡Ya lo hiciste!)
- ⬜ Día 3-4: Explorar workflows incluidos
- ⬜ Día 5-7: Personalizar 1-2 workflows

### Semana 2: Expansión
- ⬜ Configurar más APIs
- ⬜ Importar 2-3 workflows adicionales
- ⬜ Conectar con tus servicios actuales

### Semana 3: Optimización
- ⬜ Ajustar schedules
- ⬜ Optimizar workflows lentos
- ⬜ Configurar alertas importantes

### Semana 4: Producción
- ⬜ Setup HTTPS
- ⬜ Configurar backups automáticos
- ⬜ Monitoreo básico
- ⬜ Documentar customizaciones

---

## Comunidad

**¿Tienes preguntas?**
- GitHub Issues: [574.lat/issues](https://github.com/yourusername/574.lat/issues)
- n8n Community: [community.n8n.io](https://community.n8n.io/)
- Stack Overflow: Tag `n8n`

**¿Quieres compartir tu setup?**
- GitHub Discussions: Muestra tu implementación
- Twitter: Tag @n8n_io

**¿Encontraste un bug?**
- Abre issue con:
  - Descripción del problema
  - Pasos para reproducir
  - Logs relevantes
  - Versiones (n8n, Node.js, OS)

---

## Checklist de Éxito ✅

**Configuración Básica:**
- [ ] n8n corriendo y accesible
- [ ] PostgreSQL conectado
- [ ] Primer workflow activado
- [ ] Test manual exitoso

**Seguridad:**
- [ ] Password de admin configurado
- [ ] .env en .gitignore
- [ ] Credenciales en n8n (no hardcodeadas)

**Documentación:**
- [ ] Leído README.md
- [ ] Revisado FAQ.md
- [ ] Explorado workflows incluidos

**Testing:**
- [ ] Workflow ejecuta sin errores
- [ ] Datos se guardan en DB
- [ ] Notificaciones funcionan

---

## ¿Listo para más?

**Nivel Intermedio:**
1. Configurar **E-commerce Inventory Sync** ([Setup](docs/SETUP.md#workflow-3-e-commerce-inventory-sync))
2. Implementar **AI Content Generation** ([Setup](docs/SETUP.md#workflow-2-ai-content-generation))
3. Deploy a producción ([Guide](docs/DEPLOYMENT.md))

**Nivel Avanzado:**
1. Setup **IoT Monitoring** con MQTT ([Setup](docs/SETUP.md#workflow-6-iot-device-monitoring))
2. Implementar **Financial Data Aggregation** ([Setup](docs/SETUP.md#workflow-5-financial-data-aggregation))
3. Escalar con Kubernetes ([Deployment](docs/DEPLOYMENT.md#kubernetes))

---

## Obtener Ayuda

**Documentación:**
```bash
# Ver todos los documentos
ls docs/

# Buscar en documentación
grep -r "palabra_clave" docs/
```

**Logs:**
```bash
# n8n
docker-compose logs -f n8n

# PostgreSQL
docker-compose logs postgres

# Todos los servicios
docker-compose logs -f
```

**Health Check:**
```bash
# Verificar servicios
docker-compose ps

# Test conexión n8n
curl http://localhost:5678/healthz

# Test base de datos
psql -h localhost -U postgres -d n8n_workflows -c "SELECT version();"
```

---

**¡Felicitaciones por completar el Quick Start! 🎉**

Tu viaje con n8n automation workflows acaba de comenzar.

**Siguiente paso sugerido**: Leer [USAGE_GUIDE.md](docs/USAGE_GUIDE.md) para personalizar workflows.

---

**Última Actualización**: 2025-11-11
