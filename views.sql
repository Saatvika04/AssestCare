-- ============================================================================
-- AssetCare — Views (one per module, per the fairness table)  [Oracle 11g+]
--   v_asset_condition_summary   → Deepak  (asset condition)
--   v_open_maintenance_requests → Saatvika (open requests)
--   v_management_dashboard      → Sharan  (management dashboard)
-- Run after schema.sql + seed.sql.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View 1 — Asset condition summary (Deepak)
-- Latest inspection date + rating per asset, joined with its lookup tables.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_asset_condition_summary AS
SELECT a.asset_id, a.asset_code, a.asset_name,
       t.type_name, l.building, s.status_name,
       (SELECT MAX(i.inspection_date)
          FROM Inspection i
          WHERE i.asset_id = a.asset_id) AS last_inspection,
       (SELECT MAX(i.condition_rating) KEEP (DENSE_RANK LAST ORDER BY i.inspection_date)
          FROM Inspection i
          WHERE i.asset_id = a.asset_id) AS latest_rating
FROM Asset a
JOIN AssetType   t ON a.asset_type_id = t.asset_type_id
JOIN Location    l ON a.location_id   = l.location_id
JOIN AssetStatus s ON a.status_id     = s.status_id;

-- ----------------------------------------------------------------------------
-- View 2 — Open maintenance requests (Saatvika)
-- Every request not yet completed, with fault/asset context and days open.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_open_maintenance_requests AS
SELECT r.request_id, r.request_date, r.priority, r.request_status,
       a.asset_code, a.asset_name, f.description, f.severity,
       COALESCE(t.full_name, '(unassigned)') AS technician,
       (TRUNC(SYSDATE) - r.request_date)     AS days_open
FROM MaintenanceRequest r
JOIN Fault          f ON r.fault_id      = f.fault_id
JOIN Asset          a ON f.asset_id      = a.asset_id
LEFT JOIN Technician t ON r.technician_id = t.technician_id
WHERE r.request_status <> 'Completed';

-- ----------------------------------------------------------------------------
-- View 3 — Management dashboard (Sharan)
-- Per-asset fault count, maintenance spend (labour + parts) and avg condition.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_management_dashboard AS
SELECT a.asset_code, a.asset_name, t.type_name, s.status_name,
       (SELECT COUNT(*) FROM Fault f WHERE f.asset_id = a.asset_id) AS fault_count,
       (SELECT COALESCE(SUM(rep.labour_cost), 0)
          FROM Repair rep
          JOIN MaintenanceRequest r ON rep.request_id = r.request_id
          JOIN Fault f             ON r.fault_id     = f.fault_id
          WHERE f.asset_id = a.asset_id) AS total_labour,
       (SELECT COALESCE(SUM(rh.quantity_used * rh.unit_cost_at_repair), 0)
          FROM RepairHistory rh
          JOIN Repair rep           ON rh.repair_id    = rep.repair_id
          JOIN MaintenanceRequest r ON rep.request_id  = r.request_id
          JOIN Fault f              ON r.fault_id      = f.fault_id
          WHERE f.asset_id = a.asset_id) AS total_parts,
       (SELECT ROUND(AVG(i.condition_rating), 2)
          FROM Inspection i
          WHERE i.asset_id = a.asset_id) AS avg_condition
FROM Asset a
JOIN AssetType   t ON a.asset_type_id = t.asset_type_id
JOIN AssetStatus s ON a.status_id     = s.status_id;

-- ============================================================================
-- Demonstrate the views are queryable like ordinary tables
-- ============================================================================

-- Assets in poor condition (rating 2 or below), for follow-up
SELECT asset_code, asset_name, type_name, building, last_inspection, latest_rating
FROM v_asset_condition_summary
WHERE latest_rating <= 2
ORDER BY latest_rating;

-- Open requests sorted by how long they have been waiting
SELECT request_id, asset_code, description, severity, technician, days_open
FROM v_open_maintenance_requests
ORDER BY days_open DESC;

-- Dashboard: assets ordered by fault count, showing total maintenance cost
SELECT asset_code, asset_name, type_name, fault_count,
       total_labour + total_parts AS total_spend,
       avg_condition
FROM v_management_dashboard
ORDER BY fault_count DESC, total_spend DESC;
