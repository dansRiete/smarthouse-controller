-- SmartHouse AI Watchdog Bootstrap SQL
-- You can execute this script directly in your Postgres client (connected to port 24870, DB 'smarthouse').
-- Note: Hibernate's ddl-auto: update will automatically create the tables, so you only need to run the INSERT statement.

-- ==========================================
-- 1. DDL Script for creating tables
-- ==========================================
CREATE TABLE IF NOT EXISTS main.watchdog_job (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    cron_expression VARCHAR(100) NOT NULL,
    prompt_template TEXT NOT NULL,
    state_url VARCHAR(512),
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS main.watchdog_log (
    id SERIAL PRIMARY KEY,
    job_id INT REFERENCES main.watchdog_job(id) ON DELETE CASCADE,
    executed_at TIMESTAMP NOT NULL DEFAULT NOW(),
    gathered_state TEXT,
    ai_response TEXT,
    status VARCHAR(50) NOT NULL,
    notification_sent BOOLEAN NOT NULL DEFAULT FALSE,
    error_message TEXT
);


-- ==========================================
-- 2. Insert TV LED Dim Verification Job
-- ==========================================
-- This registers the Watchdog job to run daily at 10:10 PM.
-- It points directly to your Node-RED `/probe` API to verify state,
-- parses the light levels using Gemini AI, and triggers FCM if validation rules are met.

INSERT INTO main.watchdog_job (name, cron_expression, prompt_template, state_url, enabled)
VALUES (
    'Night Light Dim Verification',
    '0 10 22 * * *', -- Spring Cron format: seconds minutes hours day-of-month month day-of-week
    'Evaluate the current smart house light states against these validation rules:
1. Is it night window? (last_is_night should be true).
2. Has the LED_UNDER_TV successfully turned ON with a brightness level of exactly 20?
3. Are all other bedroom light states (LED_OVER_BED, LED_OVER_TV) turned OFF?

If all rules pass and the bedroom is perfectly set up for night mode, output JSON with "shouldNotify" = true, "severity" = "silent", title="TV LED Dimmed", and body="The LED under TV successfully dimmed to 20. Bedroom night mode verified!"
If rules fail (e.g. brightness is not 20, or other lights are left ON), output JSON with "shouldNotify" = true, "severity" = "sound", title="Watchdog Alert: Bedroom Lights Anomaly", and details of the failure in the body.

Ensure the final JSON structure strictly contains:
- "shouldNotify": boolean
- "severity": "silent" | "sound" | "severe"
- "title": "string"
- "body": "string"',
    'http://192.168.0.201:31880/probe', -- Direct internal loopback to Node-RED probe
    TRUE
)
ON CONFLICT DO NOTHING;
