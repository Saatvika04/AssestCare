-- ============================================================================
-- Module 2 — Maintenance Workflow (Saatvika K)  [Oracle 11g+]
-- Covers: CRUD on requests/repairs, joins (fault→request→repair), aggregate
--         queries (cost & duration), nested queries (unassigned/overdue).
-- Run after schema.sql + seed.sql. The CRUD section mutates state.
-- ============================================================================

-- ============================================================================
-- 1. CRUD — end-to-end workflow: Fault → Request → Assign → Repair → Parts
-- ============================================================================

-- 1a. Log a new fault (reported directly by a resident, no inspection yet)
INSERT INTO Fault
    (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status)
VALUES
    (13, 5, NULL, DATE '2026-10-02', 'Resident', 'Main gate light blinking again', 'Medium', 'Open');

-- 1b. Raise a maintenance request from that fault
INSERT INTO MaintenanceRequest (request_id, fault_id, request_date, priority, request_status)
VALUES (13, 13, DATE '2026-10-03', 'Medium', 'Pending');

-- 1c. Assign a technician to the request
UPDATE MaintenanceRequest SET technician_id = 1, request_status = 'Assigned' WHERE request_id = 13;

-- 1d. Create the repair record (work completed same day)
INSERT INTO Repair
    (repair_id, request_id, technician_id, start_date, end_date, labour_cost, outcome, notes)
VALUES
    (10, 13, 1, DATE '2026-10-04', DATE '2026-10-04', 400.00, 'Completed', 'Replaced LED bulb');

-- 1e. Record the spare part consumed
INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair)
VALUES (11, 10, 3, 1, 800.00);

-- 1f. Close the loop — update request and fault status consistently
UPDATE MaintenanceRequest SET request_status = 'Completed' WHERE request_id = 13;
UPDATE Fault             SET fault_status   = 'Resolved'  WHERE fault_id = 13;

-- ============================================================================
-- 2. JOINS — the complete maintenance workflow chain
-- ============================================================================

-- 2a. Full chain: Fault → Asset → MaintenanceRequest → Repair → Technician
SELECT f.fault_id,
       a.asset_code, f.description, f.severity, f.fault_status,
       r.request_id, r.priority, r.request_status,
       rep.repair_id, t.full_name AS technician,
       rep.start_date, rep.end_date, rep.outcome
FROM Fault f
JOIN Asset               a   ON f.asset_id      = a.asset_id
JOIN MaintenanceRequest  r   ON f.fault_id      = r.fault_id
LEFT JOIN Repair         rep ON r.request_id    = rep.request_id
LEFT JOIN Technician     t   ON rep.technician_id = t.technician_id
ORDER BY f.fault_id;

-- 2b. Open requests (not yet completed) with fault, asset and assigned tech
SELECT r.request_id, r.request_date, r.priority, r.request_status,
       a.asset_code, f.description, f.severity,
       COALESCE(t.full_name, '(unassigned)') AS technician
FROM MaintenanceRequest r
JOIN Fault      f ON r.fault_id      = f.fault_id
JOIN Asset      a ON f.asset_id      = a.asset_id
LEFT JOIN Technician t ON r.technician_id = t.technician_id
WHERE r.request_status <> 'Completed'
ORDER BY r.request_date;

-- ============================================================================
-- 3. AGGREGATE QUERIES — repair costs and durations
-- ============================================================================

-- 3a. Total cost per repair = labour + parts
SELECT rep.repair_id,
       rep.labour_cost,
       COALESCE(SUM(rh.quantity_used * rh.unit_cost_at_repair), 0) AS parts_cost,
       rep.labour_cost + COALESCE(SUM(rh.quantity_used * rh.unit_cost_at_repair), 0) AS total_cost
FROM Repair rep
LEFT JOIN RepairHistory rh ON rep.repair_id = rh.repair_id
GROUP BY rep.repair_id, rep.labour_cost
ORDER BY total_cost DESC;

-- 3b. Repair duration per job (days between start and end)
SELECT rep.repair_id,
       (rep.end_date - rep.start_date) AS duration_days
FROM Repair rep
WHERE rep.end_date IS NOT NULL
ORDER BY duration_days DESC;

-- 3c. Average repair duration across all completed jobs
SELECT ROUND(AVG(rep.end_date - rep.start_date), 1) AS avg_repair_days
FROM Repair rep
WHERE rep.end_date IS NOT NULL;

-- 3d. Total maintenance spend per asset (parts pre-aggregated to avoid double count)
SELECT a.asset_code,
       COALESCE(SUM(rep.labour_cost), 0) AS total_labour,
       COALESCE(SUM(pc.parts_cost), 0)   AS total_parts,
       COALESCE(SUM(rep.labour_cost), 0) + COALESCE(SUM(pc.parts_cost), 0) AS total_spend
FROM Asset a
JOIN Fault              f   ON a.asset_id   = f.asset_id
JOIN MaintenanceRequest r   ON f.fault_id   = r.fault_id
LEFT JOIN Repair        rep ON r.request_id = rep.request_id
LEFT JOIN (
    SELECT repair_id, SUM(quantity_used * unit_cost_at_repair) AS parts_cost
    FROM RepairHistory
    GROUP BY repair_id
) pc ON rep.repair_id = pc.repair_id
GROUP BY a.asset_code
ORDER BY total_spend DESC;

-- 3e. Technician workload (number of repairs + total days worked)
SELECT t.full_name, t.specialization,
       COUNT(rep.repair_id)                                   AS repairs_done,
       COALESCE(SUM(rep.end_date - rep.start_date), 0)        AS total_days
FROM Technician t
LEFT JOIN Repair rep ON t.technician_id = rep.technician_id
GROUP BY t.full_name, t.specialization
ORDER BY repairs_done DESC;

-- ============================================================================
-- 4. NESTED QUERIES — unassigned and overdue requests
-- ============================================================================

-- 4a. Unassigned requests (no technician yet)
SELECT r.request_id, r.request_date, r.priority, f.description, a.asset_code
FROM MaintenanceRequest r
JOIN Fault f ON r.fault_id = f.fault_id
JOIN Asset a ON f.asset_id = a.asset_id
WHERE r.technician_id IS NULL
ORDER BY r.request_date;

-- 4b. Overdue requests — open for more than 14 days (NOT IN excludes completed)
SELECT r.request_id, r.request_date, r.request_status,
       f.description, a.asset_code,
       (TRUNC(SYSDATE) - r.request_date) AS days_open
FROM MaintenanceRequest r
JOIN Fault f ON r.fault_id = f.fault_id
JOIN Asset a ON f.asset_id = a.asset_id
WHERE r.request_id NOT IN (
        SELECT request_id FROM MaintenanceRequest WHERE request_status = 'Completed'
      )
  AND (TRUNC(SYSDATE) - r.request_date) > 14
ORDER BY days_open DESC;

-- 4c. Technicians with no open assignment (NOT EXISTS correlated subquery)
SELECT t.full_name, t.specialization
FROM Technician t
WHERE NOT EXISTS (
    SELECT 1
    FROM MaintenanceRequest r
    WHERE r.technician_id = t.technician_id
      AND r.request_status IN ('Assigned', 'In Progress')
)
ORDER BY t.full_name;

-- 4d. Requests whose fault severity is Critical (IN subquery)
SELECT r.request_id, r.request_date, r.priority, r.request_status, f.description
FROM MaintenanceRequest r
JOIN Fault f ON r.fault_id = f.fault_id
WHERE r.fault_id IN (
        SELECT fault_id FROM Fault WHERE severity = 'Critical'
      )
ORDER BY r.request_date;
