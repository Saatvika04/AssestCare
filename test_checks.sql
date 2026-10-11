-- ============================================================================
-- AssetCare — Verification / test queries  [Oracle 11g+]
--
-- RUN ORDER (fresh schema, in this order):
--   1. schema.sql
--   2. seed.sql
--   3. test_checks.sql   (this file)
--   Then, for the demos: queries/01_asset_module.sql, queries/02_maintenance_module.sql,
--        queries/03_analytics.sql, views.sql, procedures_triggers.sql
--
-- Each check prints one number or row set; the expected value is in the comment
-- above it so you can eyeball pass/fail in one glance.
-- ============================================================================

-- ---------------------------------------------------------------- 1. ROW COUNTS
-- Expect 6 asset types, 7 locations, 5 custodians, 5 statuses, 6 technicians
SELECT 'AssetType' AS tbl, COUNT(*) AS rows_ FROM AssetType;
SELECT 'Location'  AS tbl, COUNT(*) AS rows_ FROM Location;
SELECT 'Custodian' AS tbl, COUNT(*) AS rows_ FROM Custodian;
SELECT 'AssetStatus' AS tbl, COUNT(*) AS rows_ FROM AssetStatus;
SELECT 'Technician' AS tbl, COUNT(*) AS rows_ FROM Technician;
SELECT 'SparePart' AS tbl, COUNT(*) AS rows_ FROM SparePart;

-- Expect 13 assets, 15 inspections, 12 faults, 12 requests, 9 repairs, 10 parts rows
SELECT 'Asset' AS tbl, COUNT(*) AS rows_ FROM Asset;
SELECT 'Inspection' AS tbl, COUNT(*) AS rows_ FROM Inspection;
SELECT 'Fault' AS tbl, COUNT(*) AS rows_ FROM Fault;
SELECT 'MaintenanceRequest' AS tbl, COUNT(*) AS rows_ FROM MaintenanceRequest;
SELECT 'Repair' AS tbl, COUNT(*) AS rows_ FROM Repair;
SELECT 'RepairHistory' AS tbl, COUNT(*) AS rows_ FROM RepairHistory;

-- ---------------------------------------------------------------- 2. KEY REPORTS
-- 2a. Frequently failing asset: expect LIFT-BLK-A-01 at the top with fault_count = 3
SELECT a.asset_code, COUNT(f.fault_id) AS fault_count
FROM Asset a
LEFT JOIN Fault f ON a.asset_id = f.asset_id
GROUP BY a.asset_code
ORDER BY fault_count DESC;

-- 2b. Recurring part failure: expect LIFT-BLK-A-01 / Lift Motor 15kW with times_used = 2
SELECT a.asset_code, sp.part_name, COUNT(*) AS times_used
FROM RepairHistory rh
JOIN Repair rep          ON rh.repair_id    = rep.repair_id
JOIN MaintenanceRequest r ON rep.request_id = r.request_id
JOIN Fault f             ON r.fault_id      = f.fault_id
JOIN Asset a             ON f.asset_id      = a.asset_id
JOIN SparePart sp        ON rh.part_id      = sp.part_id
GROUP BY a.asset_code, sp.part_name
HAVING COUNT(*) > 1
ORDER BY times_used DESC;

-- 2c. Average repair duration: expect 2.3 days
SELECT ROUND(AVG(end_date - start_date), 1) AS avg_repair_days
FROM Repair
WHERE end_date IS NOT NULL;

-- 2d. Open (non-completed) requests: expect 3 rows (request 6, 8, 12)
SELECT request_id, request_status FROM MaintenanceRequest
WHERE request_status <> 'Completed'
ORDER BY request_id;

-- ---------------------------------------------------------------- 3. CONSTRAINT REJECTION TESTS
-- Each of the following SHOULD FAIL with an error. Run one at a time to confirm
-- the database actually rejects bad data (proves FK + CHECK are enforced).

-- 3a. FK violation: reference a non-existent asset
-- INSERT INTO Fault (fault_id, asset_id, reported_date, reported_by, description, severity, fault_status)
-- VALUES (99, 999, DATE '2026-10-10', 'Test', 'bad asset', 'Low', 'Open');
--    → ORA-02291: integrity constraint (FK_FAULT_ASSET) violated

-- 3b. CHECK violation: invalid condition_rating (must be 1..5)
-- INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating)
-- VALUES (99, 1, DATE '2026-10-10', 'Test', 'Routine', 9);
--    → ORA-02290: check constraint (CHK_CONDITION_RATING) violated

-- 3c. CHECK violation: invalid severity
-- INSERT INTO Fault (fault_id, asset_id, reported_date, reported_by, description, severity, fault_status)
-- VALUES (98, 1, DATE '2026-10-10', 'Test', 'bad severity', 'Catastrophic', 'Open');
--    → ORA-02290: check constraint (CHK_SEVERITY) violated
