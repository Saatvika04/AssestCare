-- ============================================================================
-- AssetCare — Role-based access & security demo  [run as SYSTEM]
--
-- WHY run as SYSTEM: creating roles and users needs DBA privileges, which the
-- assetcare user does not have. This file demonstrates least-privilege access:
-- different roles can do different things, and no single user sees everything.
--
-- RUN ORDER:
--   1. enhancements.sql  (as assetcare)  -> creates v_asset_health etc.
--   2. security.sql      (as SYSTEM)     -> this file
--
-- Run ONCE. To re-run, first drop the users/roles (see the DROP block at bottom).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Roles
-- ----------------------------------------------------------------------------
CREATE ROLE role_asset_manager;
CREATE ROLE role_technician;
CREATE ROLE role_resident;
CREATE ROLE role_reporting;

-- ----------------------------------------------------------------------------
-- 2. Object privileges on the assetcare schema
-- ----------------------------------------------------------------------------

-- Asset manager: full control over the operational tables, read-only lookups
GRANT SELECT, INSERT, UPDATE, DELETE ON assetcare.Asset              TO role_asset_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON assetcare.Inspection         TO role_asset_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON assetcare.Fault              TO role_asset_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON assetcare.MaintenanceRequest TO role_asset_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON assetcare.Repair             TO role_asset_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON assetcare.RepairHistory      TO role_asset_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON assetcare.SparePart          TO role_asset_manager;
GRANT SELECT ON assetcare.AssetType   TO role_asset_manager;
GRANT SELECT ON assetcare.Location    TO role_asset_manager;
GRANT SELECT ON assetcare.Custodian   TO role_asset_manager;
GRANT SELECT ON assetcare.AssetStatus TO role_asset_manager;
GRANT SELECT ON assetcare.Technician  TO role_asset_manager;

-- Technician: read most things, but only UPDATE their requests / repairs
GRANT SELECT ON assetcare.Asset      TO role_technician;
GRANT SELECT ON assetcare.Fault      TO role_technician;
GRANT SELECT ON assetcare.Technician TO role_technician;
GRANT SELECT ON assetcare.SparePart  TO role_technician;
GRANT SELECT, UPDATE          ON assetcare.MaintenanceRequest TO role_technician;
GRANT SELECT, INSERT, UPDATE  ON assetcare.Repair             TO role_technician;
GRANT SELECT, INSERT          ON assetcare.RepairHistory      TO role_technician;

-- Resident: view assets and report faults only (no update/delete)
GRANT SELECT ON assetcare.Asset TO role_resident;
GRANT SELECT ON assetcare.Fault TO role_resident;
GRANT INSERT ON assetcare.Fault TO role_resident;

-- Reporting: read-only analytics via the views
GRANT SELECT ON assetcare.v_asset_condition_summary   TO role_reporting;
GRANT SELECT ON assetcare.v_open_maintenance_requests TO role_reporting;
GRANT SELECT ON assetcare.v_management_dashboard      TO role_reporting;
GRANT SELECT ON assetcare.v_asset_health              TO role_reporting;

-- ----------------------------------------------------------------------------
-- 3. Demo users (log in and verify least-privilege behaviour)
-- ----------------------------------------------------------------------------
CREATE USER demo_manager  IDENTIFIED BY demo123;
CREATE USER demo_tech     IDENTIFIED BY demo123;
CREATE USER demo_resident IDENTIFIED BY demo123;

GRANT CONNECT          TO demo_manager, demo_tech, demo_resident;
GRANT role_asset_manager TO demo_manager;
GRANT role_technician    TO demo_tech;
GRANT role_resident      TO demo_resident;

-- ----------------------------------------------------------------------------
-- 4. Verify the role -> privilege mapping
-- ----------------------------------------------------------------------------
SELECT grantee, table_name, privilege
FROM   dba_tab_privs
WHERE  grantee IN ('ROLE_ASSET_MANAGER','ROLE_TECHNICIAN','ROLE_RESIDENT','ROLE_REPORTING')
ORDER BY grantee, table_name, privilege;

-- ============================================================================
-- OPTIONAL: drop everything so the file can be re-run cleanly.
-- ============================================================================
-- DROP USER demo_manager  CASCADE;
-- DROP USER demo_tech     CASCADE;
-- DROP USER demo_resident CASCADE;
-- DROP ROLE role_asset_manager;
-- DROP ROLE role_technician;
-- DROP ROLE role_resident;
-- DROP ROLE role_reporting;
