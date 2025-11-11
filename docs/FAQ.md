# Preguntas Frecuentes (FAQ)

## Tabla de Contenidos

1. [General](#general)
2. [Instalación](#instalación)
3. [Configuración](#configuración)
4. [Workflows](#workflows)
5. [APIs y Credenciales](#apis-y-credenciales)
6. [Troubleshooting](#troubleshooting)
7. [Costos](#costos)
8. [Rendimiento](#rendimiento)
9. [Seguridad](#seguridad)
10. [Soporte](#soporte)

---

## General

### ¿Qué es n8n?

n8n es una plataforma de automatización de workflows de código abierto que permite conectar diferentes aplicaciones y servicios para automatizar tareas repetitivas. Es similar a Zapier o Make (Integromat) pero self-hosted.

### ¿Necesito experiencia en programación?

**No es estrictamente necesario**, pero ayuda. Los workflows incluidos están listos para usar. Sin embargo, personalizaciones avanzadas pueden requerir JavaScript básico.

**Nivel de dificultad por workflow:**
- 🟢 **Fácil**: Social Media Analytics, Chatbot
- 🟡 **Intermedio**: E-commerce Sync, Content Generation
- 🔴 **Avanzado**: IoT Monitoring, Financial Data

### ¿Puedo usar esto en producción?

**Sí**, todos los workflows están diseñados para producción. Asegúrate de:
- ✅ Usar HTTPS
- ✅ Configurar backups automáticos
- ✅ Monitorear recursos
- ✅ Rotar API keys regularmente
- ✅ Seguir las best practices de seguridad

### ¿Cuánto tiempo toma implementar?

**Depende del workflow:**

| Workflow | Setup Inicial | Testing | Total |
|----------|---------------|---------|-------|
| Chatbot | 30 min | 15 min | 45 min |
| Social Media | 1 hora | 30 min | 1.5 h |
| E-commerce | 2 horas | 1 hora | 3 h |
| IoT Monitoring | 3 horas | 2 horas | 5 h |
| Financial | 1.5 horas | 30 min | 2 h |

**Nota**: Tiempos asumen que ya tienes las cuentas API necesarias.

---

## Instalación

### ¿Qué necesito para empezar?

**Requisitos mínimos:**
- Servidor/VPS con 2 GB RAM
- PostgreSQL 13+
- Node.js 18+
- n8n 1.0+

**Opcional pero recomendado:**
- Redis (para queue mode)
- MQTT Broker (para IoT workflows)
- InfluxDB (para series temporales)

### ¿Puedo usar Windows?

**Sí**, pero recomendamos Linux o macOS para producción.

**Opciones en Windows:**
1. **WSL2** (Windows Subsystem for Linux) - Recomendado
2. **Docker Desktop** - Más fácil
3. **Instalación nativa** - Posible pero complicado

```bash
# En Windows con WSL2
wsl --install
# Luego seguir guía de Linux
```

### ¿Docker es obligatorio?

**No**, pero altamente recomendado porque:
- ✅ Setup más fácil
- ✅ Aislamiento de dependencias
- ✅ Fácil de escalar
- ✅ Portabilidad entre entornos

**Alternativa sin Docker:**
```bash
npm install -g n8n
n8n start
```

### ¿Puedo usar la versión cloud de n8n?

**Sí**, n8n ofrece versión cloud (https://n8n.io/cloud).

**Ventajas:**
- Sin gestión de infraestructura
- Actualizaciones automáticas
- Soporte oficial

**Desventajas:**
- Costo mensual (~$20-200/mes)
- Menos control sobre datos
- Límites de ejecución

**Nuestros workflows funcionan igual en ambas versiones.**

---

## Configuración

### ¿Dónde pongo mis API keys?

**Dos lugares:**

1. **Archivo `.env`** (para variables de sistema):
   ```env
   OPENAI_API_KEY=sk-proj-xxxxx
   POSTGRES_PASSWORD=xxxxx
   ```

2. **n8n Credentials** (para conexiones a APIs):
   ```
   n8n UI → Credentials → Add Credential
   ```

**Nunca** hardcodees API keys en los workflows JSON.

### ¿Cómo obtengo tantas API keys?

**Prioriza según tus necesidades:**

**Esenciales (para empezar):**
- OpenAI (GPT-4) - $20 crédito gratis
- Twitter - Gratis (nivel básico)
- Google Sheets - Gratis
- Slack - Gratis

**Opcionales (según workflow):**
- Shopify - Requiere tienda ($29/mes mínimo)
- Zendesk - Plan trial disponible
- Alpha Vantage - 500 requests/día gratis

**Tip**: Empieza con 1-2 workflows y expande gradualmente.

### ¿Tengo que usar TODAS las integraciones?

**No.** Cada workflow es independiente.

**Ejemplo mínimo viable:**
- Workflow de Chatbot: Solo Telegram + OpenAI
- Workflow de Social Media: Solo Twitter + Google Sheets
- Workflow de Financial: Solo Yahoo Finance (no requiere API key)

Puedes desactivar integraciones que no uses.

### ¿Cómo cambio el schedule de un workflow?

**En n8n UI:**
1. Abrir workflow
2. Click en nodo "Schedule Trigger"
3. Modificar interval:

```javascript
// Cada hora
{ hours: 1 }

// Cada día a las 9 AM
{ hour: 9, minute: 0 }

// Cada lunes
{ dayOfWeek: 1, hour: 9 }

// Cron expression
{ cronExpression: '0 9 * * 1' }
```

---

## Workflows

### ¿Puedo ejecutar workflows manualmente?

**Sí**, de 3 formas:

1. **n8n UI**: Click "Execute Workflow"
2. **Webhook**: `curl -X POST http://localhost:5678/webhook/workflow-id`
3. **CLI**: `n8n execute --id=workflow-id`

### ¿Cuántos workflows puedo ejecutar simultáneamente?

**Depende de recursos:**

**Por defecto**: 10 concurrent executions

**Configurar límite**:
```env
N8N_CONCURRENCY_PRODUCTION_LIMIT=20
```

**Recomendaciones:**
- 2 GB RAM: 5 workflows
- 4 GB RAM: 10 workflows
- 8 GB RAM: 20 workflows

### ¿Los workflows se afectan entre sí?

**No**, son independientes. Si uno falla, los demás continúan.

**Excepciones:**
- Comparten base de datos (PostgreSQL)
- Comparten rate limits de APIs
- Comparten recursos de servidor

### ¿Puedo modificar los workflows?

**¡Absolutamente!** Son tuyos. Recomendaciones:

1. **Hacer backup antes**:
   ```bash
   n8n export:workflow --backup --output=backup.json
   ```

2. **Probar en entorno de desarrollo**

3. **Documentar cambios**:
   ```javascript
   // Comentario en nodo
   // Modificado: 2025-11-11
   // Razón: Agregar validación de email
   ```

4. **Versionarlos con Git**

### ¿Cómo debug un workflow?

**Métodos:**

1. **Execution logs** (n8n UI → Executions)
2. **Console logs en Code nodes**:
   ```javascript
   console.log('Debug:', JSON.stringify(data));
   ```

3. **Sticky Notes** para documentar lógica

4. **Test con datos mockeados**:
   ```javascript
   const testData = {
     email: 'test@example.com',
     subject: 'Test ticket'
   };
   ```

5. **Logs del sistema**:
   ```bash
   tail -f ~/.n8n/logs/n8n.log
   ```

---

## APIs y Credenciales

### ¿Son seguras mis API keys en n8n?

**Sí**, n8n encripta credenciales usando:
- AES-256-CBC encryption
- Encryption key almacenada en `N8N_ENCRYPTION_KEY`

**Best practices:**
- ✅ Usar variables de entorno
- ✅ Nunca commitear `.env` a git
- ✅ Rotar keys cada 90 días
- ✅ Usar API keys con permisos mínimos

### ¿Qué pasa si excedo el rate limit de una API?

**Los workflows tienen retry logic:**

```javascript
// Configuración típica
maxRetries: 3
retryDelay: 2000ms (exponential backoff)
```

**Acciones recomendadas:**
- Reducir frecuencia de polling
- Implementar caching
- Upgrade de plan de API si es necesario

### ¿Puedo usar cuentas gratuitas de APIs?

**Sí**, pero con limitaciones:

| API | Tier Gratuito | Límites | Suficiente Para |
|-----|---------------|---------|-----------------|
| OpenAI | $5-20 crédito | ~100k tokens | Testing, proyectos pequeños |
| Twitter | Básico | 500k tweets/mes | Sí, para mayoría de casos |
| Alpha Vantage | Estándar | 500 req/día | Sí, con 1 check/hora |
| Hugging Face | Gratis | 30k req/mes | Sí |
| Gmail API | Gratis | 1B quotas/día | Sí |

**Tip**: Empieza gratis, escala cuando sea necesario.

### ¿Cómo sé si una API key está funcionando?

**Test en n8n:**
```
Credentials → Select credential → Test
```

**Test manual con curl:**
```bash
# OpenAI
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"

# Twitter
curl "https://api.twitter.com/2/tweets/search/recent?query=test" \
  -H "Authorization: Bearer $TWITTER_BEARER_TOKEN"
```

---

## Troubleshooting

### Workflow no se ejecuta

**Checklist:**
1. ☐ ¿Está activado? (toggle verde)
2. ☐ ¿Trigger configurado correctamente?
3. ☐ ¿Credenciales válidas?
4. ☐ ¿Sin errores en logs?
5. ☐ ¿Schedule en hora correcta?

**Debug:**
```bash
# Ver logs
docker-compose logs -f n8n

# Ver executions en UI
n8n UI → Executions → Filter by workflow
```

### Error "Connection timeout"

**Causas comunes:**
- API endpoint no responde
- Firewall bloqueando
- Rate limit excedido
- SSL certificate issue

**Soluciones:**
```javascript
// Aumentar timeout en nodo HTTP Request
timeout: 30000 // 30 segundos
```

```bash
# Test connectivity
ping api.example.com
curl -v https://api.example.com
```

### Base de datos desconectada

**Síntomas:**
- Workflows no inician
- Error "Connection refused"
- "ECONNREFUSED localhost:5432"

**Soluciones:**
```bash
# Verificar PostgreSQL
docker-compose ps postgres
docker-compose logs postgres

# Reiniciar
docker-compose restart postgres

# Verificar conexión
psql -h localhost -U postgres -d n8n
```

### Memory issues / Out of Memory

**Síntomas:**
- n8n se cuelga
- Ejecuciones muy lentas
- "JavaScript heap out of memory"

**Soluciones:**
```bash
# Aumentar memoria Node.js
export NODE_OPTIONS="--max-old-space-size=4096"

# O en docker-compose
environment:
  - NODE_OPTIONS=--max-old-space-size=4096

# Verificar uso
docker stats n8n
```

**Optimizaciones:**
```javascript
// Procesar en lotes
const BATCH_SIZE = 100;
for (let i = 0; i < items.length; i += BATCH_SIZE) {
  const batch = items.slice(i, i + BATCH_SIZE);
  // Procesar batch
}
```

### Webhook no responde

**Checklist:**
1. ☐ ¿Workflow activado?
2. ☐ ¿URL correcta?
3. ☐ ¿Puerto abierto en firewall?
4. ☐ ¿HTTPS configurado si es necesario?

**Debug:**
```bash
# Test webhook
curl -X POST http://localhost:5678/webhook/test \
  -H 'Content-Type: application/json' \
  -d '{"test": "data"}'

# Verificar logs
tail -f ~/.n8n/logs/webhook.log
```

---

## Costos

### ¿Cuánto cuesta operar esto?

**Costos variables (por mes):**

**Infraestructura:**
- VPS/Server: $5-50
- PostgreSQL (managed): $15-100
- Redis (managed): $10-50
- **Total infra**: $30-200/mes

**APIs (depende de uso):**
- OpenAI: $20-200
- Twitter: $0-100 (gratis o premium)
- Otros: $0-100
- **Total APIs**: $20-400/mes

**Total estimado: $50-600/mes** dependiendo de escala.

**Alternativa económica:**
- DigitalOcean Droplet $12/mes
- PostgreSQL self-hosted (gratis)
- APIs tier gratuito
- **Total**: ~$12/mes

### ¿Hay costos ocultos?

**Considera:**
- Bandwidth (generalmente incluido)
- Backups storage (~$5/mes)
- SSL certificate (gratis con Let's Encrypt)
- Email service (Sendgrid: $15/mes o gratis 100 emails/día)
- SMS/Phone notifications (si usas)

### ¿Es más barato que alternativas SaaS?

**Comparación:**

| Solución | Costo Mensual | Límites |
|----------|---------------|---------|
| **Este repo (self-hosted)** | $50-200 | Sin límites |
| Zapier | $20-600 | 750-50k tasks |
| Make (Integromat) | $9-300 | 10k-100k ops |
| n8n Cloud | $20-200 | 5k-100k executions |

**Break-even point**: ~5,000 tasks/mes

---

## Rendimiento

### ¿Cuántas ejecuciones soporta?

**Benchmarks (servidor 4 GB RAM, 2 vCPU):**
- Simple workflows: ~100/min
- Medium workflows: ~50/min
- Complex workflows: ~20/min

**Factores que afectan:**
- Complejidad de workflow
- Número de API calls
- Tamaño de datos procesados
- Base de datos performance

### ¿Cómo optimizar workflows lentos?

**Estrategias:**

1. **Procesamiento paralelo**:
   ```javascript
   // Usar Promise.all para APIs
   const results = await Promise.all([
     fetchTwitter(),
     fetchFacebook(),
     fetchInstagram()
   ]);
   ```

2. **Caching**:
   ```javascript
   // Cache responses comunes
   const cacheKey = `api:${endpoint}:${params}`;
   const cached = await redis.get(cacheKey);
   if (cached) return JSON.parse(cached);
   ```

3. **Paginación**:
   ```javascript
   // No cargar todo de una vez
   const PAGE_SIZE = 100;
   const page = $json.page || 1;
   const offset = (page - 1) * PAGE_SIZE;
   ```

4. **Indices de DB**:
   ```sql
   CREATE INDEX idx_timestamp ON tabla(timestamp DESC);
   ```

### ¿Necesito escalar horizontalmente?

**Señales de que sí:**
- CPU constante > 80%
- RAM constante > 85%
- Queue de ejecuciones creciente
- Timeouts frecuentes

**Opciones de escalado:**
1. **Vertical**: Más RAM/CPU
2. **Horizontal**: Múltiples workers
3. **Distributed**: Kubernetes cluster

```yaml
# Worker mode (horizontal)
services:
  n8n-main:
    command: n8n start
  n8n-worker-1:
    command: n8n worker
  n8n-worker-2:
    command: n8n worker
```

---

## Seguridad

### ¿Es seguro exponer n8n a internet?

**Solo con precauciones:**

✅ **Hacer:**
- HTTPS obligatorio
- Basic auth o JWT auth
- Firewall configurado
- Rate limiting
- Actualizar regularmente

❌ **No hacer:**
- HTTP sin TLS
- Sin autenticación
- Exponer Puerto PostgreSQL
- Usar passwords débiles

### ¿Debo preocuparme por inyección de código?

**n8n tiene protecciones**, pero:

**En Code nodes:**
```javascript
// ❌ PELIGRO
eval(userInput);
new Function(userInput)();

// ✅ SEGURO
const sanitized = userInput.replace(/[^a-zA-Z0-9]/g, '');
```

**En SQL:**
```javascript
// ❌ PELIGRO
`SELECT * FROM users WHERE email = '${userEmail}'`

// ✅ SEGURO (usar prepared statements)
db.query('SELECT * FROM users WHERE email = $1', [userEmail]);
```

### ¿Cómo proteger API keys?

**Best practices:**

1. **Variables de entorno**:
   ```env
   OPENAI_API_KEY=sk-proj-xxx
   ```

2. **n8n credentials (encriptadas)**

3. **Secrets managers** (producción):
   - AWS Secrets Manager
   - Google Secret Manager
   - HashiCorp Vault

4. **Rotación regular**:
   ```bash
   # Script de rotación (cada 90 días)
   0 0 1 */3 * /opt/n8n/scripts/rotate-keys.sh
   ```

### ¿Qué logs debo mantener?

**Esenciales:**
- Workflow executions (30 días)
- Error logs (90 días)
- Access logs (30 días)
- Audit logs (1 año)

**No loggear:**
- API keys completas
- Passwords
- Datos sensibles de clientes
- PII sin enmascarar

---

## Soporte

### ¿Dónde obtengo ayuda?

**Recursos oficiales:**
1. **Documentación**: [docs.n8n.io](https://docs.n8n.io)
2. **Community Forum**: [community.n8n.io](https://community.n8n.io)
3. **GitHub Issues**: Para bugs
4. **Discord**: Chat en tiempo real

**Para este repositorio:**
- **GitHub Issues**: [574.lat/issues](https://github.com/yourusername/574.lat/issues)
- **Discussions**: Para preguntas generales
- **Email**: support@574.lat

### ¿Ofrecen soporte comercial?

**Opciones:**
1. **n8n Enterprise**: Soporte oficial de n8n.io
2. **Freelance**: Contratar desarrollador n8n
3. **Agencias especializadas**: Implementación completa

**Costos típicos:**
- Consultoría: $100-200/hora
- Setup completo: $2,000-10,000
- Soporte mensual: $500-2,000

### ¿Puedo contribuir?

**¡Sí! Apreciamos:**
- 🐛 Bug reports
- ✨ Feature requests
- 📝 Documentación
- 💻 Pull requests
- 🌟 Stars en GitHub

**Guía de contribución:**
```bash
# Fork el repositorio
# Crear branch
git checkout -b feature/nueva-funcionalidad

# Hacer cambios y commit
git commit -m "Add: nueva funcionalidad"

# Push y crear PR
git push origin feature/nueva-funcionalidad
```

### ¿Con qué frecuencia se actualiza?

**Este repositorio:**
- Workflows: Trimestral
- Documentación: Mensual
- Bug fixes: Según necesidad
- Security patches: Inmediato

**n8n (upstream):**
- Releases: Semanal-quincenal
- Security updates: Prioritario

**Actualizar workflows:**
```bash
git pull origin main
# Revisar CHANGELOG
# Importar workflows actualizados
```

---

## Preguntas Adicionales

### ¿Funciona con mi país/idioma?

**Sí**, n8n es internacional:
- UI en múltiples idiomas
- Workflows funcionan globalmente
- APIs soportan internacionalización

**Consideraciones:**
- Timezone en `.env`: `GENERIC_TIMEZONE=America/Mexico_City`
- Formatos de fecha: Ajustar en workflows
- API limits pueden variar por región

### ¿Puedo vender servicios basados en esto?

**Sí**, el proyecto usa MIT License:
- ✅ Uso comercial permitido
- ✅ Modificación permitida
- ✅ Distribución permitida
- ⚠️ Sin garantía

**Respeta licenses de APIs de terceros.**

### ¿Hay una versión móvil?

**No nativa**, pero:
- n8n UI es responsive (funciona en navegador móvil)
- Puedes recibir notificaciones vía:
  - Email
  - Slack
  - Telegram
  - Push notifications (con integración)

### ¿Cuánto tiempo dura la configuración inicial?

**Timeline típico:**

**Día 1:**
- Setup infraestructura (4 horas)
- Configurar PostgreSQL (1 hora)
- Instalar n8n (1 hora)
- Total: 6 horas

**Día 2:**
- Obtener API keys (2 horas)
- Importar workflows (1 hora)
- Configurar credenciales (2 horas)
- Total: 5 horas

**Día 3:**
- Testing (3 horas)
- Ajustes (2 horas)
- Total: 5 horas

**Total: ~16 horas** para setup completo.

**Setup mínimo (1 workflow)**: 2-3 horas.

---

**¿No encontraste tu pregunta?**

Abre un issue en GitHub: [574.lat/issues](https://github.com/yourusername/574.lat/issues/new)

---

**Última Actualización**: 2025-11-11
