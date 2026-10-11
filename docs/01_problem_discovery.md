# Deliverable 1 — Problem Discovery Report

**Project:** AssetCare — Community Asset Lifecycle & Maintenance Intelligence System
**Track:** T10 (Smart Community & Civic Life), with elements of T5 (Waste & Circular Economy — repair/reuse)

---

## 1. The societal problem

Community infrastructure — lifts, water dispensers, streetlights, generators, accessibility
ramps, HVAC — is almost always maintained **reactively**: something breaks, a resident
complains, and only then is it repaired. This causes:

- **Safety hazards** — a broken ramp handrail or a lift that "jerks violently" endangers
  residents (children, the elderly, persons with disabilities).
- **Downtime** — assets sit out of service for days while the failure is noticed, reported,
  and scheduled.
- **Unplanned, higher spending** — emergency repairs cost more than scheduled ones, and
  repeated "fix the same thing again" repairs waste money.
- **No institutional memory** — nobody knows *which* asset keeps failing or *why*.

## 2. Who is affected, and where

- **Residents** of multi-building communities and residential campuses — the direct users.
- **Facility managers and custodians** — who must track assets with limited tools.
- **Technicians and vendors** — who arrive with too little history to fix the root cause.

**Where:** gated communities, apartment complexes, student/residential campuses, and
housing societies. Our working dataset models a real campus layout (Block A/B/C, Central
Library, Sports Complex, Community Hall, Main Gate, Community Park).

## 3. Evidence

The recurring-failure pattern is visible in our own (realistic) reference data:

| Asset | Failures | Pattern |
|---|---|---|
| `LIFT-BLK-A-01` (Block A Lift) | 3 | doors → jerking → **stuck with passengers**; the 15kW motor was replaced **twice** |
| `SL-PARK-01` / `SL-MG-01` (streetlights) | 2 each | same LED bulb / driver replaced repeatedly |
| `RAMP-COM-01` (Community Hall ramp) | 1, Critical | handrail broken — "unsafe for use" |

`LIFT-BLK-A-01` alone accounts for ₹1,20,900 of maintenance spend — a recurring-failure
asset that a spreadsheet would never flag *before* the third, most serious failure.

## 4. Existing solutions and their limitations

**Non-digital:** paper logbooks, WhatsApp groups, ad-hoc spreadsheets.
*Limitation:* no linking of fault → asset → part → cost; no way to detect recurrence or
predict the next failure; knowledge lives in one person's head.

**Digital (existing):** enterprise Computerised Maintenance Management Systems (CMMS)
such as IBM Maximo, Fiix, UpKeep, MaintainX.
*Limitation:* priced and architected for industrial plants/facilities; require training,
licences and IT support; overkill and unaffordable for a housing society or small campus.

## 5. The gap

There is **no affordable, database-centric maintenance-intelligence system for small
communities** that (a) tracks the full asset lifecycle, and (b) actively *flags
recurring-failure assets before they fail again*.

## 6. Proposed innovation (one line)

A lightweight, fully database-driven community asset system whose core value is
**predictive recurring-failure scoring** — turning reactive repair into proactive,
budgeted, safer maintenance.
