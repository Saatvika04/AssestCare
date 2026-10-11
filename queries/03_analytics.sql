-- ============================================================================
-- Module 3 — Database Design & Analytics (Sharan Pillai)  [Oracle 11g+]
-- Covers: cross-module joins, recurring-failure analytics, nested queries,
--         and reference-data/integration CRUD.
-- Run after schema.sql + seed.sql.
-- ============================================================================

-- ============================================================================
-- 1. CROSS-MODULE JOINS
-- ============================================================================

-- 1a. Full lifecycle trace of a single asset (the recurring-failure lift)
--     flattens Asset → Inspection → Fault → Request → Repair → Parts → Technician
SELECT a.asset_code, a.asset_name,
       i.inspection_date, i.condition_rating,
       f.fault_id, f.description AS fault_desc, f.severity,
       r.request_id, r.request_status,
       rep.repair_id, rep.outcome,
       t.full_name AS technician,
       sp.part_name
FROM Asset a
LEFT JOIN Inspection         i   ON a.asset_id       = i.asset_id
LEFT JOIN Fault              f   ON a.asset_id       = f.asset_id
LEFT JOIN MaintenanceRequest r   ON f.fault_id       = r.fault_id
LEFT JOIN Repair             rep ON r.request_id     = rep.request_id
LEFT JOIN Technician         t   ON rep.technician_id = t.technician_id
LEFT JOIN RepairHistory      rh  ON rep.repair_id    = rh.repair_id
LEFT JOIN SparePart          sp  ON rh.part_id       = sp.part_id
WHERE a.asset_id = 1
ORDER BY i.inspection_date, f.reported_date, rep.repair_id;

-- 1b. Maintenance summary per asset using scalar subqueries (no row duplication)
SELECT a.asset_code, a.asset_name,
       (SELECT COUNT(*) FROM Fault f WHERE f.asset_id = a.asset_id) AS fault_count,
       (SELECT COUNT(*)
          FROM Repair rep
          JOIN MaintenanceRequest r ON rep.request_id = r.request_id
          JOIN Fault f             ON r.fault_id     = f.fault_id
          WHERE f.asset_id = a.asset_id) AS repair_count,
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
          WHERE f.asset_id = a.asset_id) AS total_parts
FROM Asset a
ORDER BY fault_count DESC, total_labour DESC;

-- ============================================================================
-- 2. RECURRING-FAILURE ANALYTICS (aggregate)
-- ============================================================================

-- 2a. Frequently failing assets — fault count per asset, ranked
SELECT a.asset_code, a.asset_name, COUNT(f.fault_id) AS fault_count
FROM Asset a
LEFT JOIN Fault f ON a.asset_id = f.asset_id
GROUP BY a.asset_code, a.asset_name
ORDER BY fault_count DESC, a.asset_code;

-- 2b. Repairs performed per asset
SELECT a.asset_code, COUNT(rep.repair_id) AS repair_count
FROM Asset a
LEFT JOIN Fault f              ON a.asset_id   = f.asset_id
LEFT JOIN MaintenanceRequest r ON f.fault_id   = r.fault_id
LEFT JOIN Repair rep           ON r.request_id = rep.request_id
GROUP BY a.asset_code
ORDER BY repair_count DESC;

-- 2c. Recurring part failures — same part used more than once on the same asset
SELECT a.asset_code, sp.part_name,
       COUNT(*)              AS times_used,
       SUM(rh.quantity_used) AS total_qty
FROM RepairHistory rh
JOIN Repair             rep ON rh.repair_id    = rep.repair_id
JOIN MaintenanceRequest r   ON rep.request_id  = r.request_id
JOIN Fault              f   ON r.fault_id      = f.fault_id
JOIN Asset              a   ON f.asset_id      = a.asset_id
JOIN SparePart          sp  ON rh.part_id      = sp.part_id
GROUP BY a.asset_code, sp.part_name
HAVING COUNT(*) > 1
ORDER BY times_used DESC;

-- 2d. Fault severity distribution
SELECT f.severity, COUNT(*) AS fault_count
FROM Fault f
GROUP BY f.severity
ORDER BY fault_count DESC;

-- 2e. Faults reported per month (maintenance demand trend)
SELECT TO_CHAR(f.reported_date, 'YYYY-MM') AS month, COUNT(*) AS faults
FROM Fault f
GROUP BY TO_CHAR(f.reported_date, 'YYYY-MM')
ORDER BY month;

-- ============================================================================
-- 3. NESTED QUERIES — assets above the average failure rate / spend
-- ============================================================================

-- 3a. Assets with an above-average number of faults
SELECT a.asset_code, COUNT(f.fault_id) AS fault_count
FROM Asset a
LEFT JOIN Fault f ON a.asset_id = f.asset_id
GROUP BY a.asset_code
HAVING COUNT(f.fault_id) > (
        SELECT AVG(fault_count)
        FROM (
            SELECT COUNT(*) AS fault_count
            FROM Fault
            GROUP BY asset_id
        ) fc
      )
ORDER BY fault_count DESC;

-- 3b. Assets whose total labour spend is above the average per-asset spend
SELECT a.asset_code, SUM(rep.labour_cost) AS total_labour
FROM Asset a
JOIN Fault              f   ON a.asset_id   = f.asset_id
JOIN MaintenanceRequest r   ON f.fault_id   = r.fault_id
JOIN Repair             rep ON r.request_id = rep.request_id
GROUP BY a.asset_code
HAVING SUM(rep.labour_cost) > (
        SELECT AVG(total)
        FROM (
            SELECT SUM(rep2.labour_cost) AS total
            FROM Asset a2
            JOIN Fault              f2   ON a2.asset_id   = f2.asset_id
            JOIN MaintenanceRequest r2   ON f2.fault_id   = r2.fault_id
            JOIN Repair             rep2 ON r2.request_id = rep2.request_id
            GROUP BY a2.asset_id
        ) t
      )
ORDER BY total_labour DESC;

-- ============================================================================
-- 4. REFERENCE DATA & INTEGRATION SUPPORT (CRUD)
-- ============================================================================

-- 4a. Add a new asset type (reference data)
INSERT INTO AssetType (asset_type_id, type_name, category, expected_life_years, inspection_interval_days)
VALUES (7, 'Solar Panel Array', 'Electrical', 25, 180);

-- 4b. Add a new asset status (reference data)
INSERT INTO AssetStatus (status_id, status_name, description)
VALUES (6, 'Under Warranty', 'New asset still covered by vendor warranty');

-- 4c. Add a new technician (reference data)
INSERT INTO Technician (technician_id, full_name, specialization, phone, email, is_available)
VALUES (7, 'Divya Sharma', 'Electrical', '9001070707', 'divya.s@vit.ac.in', 1);

-- 4d. Verify the new reference rows are usable by the modules
SELECT type_name, category FROM AssetType    WHERE asset_type_id = 7;
SELECT status_name           FROM AssetStatus WHERE status_id     = 6;
SELECT full_name, specialization FROM Technician WHERE technician_id = 7;
