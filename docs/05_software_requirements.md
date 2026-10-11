# Deliverable 3 — Software Requirements

**Project:** AssetCare — Community Asset Lifecycle & Maintenance Intelligence System

---

## Stakeholders

| Stakeholder | Needs |
|---|---|
| Residents | report a fault quickly; know a fault is being handled |
| Facility managers / custodians | see asset status, schedule maintenance, control budget |
| Technicians | see assigned work, record repairs and parts used |
| Management / administration | read-only dashboards and analytics |

## Functional requirements

| # | Requirement | Implemented by |
|---|---|---|
| FR1 | Maintain the asset registry (CRUD) | `Asset`, `queries/01_asset_module.sql` |
| FR2 | Record inspections and condition ratings | `Inspection` |
| FR3 | Log faults and raise maintenance requests | `Fault`, `MaintenanceRequest` |
| FR4 | Assign technicians and record repairs | `Repair`, `queries/02_maintenance_module.sql` |
| FR5 | Track spare parts and stock | `SparePart`, `RepairHistory` |
| FR6 | Report open/overdue/unassigned work | `v_open_maintenance_requests` |
| FR7 | Recurring-failure & predictive-risk analytics | `fn_asset_risk_score`, `v_asset_health` |
| FR8 | Management dashboard (cost, condition, fault count) | `v_management_dashboard` |
| FR9 | One-call repair completion with status cascade | `complete_repair` procedure |
| FR10 | Enforce stock and date rules automatically | `trg_repair_history_stock`, `trg_repair_date_check` |
| FR11 | Audit every asset-status change | `trg_asset_audit`, `Asset_Audit` |
| FR12 | Role-based, least-privilege access | `security.sql` |

## Non-functional requirements

| Category | Requirement | How satisfied |
|---|---|---|
| **Data integrity** | reject invalid severity/rating/status | `CHECK` constraints |
| **Referential integrity** | no orphan rows | `FOREIGN KEY` constraints |
| **Performance** | fast joins/filters | 16 explicit indexes on FKs & filter columns |
| **Consistency** | all-or-nothing multi-step updates | transactions (`COMMIT` / `ROLLBACK`) |
| **Security** | least-privilege roles | `role_asset_manager` / `_technician` / `_resident` / `_reporting` |
| **Auditability** | trace who changed what, when | `Asset_Audit` + `trg_asset_audit` |
| **Portability** | run on any Oracle 11g+ instance | plain NUMBER PKs, no version-specific IDENTITY |
