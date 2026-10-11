-- ============================================================================
-- AssetCare — Enhancements: intelligence + integrity layer  [Oracle 11g+]
-- Run as ASSETCARE, AFTER schema.sql + seed.sql + views.sql
--   (and after procedures_triggers.sql if you also want the status cascade
--    to be captured by the audit trigger).
--
-- Adds four things that lift the project from "database + analytics"
-- (Level 2) to "intelligent / smart" (Level 3):
--   1. Sequences        -> real ID generation (closes the "hardcoded IDs" gap)
--   2. Asset_Audit      -> change-tracking trigger (data integrity / audit trail)
--   3. fn_asset_risk_score -> predictive-maintenance scoring (the innovation core)
--   4. v_asset_health   -> dashboard view ranking assets by predicted failure risk
-- ============================================================================

-- ============================================================================
-- 1. SEQUENCES — generate primary keys instead of hardcoding them
-- ============================================================================
CREATE SEQUENCE seq_asset      START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_fault      START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_request    START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_repair     START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_inspection START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_audit      START WITH 1    INCREMENT BY 1;

-- Prove they work (nextval advances the counter)
SELECT seq_asset.NEXTVAL AS next_asset_id FROM dual;

-- Real usage pattern (comment shown, not run — it would insert a new row):
-- INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id,
--                    location_id, custodian_id, status_id)
-- VALUES (seq_asset.NEXTVAL, 'LIFT-BLK-D-01', 'Block D Passenger Lift',
--         1, 1, 1, 1);

-- ============================================================================
-- 2. AUDIT TRAIL — track every change to an asset's status
-- ============================================================================
CREATE TABLE Asset_Audit (
    audit_id    NUMBER       CONSTRAINT pk_asset_audit PRIMARY KEY,
    asset_id    NUMBER       NOT NULL,
    old_status  NUMBER,
    new_status  NUMBER,
    changed_by  VARCHAR2(80),
    changed_at  DATE         DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_audit_asset FOREIGN KEY (asset_id) REFERENCES Asset(asset_id)
);

CREATE OR REPLACE TRIGGER trg_asset_audit
BEFORE UPDATE ON Asset
FOR EACH ROW
BEGIN
    IF :OLD.status_id <> :NEW.status_id THEN
        INSERT INTO Asset_Audit (audit_id, asset_id, old_status, new_status,
                                 changed_by, changed_at)
        VALUES (seq_audit.NEXTVAL, :NEW.asset_id, :OLD.status_id, :NEW.status_id,
                USER, SYSDATE);
    END IF;
END;
/

-- ============================================================================
-- 3. PREDICTIVE-MAINTENANCE RISK SCORE (stored function)
--    risk = frequency + severity + recency - condition
--    Higher score  => more likely to fail next => maintain proactively.
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_asset_risk_score (p_asset_id IN NUMBER)
RETURN NUMBER
IS
    v_fault_count  NUMBER := 0;
    v_sev_penalty  NUMBER := 0;
    v_recency      NUMBER := 0;
    v_open_penalty NUMBER := 0;
    v_condition    NUMBER := 3;
    v_risk         NUMBER;
BEGIN
    -- 1. How many times has it failed?
    SELECT COUNT(*) INTO v_fault_count
      FROM Fault WHERE asset_id = p_asset_id;

    -- 2. How severe were those failures? (Low=2, Medium=4, High=6, Critical=10)
    SELECT COALESCE(SUM(CASE severity
                         WHEN 'Low'      THEN 2
                         WHEN 'Medium'   THEN 4
                         WHEN 'High'     THEN 6
                         WHEN 'Critical' THEN 10
                         ELSE 0 END), 0)
      INTO v_sev_penalty
      FROM Fault WHERE asset_id = p_asset_id;

    -- 3. How recent was the last failure? (a 45-day window; older = no penalty)
    SELECT NVL(GREATEST(0, 45 - (TRUNC(SYSDATE) - MAX(reported_date))), 0)
      INTO v_recency
      FROM Fault WHERE asset_id = p_asset_id;

    -- 4. Is anything still UNRESOLVED? An open/active fault is a live risk.
    SELECT COUNT(*) INTO v_open_penalty
      FROM Fault WHERE asset_id = p_asset_id AND fault_status <> 'Resolved';
    IF v_open_penalty > 0 THEN
        v_open_penalty := 25;
    END IF;

    -- 5. What is the asset's current condition? (rating 1..5, 5 = excellent)
    SELECT NVL(ROUND(AVG(condition_rating), 1), 3)
      INTO v_condition
      FROM Inspection WHERE asset_id = p_asset_id;

    -- Combine: frequency, severity, recency and OPEN faults RAISE risk;
    -- good condition lowers it.
    v_risk := GREATEST(0,
               (v_fault_count * 10) + v_sev_penalty + v_recency + v_open_penalty
               - (v_condition * 5));

    RETURN v_risk;
END;
/

-- ============================================================================
-- 4. ASSET HEALTH DASHBOARD VIEW — rank assets by predicted failure risk
-- ============================================================================
CREATE OR REPLACE VIEW v_asset_health AS
SELECT asset_code, asset_name, status_name,
       fault_count, last_fault_date, avg_condition,
       risk_score,
       CASE WHEN risk_score >= 40 THEN 'HIGH'
            WHEN risk_score >= 20 THEN 'MODERATE'
            ELSE 'LOW' END AS risk_band
FROM (
    SELECT a.asset_code, a.asset_name, s.status_name,
           (SELECT COUNT(*) FROM Fault f WHERE f.asset_id = a.asset_id) AS fault_count,
           (SELECT MAX(f.reported_date) FROM Fault f WHERE f.asset_id = a.asset_id) AS last_fault_date,
           (SELECT NVL(ROUND(AVG(i.condition_rating),1), 3)
              FROM Inspection i WHERE i.asset_id = a.asset_id) AS avg_condition,
           fn_asset_risk_score(a.asset_id) AS risk_score
    FROM Asset a
    JOIN AssetStatus s ON a.status_id = s.status_id
);

-- ============================================================================
-- 5. DEMOS
-- ============================================================================

-- 5a. Predicted maintenance priority (the headline: "what fails next?")
SELECT asset_code, asset_name, status_name, fault_count,
       risk_score, risk_band
FROM v_asset_health
ORDER BY risk_score DESC;

-- 5b. The audit trigger in action — two status changes, two audit rows
UPDATE Asset SET status_id = 5 WHERE asset_id = 2;   -- Active -> Pending Inspection
UPDATE Asset SET status_id = 1 WHERE asset_id = 2;   -- back to Active
SELECT asset_id, old_status, new_status, changed_by, changed_at
FROM Asset_Audit
ORDER BY audit_id;
COMMIT;
