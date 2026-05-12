# SmartHouse Backlog

Priority: **P1** = critical / blocking, **P2** = important, **P3** = nice to have

---

## Open

| # | Priority | Module | Title | Notes |
|---|----------|--------|-------|-------|
| 1 | P2 | controller | Switch `Appliance` from pessimistic to optimistic locking | Current `PESSIMISTIC_WRITE` on `findById` blocks Android PATCH requests for up to 3s while `powerControl()` (every 10s) holds the lock. Fix: add `@Version` to `Appliance`, remove `@Lock`/`@QueryHints` from `ApplianceRepository`, add 1-2 retry attempts on `OptimisticLockException` at call sites. |

---

## In Progress

_none_

---

## Done

_none_
