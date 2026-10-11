# AssetCare — ER / EER Diagram

Render this file in VS Code (with a Mermaid extension), at https://mermaid.live,
or paste the diagram into draw.io (it imports Mermaid). Screenshot the result for
the report / poster.

```mermaid
erDiagram
    AssetType ||--o{ Asset : "classified by"
    Location  ||--o{ Asset : "located at"
    Custodian ||--o{ Asset : "maintained by"
    AssetStatus ||--o{ Asset : "has status"

    Asset ||--o{ Inspection : "inspected in"
    Asset ||--o{ Fault : "fails with"
    Inspection ||--o{ Fault : "detects"

    Fault ||--o{ MaintenanceRequest : "raises"
    Technician ||--o{ MaintenanceRequest : "assigned to"
    Technician ||--o{ Repair : "performs"

    MaintenanceRequest ||--o{ Repair : "resolved by"
    Repair ||--o{ RepairHistory : "consumes"
    SparePart ||--o{ RepairHistory : "supplied in"

    Asset ||--o{ Asset_Audit : "change logged to"

    AssetType {
        number asset_type_id PK
        varchar2 type_name
        varchar2 category
        number expected_life_years
        number inspection_interval_days
    }

    Location {
        number location_id PK
        varchar2 building
        varchar2 floor_level
        varchar2 area
        varchar2 city
    }

    Custodian {
        number custodian_id PK
        varchar2 full_name
        varchar2 department
        varchar2 phone
        varchar2 email
    }

    AssetStatus {
        number status_id PK
        varchar2 status_name
        varchar2 description
    }

    Asset {
        number asset_id PK
        varchar2 asset_code
        varchar2 asset_name
        number asset_type_id FK
        number location_id FK
        number custodian_id FK
        number status_id FK
        varchar2 serial_number
        date install_date
        number purchase_cost
    }

    Inspection {
        number inspection_id PK
        number asset_id FK
        date inspection_date
        varchar2 inspector_name
        varchar2 inspection_type
        number condition_rating
        varchar2 findings
        date next_due_date
    }

    Fault {
        number fault_id PK
        number asset_id FK
        number inspection_id FK
        date reported_date
        varchar2 reported_by
        varchar2 description
        varchar2 severity
        varchar2 fault_status
    }

    Technician {
        number technician_id PK
        varchar2 full_name
        varchar2 specialization
        varchar2 phone
        varchar2 email
        number is_available
    }

    MaintenanceRequest {
        number request_id PK
        number fault_id FK
        number technician_id FK
        date request_date
        varchar2 priority
        varchar2 request_status
    }

    SparePart {
        number part_id PK
        varchar2 part_name
        varchar2 category
        number unit_cost
        number stock_qty
        number reorder_level
        varchar2 supplier
    }

    Repair {
        number repair_id PK
        number request_id FK
        number technician_id FK
        date start_date
        date end_date
        number labour_cost
        varchar2 outcome
        varchar2 notes
    }

    RepairHistory {
        number repair_history_id PK
        number repair_id FK
        number part_id FK
        number quantity_used
        number unit_cost_at_repair
    }

    Asset_Audit {
        number audit_id PK
        number asset_id FK
        number old_status
        number new_status
        varchar2 changed_by
        date changed_at
    }
```

## Cardinalities (one-line summary)

| Relationship | Cardinality | Meaning |
|---|---|---|
| AssetType → Asset | 1:N | one type classifies many assets |
| Location → Asset | 1:N | one location hosts many assets |
| Custodian → Asset | 1:N | one custodian manages many assets |
| AssetStatus → Asset | 1:N | one status applies to many assets |
| Asset → Inspection | 1:N | one asset has many inspections |
| Asset → Fault | 1:N | one asset can fail many times |
| Inspection → Fault | 1:N | one inspection can detect many faults |
| Fault → MaintenanceRequest | 1:N | one fault raises one/more requests |
| Technician → MaintenanceRequest | 1:N | one technician handles many requests |
| Technician → Repair | 1:N | one technician performs many repairs |
| MaintenanceRequest → Repair | 1:N | one request resolved by one/more repairs |
| Repair → RepairHistory | 1:N | one repair consumes many parts |
| SparePart → RepairHistory | 1:N | one part used across many repairs (M:N via junction) |
| Asset → Asset_Audit | 1:N | one asset has many status-change records |
