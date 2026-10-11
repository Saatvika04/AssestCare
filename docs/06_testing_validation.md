# Deliverable 6 — Testing & Validation

**Project:** AssetCare — Community Asset Lifecycle & Maintenance Intelligence System

Automated checks live in `test_checks.sql`. Scenario-based validation was performed by
running the three module scripts and the enhancement scripts against the seeded database.

---

## 1. Data-load validation (`test_checks.sql`)

| Check | Expected | Result |
|---|---|---|
| Row counts (types, locations, custodians, statuses, technicians) | 6/7/5/5/6 | PASS |
| Row counts (assets, inspections, faults, requests, repairs, history) | 13/15/12/12/9/10 | PASS |
| Frequently failing asset | `LIFT-BLK-A-01` = 3 | PASS |
| Recurring part failure | Lift Motor 15kW used 2× | PASS |
| Average repair duration | ~2.3 days (before CRUD) | PASS |
| Open (non-completed) requests | requests 6, 8, 12 | PASS |

## 2. Constraint rejection tests (negative testing)

Each of these **should** raise an error, proving constraints are enforced:

| Attempt | Rejected by | Oracle error |
|---|---|---|
| Insert fault referencing asset_id 999 | FK `fk_fault_asset` | ORA-02291 |
| Insert condition_rating = 9 | CHECK `chk_condition_rating` | ORA-02290 |
| Insert severity = 'Catastrophic' | CHECK `chk_severity` | ORA-02290 |

## 3. Trigger / business-rule tests (`procedures_triggers.sql`)

| Attempt | Rejected by | Error |
|---|---|---|
| Over-consume stock (quantity 999) | `trg_repair_history_stock` | ORA-20001 |
| Repair end_date before start_date | `trg_repair_date_check` | ORA-20002 |

## 4. Transaction test

- **Atomic COMMIT** — a repair + part consumption + status cascade applied together,
  all-or-nothing.
- **ROLLBACK** — decrementing spare-part stock inside a rolled-back transaction leaves the
  stock **unchanged** (verified before/after).

## 5. Realistic scenario walkthroughs (module scripts)

- **Scenario A — new fault lifecycle** (`02_maintenance_module.sql`): a resident reports a
  flickering gate light → fault logged → request raised → technician assigned → repair
  completed → part consumed → loop closed. Verified end-to-end.
- **Scenario B — recurring-failure detection** (`03_analytics.sql`): the lift's 3 faults and
  repeated motor usage are surfaced by `HAVING COUNT(*) > 1` and the risk-score view.
- **Scenario C — predictive maintenance** (`enhancements.sql`): `v_asset_health` ranks
  `LIFT-BLK-A-01` HIGH risk before a further failure occurs.

## 6. Security test (`security.sql`)

Logging in as `demo_resident` and attempting a `DELETE` or `UPDATE` on `Asset` is rejected
with `ORA-01031` (insufficient privileges) — proving least-privilege enforcement.

---

**Conclusion:** all positive, negative, transaction, trigger and security tests pass,
validating the prototype at TRL 4.
