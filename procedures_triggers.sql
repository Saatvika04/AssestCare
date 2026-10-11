-- ============================================================================
-- AssetCare — Stored procedure, triggers, and transaction/rollback demo
-- [Oracle 11g+, PL/SQL]
--
-- IMPORTANT: run this whole file as a SCRIPT (SQL Developer: press F5 /
-- "Run Script"; SQL*Plus: SQL> @procedures_triggers.sql). Each PL/SQL block
-- must be followed by a slash ( / ) on its own line, which is already present.
--
-- Run after schema.sql + seed.sql.
-- ============================================================================

-- ============================================================================
-- 1. STORED PROCEDURE — complete a repair and cascade the status updates
--    (closes Repair, Request, Fault and returns the Asset to Active in one call)
-- ============================================================================
CREATE OR REPLACE PROCEDURE complete_repair(
    p_repair_id IN NUMBER,
    p_end_date  IN DATE,
    p_outcome   IN VARCHAR2
)
AS
    v_request_id NUMBER;
    v_fault_id   NUMBER;
    v_asset_id   NUMBER;
BEGIN
    -- Resolve the chain Repair -> Request -> Fault -> Asset
    SELECT r.request_id, f.fault_id, f.asset_id
    INTO   v_request_id, v_fault_id, v_asset_id
    FROM Repair rep
    JOIN MaintenanceRequest r ON rep.request_id = r.request_id
    JOIN Fault              f ON r.fault_id     = f.fault_id
    WHERE rep.repair_id = p_repair_id;

    UPDATE Repair             SET end_date = p_end_date, outcome = p_outcome WHERE repair_id   = p_repair_id;
    UPDATE MaintenanceRequest SET request_status = 'Completed'            WHERE request_id  = v_request_id;
    UPDATE Fault              SET fault_status   = 'Resolved'             WHERE fault_id    = v_fault_id;
    UPDATE Asset              SET status_id      = 1                      WHERE asset_id    = v_asset_id;  -- Active
END;
/

-- ============================================================================
-- 2. TRIGGERS
-- ============================================================================

-- 2a. Enforce spare-part stock: reject over-consumption, then decrement stock
--     automatically whenever a part is recorded against a repair.
CREATE OR REPLACE TRIGGER trg_repair_history_stock
BEFORE INSERT ON RepairHistory
FOR EACH ROW
DECLARE
    v_stock NUMBER;
BEGIN
    SELECT stock_qty INTO v_stock FROM SparePart WHERE part_id = :NEW.part_id;

    IF v_stock < :NEW.quantity_used THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient spare-part stock');
    END IF;

    UPDATE SparePart SET stock_qty = stock_qty - :NEW.quantity_used WHERE part_id = :NEW.part_id;
END;
/

-- 2b. Reject a repair whose end date is before its start date (business rule)
CREATE OR REPLACE TRIGGER trg_repair_date_check
BEFORE UPDATE ON Repair
FOR EACH ROW
BEGIN
    IF :NEW.end_date IS NOT NULL AND :NEW.end_date < :NEW.start_date THEN
        RAISE_APPLICATION_ERROR(-20002, 'Repair end_date cannot be before start_date');
    END IF;
END;
/

-- ============================================================================
-- 3. TRANSACTION DEMO — atomicity and rollback
-- ============================================================================

-- 3a. Atomic COMMIT: create repair + consume a part + close the whole loop.
--     The stock decrement happens inside the same transaction (all-or-nothing).
INSERT INTO Repair (repair_id, request_id, technician_id, start_date, end_date, labour_cost, outcome, notes)
VALUES (20, 6, 3, DATE '2026-09-02', DATE '2026-09-03', 1200.00, 'Completed', 'Replaced compressor relay');

-- Fires trg_repair_history_stock → validates and decrements water-filter stock
INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair)
VALUES (20, 20, 2, 1, 1500.00);

UPDATE MaintenanceRequest SET request_status = 'Completed' WHERE request_id = 6;
UPDATE Fault              SET fault_status   = 'Resolved'  WHERE fault_id = 6;
UPDATE Asset              SET status_id      = 1           WHERE asset_id = 4;

COMMIT;

-- 3b. ROLLBACK: changes inside a rolled-back transaction leave no trace.
SELECT part_name, stock_qty FROM SparePart WHERE part_id = 3;   -- before: 60

UPDATE SparePart SET stock_qty = stock_qty - 5 WHERE part_id = 3;
ROLLBACK;

SELECT part_name, stock_qty FROM SparePart WHERE part_id = 3;   -- after: still 60

-- ============================================================================
-- 4. USE THE STORED PROCEDURE — close the open HVAC repair (request 8)
-- ============================================================================
INSERT INTO Repair (repair_id, request_id, technician_id, start_date, labour_cost, outcome, notes)
VALUES (21, 8, 6, DATE '2026-09-21', 0, 'Completed', 'Compressor replacement');

BEGIN
    complete_repair(21, DATE '2026-09-25', 'Completed');
END;
/

-- Verify the procedure cascaded the status changes in a single call
SELECT request_id, request_status FROM MaintenanceRequest WHERE request_id = 8;   -- Completed
SELECT fault_id,   fault_status   FROM Fault              WHERE fault_id   = 8;   -- Resolved
SELECT asset_code, status_id      FROM Asset              WHERE asset_id   = 10;  -- 1 (Active)

-- ============================================================================
-- 5. TRIGGER REJECTION DEMO (run one at a time; each raises an error)
-- ============================================================================

-- 5a. Attempting to over-consume stock → rejected by trg_repair_history_stock
-- INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair)
-- VALUES (21, 20, 6, 999, 6500.00);   -- stock of part 6 is only 4 → ORA-20001

-- 5b. Attempting an invalid repair date → rejected by trg_repair_date_check
-- UPDATE Repair SET end_date = DATE '2026-01-01' WHERE repair_id = 1;   -- before start_date → ORA-20002
