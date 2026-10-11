# Deliverable 5 — Application Prototype

**Project:** AssetCare — Community Asset Lifecycle & Maintenance Intelligence System

---

## Overview

AssetCare is a **database-centric** prototype with two layers:

1. **Backend (the system of record)** — an Oracle 11g database: 12 tables in 3NF,
   16 indexes, CHECK/FOREIGN-KEY constraints, views, a PL/SQL procedure, three
   triggers, a risk-scoring function, sequences and role-based access.
2. **Frontend (the dashboard)** — `dashboard.html`, a visual dashboard that renders
   the database's analytics: key performance indicators, a predicted-failure-risk
   ranking, severity distribution, spend-by-asset, and open requests.

## How the frontend is driven by the database

Every figure on the dashboard is produced by a database object, not hand-written:

| Dashboard element | Database source |
|---|---|
| KPI cards (assets / faults / open requests / spend) | row counts + aggregate queries |
| Predicted failure risk table | `v_asset_health` → `fn_asset_risk_score()` |
| Severity distribution chart | `GROUP BY severity` over `Fault` |
| Spend-by-asset chart | `v_management_dashboard` (`total_labour + total_parts`) |
| Open requests table | `v_open_maintenance_requests` (`days_open`, technician) |

The same numbers appear when the equivalent SQL is run directly in SQL*Plus — the
dashboard is the presentation layer, the database is the source of truth.

## End-to-end workflow (user input → DB → output)

1. A **resident reports a fault** → `INSERT INTO Fault` (least-privilege `role_resident`).
2. The fault **raises a request** → `MaintenanceRequest`; a technician is assigned.
3. The technician **records the repair + parts** → `Repair` + `RepairHistory`; a trigger
   validates and decrements spare-part stock.
4. A stored procedure `complete_repair()` **cascades the closure** (Repair → Request →
   Fault → Asset status) in one atomic call.
5. An **audit trigger** logs every asset-status change to `Asset_Audit`.
6. The **risk-scoring function** re-ranks assets, and the **dashboard** surfaces the
   next asset to maintain — before it fails again.

## Evidence of a working solution

- Screenshots of the dashboard (KPIs, risk ranking, charts, open requests).
- SQL*Plus output showing the same views/queries returning identical data (joins,
  nested queries, transactions, triggers, role-based access).
