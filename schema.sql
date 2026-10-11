-- ============================================================================
-- AssetCare — Community Asset Lifecycle & Maintenance Intelligence System
-- Relational Schema (Oracle 11g+ / 12c / 19c / 21c)  |  12 tables, 3NF
-- ----------------------------------------------------------------------------
-- HOW TO RUN:
--   SQL Developer : open this file and press F5 (Run Script), connected as
--                   your project user/schema.
--   SQL*Plus      : SQL> @schema.sql
--   (Run once on a fresh schema. To re-run, first drop the tables — see the
--    commented DROP block at the bottom.)
--
-- NOTES (Oracle specifics):
--   * Primary keys are plain NUMBER, inserted EXPLICITLY by seed.sql — this is
--     portable across every Oracle version (no 12c IDENTITY dependency).
--   * Oracle does NOT auto-index foreign keys, so the indexes below are
--     genuinely required for the joins/analytics (justifies the "indexing"
--     requirement).
-- ----------------------------------------------------------------------------
-- Lifecycle:  Asset -> Inspection -> Fault -> MaintenanceRequest -> Repair
--             -> RepairHistory (parts) -> Historical Analysis
--
-- Cardinalities:
--   AssetType 1-N Asset ; Location 1-N Asset ; Custodian 1-N Asset
--   AssetStatus 1-N Asset ; Asset 1-N Inspection ; Asset 1-N Fault
--   Inspection 1-N Fault ; Fault 1-N MaintenanceRequest
--   Technician 1-N MaintenanceRequest ; Technician 1-N Repair
--   MaintenanceRequest 1-N Repair ; Repair 1-N RepairHistory
--   SparePart 1-N RepairHistory   (M:N Repair <-> SparePart)
-- ============================================================================

-- 1. AssetType
CREATE TABLE AssetType (
    asset_type_id            NUMBER        CONSTRAINT pk_assettype PRIMARY KEY,
    type_name                VARCHAR2(60)  NOT NULL,
    category                 VARCHAR2(40)  NOT NULL,
    expected_life_years      NUMBER        NOT NULL,
    inspection_interval_days NUMBER        NOT NULL,
    CONSTRAINT uq_assettype_name UNIQUE (type_name)
);

-- 2. Location
CREATE TABLE Location (
    location_id NUMBER        CONSTRAINT pk_location PRIMARY KEY,
    building    VARCHAR2(60)  NOT NULL,
    floor_level VARCHAR2(20),
    area        VARCHAR2(60),
    city        VARCHAR2(40)  NOT NULL,
    CONSTRAINT uq_location UNIQUE (building, floor_level, area)
);

-- 3. Custodian
CREATE TABLE Custodian (
    custodian_id NUMBER       CONSTRAINT pk_custodian PRIMARY KEY,
    full_name    VARCHAR2(80) NOT NULL,
    department   VARCHAR2(60),
    phone        VARCHAR2(20),
    email        VARCHAR2(80),
    CONSTRAINT uq_custodian_email UNIQUE (email)
);

-- 4. AssetStatus
CREATE TABLE AssetStatus (
    status_id   NUMBER        CONSTRAINT pk_assetstatus PRIMARY KEY,
    status_name VARCHAR2(30)  NOT NULL,
    description VARCHAR2(120),
    CONSTRAINT uq_status_name UNIQUE (status_name)
);

-- 5. Asset
CREATE TABLE Asset (
    asset_id      NUMBER        CONSTRAINT pk_asset PRIMARY KEY,
    asset_code    VARCHAR2(30)  NOT NULL,
    asset_name    VARCHAR2(80)  NOT NULL,
    asset_type_id NUMBER        NOT NULL,
    location_id   NUMBER        NOT NULL,
    custodian_id  NUMBER        NOT NULL,
    status_id     NUMBER        NOT NULL,
    serial_number VARCHAR2(40),
    install_date  DATE,
    purchase_cost NUMBER(12,2),
    CONSTRAINT uq_asset_code UNIQUE (asset_code),
    CONSTRAINT fk_asset_type   FOREIGN KEY (asset_type_id) REFERENCES AssetType(asset_type_id),
    CONSTRAINT fk_asset_loc    FOREIGN KEY (location_id)   REFERENCES Location(location_id),
    CONSTRAINT fk_asset_cust   FOREIGN KEY (custodian_id)  REFERENCES Custodian(custodian_id),
    CONSTRAINT fk_asset_status FOREIGN KEY (status_id)     REFERENCES AssetStatus(status_id)
);

-- 6. Inspection
CREATE TABLE Inspection (
    inspection_id    NUMBER        CONSTRAINT pk_inspection PRIMARY KEY,
    asset_id         NUMBER        NOT NULL,
    inspection_date  DATE          NOT NULL,
    inspector_name   VARCHAR2(80)  NOT NULL,
    inspection_type  VARCHAR2(30)  NOT NULL,
    condition_rating NUMBER(2)     NOT NULL,
    findings         VARCHAR2(4000),
    next_due_date    DATE,
    CONSTRAINT fk_insp_asset FOREIGN KEY (asset_id) REFERENCES Asset(asset_id),
    CONSTRAINT chk_condition_rating CHECK (condition_rating BETWEEN 1 AND 5)
);

-- 7. Fault
CREATE TABLE Fault (
    fault_id      NUMBER        CONSTRAINT pk_fault PRIMARY KEY,
    asset_id      NUMBER        NOT NULL,
    inspection_id NUMBER,
    reported_date DATE          NOT NULL,
    reported_by   VARCHAR2(80)  NOT NULL,
    description   VARCHAR2(4000) NOT NULL,
    severity      VARCHAR2(10)  NOT NULL,
    fault_status  VARCHAR2(15)  DEFAULT 'Open' NOT NULL,
    CONSTRAINT fk_fault_asset FOREIGN KEY (asset_id)      REFERENCES Asset(asset_id),
    CONSTRAINT fk_fault_insp  FOREIGN KEY (inspection_id) REFERENCES Inspection(inspection_id),
    CONSTRAINT chk_severity    CHECK (severity IN ('Low','Medium','High','Critical')),
    CONSTRAINT chk_fault_status CHECK (fault_status IN ('Open','In Progress','Resolved'))
);

-- 8. Technician
CREATE TABLE Technician (
    technician_id  NUMBER        CONSTRAINT pk_technician PRIMARY KEY,
    full_name      VARCHAR2(80)  NOT NULL,
    specialization VARCHAR2(40)  NOT NULL,
    phone          VARCHAR2(20),
    email          VARCHAR2(80),
    is_available   NUMBER(1)     DEFAULT 1 NOT NULL,
    CONSTRAINT uq_technician_email UNIQUE (email),
    CONSTRAINT chk_is_available CHECK (is_available IN (0,1))
);

-- 9. MaintenanceRequest
CREATE TABLE MaintenanceRequest (
    request_id     NUMBER        CONSTRAINT pk_maintreq PRIMARY KEY,
    fault_id       NUMBER        NOT NULL,
    technician_id  NUMBER,
    request_date   DATE          NOT NULL,
    priority       VARCHAR2(10)  NOT NULL,
    request_status VARCHAR2(15)  DEFAULT 'Pending' NOT NULL,
    CONSTRAINT fk_req_fault FOREIGN KEY (fault_id)      REFERENCES Fault(fault_id),
    CONSTRAINT fk_req_tech  FOREIGN KEY (technician_id) REFERENCES Technician(technician_id),
    CONSTRAINT chk_priority CHECK (priority IN ('Low','Medium','High','Urgent')),
    CONSTRAINT chk_req_status CHECK (request_status IN ('Pending','Assigned','In Progress','Completed','Cancelled'))
);

-- 10. SparePart
CREATE TABLE SparePart (
    part_id       NUMBER        CONSTRAINT pk_sparepart PRIMARY KEY,
    part_name     VARCHAR2(80)  NOT NULL,
    category      VARCHAR2(40),
    unit_cost     NUMBER(10,2)  NOT NULL,
    stock_qty     NUMBER        DEFAULT 0 NOT NULL,
    reorder_level NUMBER        DEFAULT 1 NOT NULL,
    supplier      VARCHAR2(80),
    CONSTRAINT uq_part_name UNIQUE (part_name)
);

-- 11. Repair
CREATE TABLE Repair (
    repair_id     NUMBER        CONSTRAINT pk_repair PRIMARY KEY,
    request_id    NUMBER        NOT NULL,
    technician_id NUMBER        NOT NULL,
    start_date    DATE          NOT NULL,
    end_date      DATE,
    labour_cost   NUMBER(10,2)  DEFAULT 0 NOT NULL,
    outcome       VARCHAR2(20)  NOT NULL,
    notes         VARCHAR2(4000),
    CONSTRAINT fk_rep_req  FOREIGN KEY (request_id)    REFERENCES MaintenanceRequest(request_id),
    CONSTRAINT fk_rep_tech FOREIGN KEY (technician_id) REFERENCES Technician(technician_id),
    CONSTRAINT chk_outcome CHECK (outcome IN ('Completed','Partially Completed','Replaced','Failed'))
);

-- 12. RepairHistory (parts consumed per repair — M:N junction)
CREATE TABLE RepairHistory (
    repair_history_id    NUMBER        CONSTRAINT pk_repairhistory PRIMARY KEY,
    repair_id            NUMBER        NOT NULL,
    part_id              NUMBER        NOT NULL,
    quantity_used        NUMBER        NOT NULL,
    unit_cost_at_repair  NUMBER(10,2)  NOT NULL,
    CONSTRAINT fk_rh_repair FOREIGN KEY (repair_id) REFERENCES Repair(repair_id),
    CONSTRAINT fk_rh_part   FOREIGN KEY (part_id)   REFERENCES SparePart(part_id),
    CONSTRAINT uq_repair_part UNIQUE (repair_id, part_id)
);

-- ============================================================================
-- INDEXES — Oracle does not auto-index foreign keys, so these support the
-- joins, filters and analytics queries.
-- ============================================================================
CREATE INDEX idx_asset_type    ON Asset(asset_type_id);
CREATE INDEX idx_asset_loc     ON Asset(location_id);
CREATE INDEX idx_asset_cust    ON Asset(custodian_id);
CREATE INDEX idx_asset_status  ON Asset(status_id);

CREATE INDEX idx_insp_asset    ON Inspection(asset_id);
CREATE INDEX idx_insp_date     ON Inspection(inspection_date);

CREATE INDEX idx_fault_asset   ON Fault(asset_id);
CREATE INDEX idx_fault_insp    ON Fault(inspection_id);
CREATE INDEX idx_fault_status  ON Fault(fault_status);
CREATE INDEX idx_fault_severity ON Fault(severity);

CREATE INDEX idx_req_fault     ON MaintenanceRequest(fault_id);
CREATE INDEX idx_req_tech      ON MaintenanceRequest(technician_id);
CREATE INDEX idx_req_status    ON MaintenanceRequest(request_status);

CREATE INDEX idx_rep_req       ON Repair(request_id);
CREATE INDEX idx_rep_tech      ON Repair(technician_id);

CREATE INDEX idx_rh_part       ON RepairHistory(part_id);

-- ============================================================================
-- OPTIONAL: drop everything so the script can be re-run cleanly.
-- Uncomment the lines below and run them once if you need to start over.
-- ============================================================================
-- DROP TABLE RepairHistory      CASCADE CONSTRAINTS PURGE;
-- DROP TABLE Repair             CASCADE CONSTRAINTS PURGE;
-- DROP TABLE SparePart          CASCADE CONSTRAINTS PURGE;
-- DROP TABLE MaintenanceRequest CASCADE CONSTRAINTS PURGE;
-- DROP TABLE Technician         CASCADE CONSTRAINTS PURGE;
-- DROP TABLE Fault              CASCADE CONSTRAINTS PURGE;
-- DROP TABLE Inspection         CASCADE CONSTRAINTS PURGE;
-- DROP TABLE Asset              CASCADE CONSTRAINTS PURGE;
-- DROP TABLE AssetStatus        CASCADE CONSTRAINTS PURGE;
-- DROP TABLE Custodian          CASCADE CONSTRAINTS PURGE;
-- DROP TABLE Location           CASCADE CONSTRAINTS PURGE;
-- DROP TABLE AssetType          CASCADE CONSTRAINTS PURGE;
