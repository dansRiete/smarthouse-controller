# SmartHouse AI Watchdog Service Architecture

This document outlines the architectural specifications, data flows, and configuration details for the database-driven, autonomous **AI Watchdog Service** running inside the Spring Boot central backend (`smarthouse-controller`).

## 1. Overview
The AI Watchdog is a unified, extensible framework that dynamically triggers automated "check-ups" on different parts of the smart home system. It fetches raw system states from customizable locations (either local database repositories or external HTTP endpoints), evaluates those states against natural language rule-templates using Google's **Gemini 1.5 Flash API**, and delivers Firebase Cloud Messaging (FCM) notifications to the user's phone if validation rules succeed or fail.

All configurations and execution logs are dynamically tracked inside a **PostgreSQL** database.

---

## 2. Database Schema Design

The watchdog service is entirely database-driven. You can add, adjust, or disable jobs at runtime by querying the PostgreSQL database.

### `main.watchdog_job`
Stores the configuration of each active AI check-up job.
* `id` (SERIAL PRIMARY KEY): Unique identifier.
* `name` (VARCHAR): Descriptive name of the verification check.
* `cron_expression` (VARCHAR): Standard 6-field cron expression matching execution schedules.
* `prompt_template` (TEXT): Detailed natural language instructions detailing validation criteria for Gemini.
* `state_url` (VARCHAR): The URI locating the target state (e.g. `http://...`, `db://...`, `sys://...`).
* `enabled` (BOOLEAN): Flag to enable/disable the recurring job.
* `created_at` / `updated_at` (TIMESTAMP).

### `main.watchdog_log`
Provides full historical audit logs of every execution.
* `id` (SERIAL PRIMARY KEY).
* `job_id` (INT REFERENCES watchdog_job(id)).
* `executed_at` (TIMESTAMP).
* `gathered_state` (TEXT): The raw JSON state captured at execution time.
* `ai_response` (TEXT): The raw JSON output returned by Gemini.
* `status` (VARCHAR): "SUCCESS", "ALERT", or "FAILURE".
* `notification_sent` (BOOLEAN).
* `error_message` (TEXT).

---

## 3. High-Level Class Diagrams & Packages

All watchdog logic resides inside the package: `com.alexsoft.smarthouse.watchdog` and related entity/repository directories.

```
smarthouse-controller/src/main/java/com/alexsoft/smarthouse/
├── entity/
│   ├── WatchdogJob.java              # JPA Entity
│   └── WatchdogLog.java              # JPA Entity
├── repository/
│   ├── WatchdogJobRepository.java    # JPA Repository
│   └── WatchdogLogRepository.java    # JPA Repository
├── service/
│   └── GeminiService.java            # Communicates with Google Gemini API
└── watchdog/
    ├── WatchdogScheduler.java        # Runs cron triggers every minute
    └── resolver/
        ├── StateResolver.java        # Unified resolution contract
        ├── StateResolutionService.java # Strategy executor
        ├── HttpStateResolver.java    # Handles http:// and https:// URIs
        └── DbStateResolver.java      # Handles db:// JPA repository queries
```

---

## 4. The Strategy Protocol Resolver Architecture

To avoid tightly coupling the scheduler to various subsystems, we utilize the **Strategy Pattern** to gather states.

```
       StateResolutionService (Registry Manager)
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
    [Http]      [Db]      [Sys]   (Strategy Implementations)
```

The system dynamically resolves the scheme prefix of `state_url`:
1. **HTTP Scheme (`http://`, `https://`)**: Makes a loopback HTTP GET request to local or external REST endpoints (like Node-RED `/probe`).
2. **Database Scheme (`db://`)**: Runs in-memory queries directly against Spring Boot JPA repositories (e.g., `db://appliance-metrics` calls `ApplianceRepository.findAll()`) and serializes entities to a clean JSON string, eliminating loopback network overhead.
3. **System Scheme (`sys://`)**: Gathers environment, CPU, memory, or local disk space statistics.

---

## 5. Security & Credentials
The Gemini API key is securely injected into the `GeminiService` using the standard Spring property:
`gemini.api-key`

This property is populated at runtime from the host's environment variable `GEMINI_API_KEY`, ensuring credentials are never exposed or checked into Git.
