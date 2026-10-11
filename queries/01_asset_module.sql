-- ============================================================================
-- Module 1 — Asset Management (Deepak James)  [Oracle 11g+]
-- Covers: CRUD on Asset/Inspection, joins, aggregate queries, nested queries
-- Run after schema.sql + seed.sql.
-- ============================================================================

-- ============================================================================
-- 1. CRUD OPERATIONS  (Asset registration + inspection recording)
-- ============================================================================

-- 1a. CREATE — register a new asset
INSERT INTO Asset
    (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost)
VALUES
    (14, 'SL-PARK-02', 'Park North Streetlight', 3, 6, 2, 1, 'SL-2026-09', DATE '2026-09-15', 18500.00);

-- 1b. READ — fetch the asset just created (by natural key)
SELECT * FROM Asset WHERE asset_code = 'SL-PARK-02';

-- 1c. UPDATE — change an asset's status (e.g. mark Block A lift as under repair)
UPDATE Asset SET status_id = 2 WHERE asset_id = 1;

-- 1d. CREATE — record a new inspection for an asset
INSERT INTO Inspection
    (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date)
VALUES
    (16, 2, DATE '2026-10-01', 'Deepak James', 'Routine', 4, 'Slight motor noise, otherwise fine', DATE '2027-01-01');

-- 1e. DELETE — decommission / remove an obsolete asset record
--     (relies on FK checks: cannot delete while inspections/faults reference it)
-- DELETE FROM Asset WHERE asset_id = 13;

-- ============================================================================
-- 2. JOINS — asset registry with its lookup tables
-- ============================================================================

-- 2a. Full asset list joined across AssetType, Location, Custodian, AssetStatus
SELECT a.asset_id, a.asset_code, a.asset_name,
       t.type_name,
       l.building, l.area,
       c.full_name AS custodian,
       s.status_name
FROM Asset a
JOIN AssetType   t ON a.asset_type_id = t.asset_type_id
JOIN Location    l ON a.location_id   = l.location_id
JOIN Custodian   c ON a.custodian_id  = c.custodian_id
JOIN AssetStatus s ON a.status_id     = s.status_id
ORDER BY a.asset_id;

-- 2b. Location-wise assets (how many assets + total value per location)
SELECT l.building, l.area, l.city,
       COUNT(a.asset_id)          AS asset_count,
       COALESCE(SUM(a.purchase_cost), 0) AS total_value
FROM Location l
LEFT JOIN Asset a ON l.location_id = a.location_id
GROUP BY l.building, l.area, l.city
ORDER BY asset_count DESC, total_value DESC;

-- 2c. Inspections joined with Asset + Location (the inspection history view)
SELECT i.inspection_id,
       a.asset_code, a.asset_name, l.building,
       i.inspection_date, i.inspection_type, i.condition_rating, i.findings
FROM Inspection i
JOIN Asset    a ON i.asset_id = a.asset_id
JOIN Location l ON a.location_id = l.location_id
ORDER BY i.inspection_date DESC;

-- ============================================================================
-- 3. AGGREGATE QUERIES — inspection summaries
-- ============================================================================

-- 3a. Number of inspections per asset
SELECT a.asset_code, a.asset_name, COUNT(i.inspection_id) AS inspections_done
FROM Asset a
LEFT JOIN Inspection i ON a.asset_id = i.asset_id
GROUP BY a.asset_code, a.asset_name
ORDER BY inspections_done DESC;

-- 3b. Average condition rating per asset (only show assets below a healthy 4)
SELECT a.asset_code,
       ROUND(AVG(i.condition_rating), 2) AS avg_condition
FROM Asset a
JOIN Inspection i ON a.asset_id = i.asset_id
GROUP BY a.asset_code
HAVING ROUND(AVG(i.condition_rating), 2) < 4
ORDER BY avg_condition ASC;

-- 3c. Asset count by type
SELECT t.type_name, COUNT(a.asset_id) AS asset_count
FROM AssetType t
LEFT JOIN Asset a ON t.asset_type_id = a.asset_type_id
GROUP BY t.type_name
ORDER BY asset_count DESC;

-- ============================================================================
-- 4. NESTED QUERIES — assets due for inspection / never inspected
-- ============================================================================

-- 4a. Assets whose latest inspection is now overdue (next_due_date < today)
SELECT a.asset_code, a.asset_name
FROM Asset a
WHERE a.asset_id IN (
    SELECT i.asset_id
    FROM Inspection i
    WHERE i.next_due_date < TRUNC(SYSDATE)
      AND i.inspection_date = (
          SELECT MAX(i2.inspection_date)
          FROM Inspection i2
          WHERE i2.asset_id = i.asset_id
      )
)
ORDER BY a.asset_code;

-- 4b. Assets that have never been inspected (using NOT EXISTS)
SELECT a.asset_code, a.asset_name
FROM Asset a
WHERE NOT EXISTS (
    SELECT 1
    FROM Inspection i
    WHERE i.asset_id = a.asset_id
)
ORDER BY a.asset_code;
