# Deliverable 7 — Impact & TRL Report

**Project:** AssetCare — Community Asset Lifecycle & Maintenance Intelligence System

---

## Societal impact (measurable / defensible)

| Outcome | How AssetCare delivers it | Evidence in our data |
|---|---|---|
| **Safety** | safety-critical assets (lifts, ramps) auto-flagged HIGH risk | `RAMP-COM-01` "handrail broken, unsafe" (Critical) |
| **Reduced downtime** | open requests tracked by age, unassigned work surfaced | `v_open_maintenance_requests` (days_open 21–50) |
| **Lower cost** | proactive maintenance beats emergency repair | `LIFT-BLK-A-01` = ₹1,20,900 from 3 failures |
| **Budget predictability** | cost-per-asset + risk ranking | `v_management_dashboard` total_spend per asset |
| **Longer asset life** | recurring part-failure detected after first repeat | Lift Motor 15kW used 2× on same lift |
| **Accountability** | full audit trail of status changes | `Asset_Audit` table + `trg_asset_audit` |

## TRL justification

**Target: TRL 4 (working prototype, validated in a controlled environment), reaching toward TRL 5.**

- **TRL 3 (proof of concept)** — exceeded: a complete 12-table, 3NF database is
  implemented, populated with 100+ rows of realistic data, and exercises the full
  lifecycle workflow end-to-end.
- **TRL 4** — met: the prototype is validated against realistic scenarios (recurring-failure
  detection, unassigned/overdue request reporting, transaction atomicity, trigger-enforced
  business rules, role-based access).
- **TRL 5** — the design is *ready* for validation with real users/locations; our dataset
  mirrors a real campus, but external deployment is not yet performed.

## Scalability & deployment roadmap

1. **Application layer** — expose the database through Oracle APEX (bundled with Oracle XE)
   for login-protected dashboards and CRUD forms.
2. **IoT integration** — sensors auto-populate `condition_rating` and trigger faults
   directly (removes manual inspection lag).
3. **Machine learning** — train a failure classifier on accumulated `Fault` history to
   replace/augment the rule-based risk score.
4. **GIS** — plot assets on a campus map using the `Location` table.
5. **Multi-society deployment** — add a `community_id` dimension to scale from one campus
   to many, with role-based tenants.
