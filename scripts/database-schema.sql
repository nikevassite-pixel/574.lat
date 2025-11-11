-- n8n Automation Workflows Database Schema
-- PostgreSQL 13+
-- Created: 2025-11-11
-- Purpose: Complete database schema for all n8n workflows

-- ============================================================================
-- 1. INVENTORY MANAGEMENT
-- ============================================================================

-- Inventory table for e-commerce sync workflow
CREATE TABLE IF NOT EXISTS inventory (
    id SERIAL PRIMARY KEY,
    product_id VARCHAR(255) NOT NULL,
    sku VARCHAR(255) UNIQUE NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    warehouse_location VARCHAR(255),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_inventory_sku ON inventory(sku);
CREATE INDEX idx_inventory_product_id ON inventory(product_id);

-- Inventory sync log table
CREATE TABLE IF NOT EXISTS inventory_sync_log (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(255) NOT NULL,
    platform VARCHAR(50) NOT NULL,
    previous_stock INTEGER,
    new_stock INTEGER NOT NULL,
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'completed',
    error_message TEXT,
    UNIQUE(sku, platform, synced_at)
);

CREATE INDEX idx_sync_log_sku ON inventory_sync_log(sku);
CREATE INDEX idx_sync_log_platform ON inventory_sync_log(platform);
CREATE INDEX idx_sync_log_date ON inventory_sync_log(synced_at DESC);

-- ============================================================================
-- 2. CONTENT GENERATION PIPELINE
-- ============================================================================

-- Content pipeline tracking table
CREATE TABLE IF NOT EXISTS content_pipeline (
    id SERIAL PRIMARY KEY,
    original_url VARCHAR(500),
    original_title VARCHAR(500),
    generated_headline VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    meta_description VARCHAR(255),
    wordpress_post_id VARCHAR(100),
    medium_post_id VARCHAR(100),
    status VARCHAR(50) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP
);

CREATE INDEX idx_content_status ON content_pipeline(status);
CREATE INDEX idx_content_created ON content_pipeline(created_at DESC);

-- ============================================================================
-- 3. CUSTOMER SUPPORT SYSTEM
-- ============================================================================

-- Support tickets log table
CREATE TABLE IF NOT EXISTS support_tickets_log (
    id SERIAL PRIMARY KEY,
    email_id VARCHAR(255) UNIQUE NOT NULL,
    sender_email VARCHAR(255) NOT NULL,
    subject VARCHAR(500),
    category VARCHAR(100),
    category_confidence DECIMAL(5,4),
    sentiment VARCHAR(50),
    sentiment_score DECIMAL(5,4),
    priority VARCHAR(20),
    zendesk_ticket_id VARCHAR(100),
    auto_response_sent BOOLEAN DEFAULT false,
    escalated BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tickets_email ON support_tickets_log(sender_email);
CREATE INDEX idx_tickets_category ON support_tickets_log(category);
CREATE INDEX idx_tickets_priority ON support_tickets_log(priority);
CREATE INDEX idx_tickets_created ON support_tickets_log(created_at DESC);

-- ============================================================================
-- 4. FINANCIAL DATA AGGREGATION
-- ============================================================================

-- Financial data table
CREATE TABLE IF NOT EXISTS financial_data (
    id SERIAL PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL,
    source VARCHAR(50) NOT NULL,
    current_price DECIMAL(15,6),
    change_percent DECIMAL(8,4),
    volume BIGINT,
    market_cap DECIMAL(20,2),
    data_json JSONB,
    timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_financial_symbol ON financial_data(symbol);
CREATE INDEX idx_financial_source ON financial_data(source);
CREATE INDEX idx_financial_timestamp ON financial_data(timestamp DESC);
CREATE INDEX idx_financial_data_json ON financial_data USING GIN (data_json);

-- Financial alerts table
CREATE TABLE IF NOT EXISTS financial_alerts (
    id SERIAL PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL,
    alert_type VARCHAR(50),
    severity VARCHAR(20),
    message TEXT,
    triggered_value DECIMAL(15,6),
    threshold_value DECIMAL(15,6),
    notified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_alerts_symbol ON financial_alerts(symbol);
CREATE INDEX idx_alerts_severity ON financial_alerts(severity);
CREATE INDEX idx_alerts_notified ON financial_alerts(notified);

-- ============================================================================
-- 5. IOT DEVICE MONITORING
-- ============================================================================

-- IoT sensor data table
CREATE TABLE IF NOT EXISTS iot_sensor_data (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    category VARCHAR(100),
    temperature DECIMAL(6,2),
    humidity DECIMAL(5,2),
    pressure DECIMAL(7,2),
    battery_level DECIMAL(5,2),
    signal_strength INTEGER,
    status VARCHAR(50),
    alerts_count INTEGER DEFAULT 0,
    timestamp TIMESTAMP NOT NULL,
    received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_iot_device ON iot_sensor_data(device_id);
CREATE INDEX idx_iot_location ON iot_sensor_data(location);
CREATE INDEX idx_iot_timestamp ON iot_sensor_data(timestamp DESC);
CREATE INDEX idx_iot_status ON iot_sensor_data(status);

-- IoT alerts table
CREATE TABLE IF NOT EXISTS iot_alerts (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    alert_type VARCHAR(100),
    severity VARCHAR(20),
    metric VARCHAR(50),
    value DECIMAL(10,2),
    threshold DECIMAL(10,2),
    message TEXT,
    acknowledged BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_iot_alerts_device ON iot_alerts(device_id);
CREATE INDEX idx_iot_alerts_severity ON iot_alerts(severity);
CREATE INDEX idx_iot_alerts_acknowledged ON iot_alerts(acknowledged);

-- ============================================================================
-- 6. PROJECT MANAGEMENT SYNC
-- ============================================================================

-- Task sync state table
CREATE TABLE IF NOT EXISTS task_sync_state (
    id SERIAL PRIMARY KEY,
    external_id VARCHAR(255) NOT NULL,
    source VARCHAR(50) NOT NULL,
    title VARCHAR(500),
    description TEXT,
    status VARCHAR(50),
    due_date DATE,
    sync_hash VARCHAR(32),
    last_modified TIMESTAMP,
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(external_id, source)
);

CREATE INDEX idx_task_sync_external_id ON task_sync_state(external_id);
CREATE INDEX idx_task_sync_source ON task_sync_state(source);
CREATE INDEX idx_task_sync_hash ON task_sync_state(sync_hash);

-- Task sync conflicts table
CREATE TABLE IF NOT EXISTS task_sync_conflicts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500),
    sources TEXT[],
    resolution_strategy VARCHAR(50),
    selected_source VARCHAR(50),
    resolved BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_conflicts_resolved ON task_sync_conflicts(resolved);

-- ============================================================================
-- 7. CHATBOT INTERACTIONS
-- ============================================================================

-- Chatbot interactions log
CREATE TABLE IF NOT EXISTS chatbot_interactions (
    id SERIAL PRIMARY KEY,
    platform VARCHAR(50) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    username VARCHAR(255),
    chat_id VARCHAR(255) NOT NULL,
    message_text TEXT,
    is_command BOOLEAN DEFAULT false,
    command VARCHAR(100),
    response_text TEXT,
    ai_processed BOOLEAN DEFAULT false,
    timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chatbot_platform ON chatbot_interactions(platform);
CREATE INDEX idx_chatbot_user ON chatbot_interactions(user_id);
CREATE INDEX idx_chatbot_timestamp ON chatbot_interactions(timestamp DESC);
CREATE INDEX idx_chatbot_command ON chatbot_interactions(command) WHERE command IS NOT NULL;

-- Chatbot user preferences
CREATE TABLE IF NOT EXISTS chatbot_user_preferences (
    id SERIAL PRIMARY KEY,
    platform VARCHAR(50) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    preferences JSONB,
    notification_enabled BOOLEAN DEFAULT true,
    language VARCHAR(10) DEFAULT 'en',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(platform, user_id)
);

CREATE INDEX idx_user_prefs ON chatbot_user_preferences(platform, user_id);

-- ============================================================================
-- 8. SOCIAL MEDIA ANALYTICS
-- ============================================================================

-- Social media metrics table
CREATE TABLE IF NOT EXISTS social_media_metrics (
    id SERIAL PRIMARY KEY,
    platform VARCHAR(50) NOT NULL,
    metric_type VARCHAR(100),
    metric_value DECIMAL(15,2),
    engagement_rate DECIMAL(8,4),
    timestamp TIMESTAMP NOT NULL,
    data_json JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_social_platform ON social_media_metrics(platform);
CREATE INDEX idx_social_timestamp ON social_media_metrics(timestamp DESC);
CREATE INDEX idx_social_data ON social_media_metrics USING GIN (data_json);

-- ============================================================================
-- 9. WORKFLOW EXECUTION LOGS
-- ============================================================================

-- General workflow execution log
CREATE TABLE IF NOT EXISTS workflow_execution_log (
    id SERIAL PRIMARY KEY,
    workflow_name VARCHAR(255) NOT NULL,
    execution_id VARCHAR(255),
    status VARCHAR(50),
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    duration_seconds INTEGER,
    error_message TEXT,
    items_processed INTEGER DEFAULT 0,
    metadata JSONB
);

CREATE INDEX idx_workflow_name ON workflow_execution_log(workflow_name);
CREATE INDEX idx_workflow_status ON workflow_execution_log(status);
CREATE INDEX idx_workflow_started ON workflow_execution_log(started_at DESC);

-- ============================================================================
-- 10. SYSTEM CONFIGURATION
-- ============================================================================

-- Configuration table for workflow settings
CREATE TABLE IF NOT EXISTS workflow_config (
    id SERIAL PRIMARY KEY,
    workflow_name VARCHAR(255) UNIQUE NOT NULL,
    config_json JSONB NOT NULL,
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_config_workflow ON workflow_config(workflow_name);
CREATE INDEX idx_config_enabled ON workflow_config(enabled);

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View for recent workflow executions
CREATE OR REPLACE VIEW recent_workflow_executions AS
SELECT
    workflow_name,
    status,
    started_at,
    duration_seconds,
    items_processed,
    error_message
FROM workflow_execution_log
WHERE started_at > CURRENT_TIMESTAMP - INTERVAL '24 hours'
ORDER BY started_at DESC;

-- View for active alerts
CREATE OR REPLACE VIEW active_alerts AS
SELECT
    'iot' as source,
    device_id as entity_id,
    alert_type,
    severity,
    message,
    created_at
FROM iot_alerts
WHERE acknowledged = false
UNION ALL
SELECT
    'financial' as source,
    symbol as entity_id,
    alert_type,
    severity,
    message,
    created_at
FROM financial_alerts
WHERE notified = false
ORDER BY created_at DESC;

-- View for chatbot activity summary
CREATE OR REPLACE VIEW chatbot_activity_summary AS
SELECT
    platform,
    DATE(timestamp) as activity_date,
    COUNT(*) as total_interactions,
    COUNT(CASE WHEN is_command THEN 1 END) as command_count,
    COUNT(CASE WHEN ai_processed THEN 1 END) as ai_processed_count,
    COUNT(DISTINCT user_id) as unique_users
FROM chatbot_interactions
GROUP BY platform, DATE(timestamp)
ORDER BY activity_date DESC;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to workflow_config
CREATE TRIGGER update_workflow_config_updated_at
    BEFORE UPDATE ON workflow_config
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to chatbot_user_preferences
CREATE TRIGGER update_chatbot_prefs_updated_at
    BEFORE UPDATE ON chatbot_user_preferences
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function to clean old logs (retention: 90 days)
CREATE OR REPLACE FUNCTION cleanup_old_logs()
RETURNS void AS $$
BEGIN
    DELETE FROM workflow_execution_log
    WHERE started_at < CURRENT_TIMESTAMP - INTERVAL '90 days';

    DELETE FROM chatbot_interactions
    WHERE timestamp < CURRENT_TIMESTAMP - INTERVAL '90 days';

    DELETE FROM inventory_sync_log
    WHERE synced_at < CURRENT_TIMESTAMP - INTERVAL '90 days';

    DELETE FROM support_tickets_log
    WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '180 days';

    RAISE NOTICE 'Old logs cleaned up successfully';
END;
$$ LANGUAGE plpgsql;

-- Function to get workflow statistics
CREATE OR REPLACE FUNCTION get_workflow_stats(workflow VARCHAR)
RETURNS TABLE (
    total_executions BIGINT,
    success_count BIGINT,
    failure_count BIGINT,
    avg_duration NUMERIC,
    last_execution TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*) as total_executions,
        COUNT(CASE WHEN status = 'success' THEN 1 END) as success_count,
        COUNT(CASE WHEN status = 'error' THEN 1 END) as failure_count,
        ROUND(AVG(duration_seconds)::numeric, 2) as avg_duration,
        MAX(started_at) as last_execution
    FROM workflow_execution_log
    WHERE workflow_name = workflow
        AND started_at > CURRENT_TIMESTAMP - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- INITIAL DATA
-- ============================================================================

-- Insert default workflow configurations
INSERT INTO workflow_config (workflow_name, config_json, enabled) VALUES
    ('social-media-analytics', '{"schedule": "0 */6 * * *", "platforms": ["twitter", "facebook", "instagram"]}', true),
    ('content-generation', '{"schedule": "0 */4 * * *", "auto_publish": false}', true),
    ('inventory-sync', '{"schedule": "*/15 * * * *", "low_stock_threshold": 10}', true),
    ('customer-support', '{"auto_response": true, "escalation_threshold": 0.8}', true),
    ('financial-data', '{"schedule": "0 * * * *", "alert_threshold_percent": 5}', true),
    ('iot-monitoring', '{"realtime": true, "alert_on_critical": true}', true),
    ('task-sync', '{"schedule": "*/5 * * * *", "conflict_resolution": "most_recent"}', true),
    ('chatbot', '{"realtime": true, "ai_enabled": true}', true)
ON CONFLICT (workflow_name) DO NOTHING;

-- ============================================================================
-- PERMISSIONS
-- ============================================================================

-- Grant permissions (adjust for your user)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO n8n_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO n8n_user;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO n8n_user;

-- ============================================================================
-- MAINTENANCE
-- ============================================================================

-- Analyze tables for query optimization
ANALYZE;

-- Create scheduled job for cleanup (requires pg_cron extension)
-- SELECT cron.schedule('cleanup-old-logs', '0 2 * * 0', 'SELECT cleanup_old_logs();');

COMMENT ON TABLE inventory IS 'Stores current inventory levels for e-commerce sync';
COMMENT ON TABLE content_pipeline IS 'Tracks AI-generated content through publication pipeline';
COMMENT ON TABLE support_tickets_log IS 'Logs all customer support ticket interactions';
COMMENT ON TABLE financial_data IS 'Historical financial market data';
COMMENT ON TABLE iot_sensor_data IS 'IoT device sensor readings and metrics';
COMMENT ON TABLE task_sync_state IS 'Project management task synchronization state';
COMMENT ON TABLE chatbot_interactions IS 'Complete log of chatbot conversations';
COMMENT ON TABLE workflow_execution_log IS 'Execution history for all workflows';

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================

-- Verification query
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
