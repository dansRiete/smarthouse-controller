# SmartHouse Backlog

Priority: **P1** = critical / blocking, **P2** = important, **P3** = nice to have

---

## Open

| # | Priority | Module | Title | Notes |
|---|----------|--------|-------|-------|
| 1 | P2 | controller | Switch `Appliance` from pessimistic to optimistic locking | Current `PESSIMISTIC_WRITE` on `findById` blocks Android PATCH requests for up to 3s while `powerControl()` (every 10s) holds the lock. Fix: add `@Version` to `Appliance`, remove `@Lock`/`@QueryHints` from `ApplianceRepository`, add 1-2 retry attempts on `OptimisticLockException` at call sites. |
| 2 | P2 | controller / node-red | Migrate Climate Automation (AC, DEH, FAN) to Node-RED | Decouple automatic climate decisions from Spring Boot backend into Node-RED. Keeps backend as DB and REST API source of truth, but executes all hysteresis and duty-minute logic in Node-RED. Detailed design in [docs/climate_migration_plan.md](file:///home/alexkzk/IdeaProjects/SmartHouse/smarthouse-controller/docs/climate_migration_plan.md) |

---

## In Progress

_none_

---

## Done

_none_
