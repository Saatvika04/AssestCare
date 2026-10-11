# Deliverable 4 (part) — Normalization Justification

**Project:** AssetCare — Community Asset Lifecycle & Maintenance Intelligence System

The schema is fully normalised to **Third Normal Form (3NF)**. Justification below.

---

## 1NF — atomic values, no repeating groups

Every column holds a single atomic value; there are no multi-valued columns or repeating
groups. Example: instead of storing multiple faults *inside* the Asset row, each fault is a
separate row in `Fault` (a 1:N relationship).

## 2NF — no partial dependency (full key dependency)

Every table has a **single-column primary key**, so there are no composite keys and
therefore no partial dependencies. Non-key attributes depend on the whole primary key.
Example: in `Repair`, `start_date`, `labour_cost` and `outcome` depend entirely on
`repair_id`.

## 3NF — no transitive dependency

No non-key attribute depends on another non-key attribute. Lookup attributes are pulled out
into their own tables rather than repeated:

| Instead of storing… | …we reference a lookup table |
|---|---|
| type name/category/life on every Asset | `AssetType` |
| building/floor/area/city on every Asset | `Location` |
| custodian name/department on every Asset | `Custodian` |
| status name on every Asset | `AssetStatus` |
| part name/cost/stock on every RepairHistory row | `SparePart` |

This eliminates update anomalies: renaming a custodian or changing a part's unit cost is a
single UPDATE, not a mass update across thousands of rows.

## The M:N junction — RepairHistory

`Repair` ↔ `SparePart` is **many-to-many** (one repair uses many parts; one part is used
across many repairs). This is correctly decomposed via the `RepairHistory` junction table,
which additionally stores the *quantity used* and the *unit cost at the time of repair*
(a snapshot — historical cost must not change when today's price changes).

## Functional dependencies (summary)

- `AssetType.asset_type_id → type_name, category, expected_life_years, inspection_interval_days`
- `Asset.asset_id → asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, …`
- `Fault.fault_id → asset_id, inspection_id, reported_date, severity, fault_status, …`
- `RepairHistory.(repair_id, part_id) → quantity_used, unit_cost_at_repair`

## Why not higher normal forms (BCNF/4NF)?

The schema is already in BCNF (every determinant is a candidate key — all single-column
primary keys with no overlapping determinants), and there are no multi-valued dependencies
to require 4NF. Higher normalisation would add no benefit here and would fragment the
domain into less-intuitive tables.
