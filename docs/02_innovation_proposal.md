# Deliverable 2 — Innovation Proposal

**Project:** AssetCare — Community Asset Lifecycle & Maintenance Intelligence System

---

## Existing solution(s)

Enterprise CMMS platforms (IBM Maximo, Fiix, UpKeep, MaintainX) and ad-hoc
spreadsheet/WhatsApp tracking.

## Limitation

Enterprise CMMS is too costly and complex for community scale; spreadsheets cannot link
faults → assets → parts → costs, cannot detect recurring failures, and cannot forecast the
next breakdown. In both cases, maintenance remains **reactive**.

## Proposed innovation

A database-centric system with a **predictive maintenance-risk score** computed per asset:

```
risk = (failure frequency × 10)
     + (severity penalty: Low 2 / Medium 4 / High 6 / Critical 10)
     + (recency penalty: up to 45 for a failure in the last 45 days)
     − (average condition rating × 5)
```

Implemented as a stored PL/SQL function `fn_asset_risk_score()` and surfaced through a
`v_asset_health` dashboard view that ranks every asset HIGH / MODERATE / LOW risk.

## Why this is different

- It is **predictive, not just descriptive** — it does not merely *count* past failures, it
  *ranks which asset is most likely to fail next* so a budget can be allocated before the
  failure happens.
- It is **community-scale and database-only** — the entire "intelligence" lives in SQL and
  PL/SQL, requiring no separate app infrastructure or licence.
- It is **holistic** — one system links asset, inspection, fault, request, repair, parts,
  technician, and cost, which is exactly what a spreadsheet cannot do.

## Expected improvement (measurable)

1. **Fewer emergency failures** — high-risk assets (e.g. `LIFT-BLK-A-01`) are serviced
   before the third, most dangerous failure.
2. **Lower total cost** — scheduled labour is cheaper than emergency labour; recurring-part
   failures are caught after the first repeat.
3. **Better safety** — safety-critical assets (lifts, ramps) are prioritised automatically.
4. **Predictable budgets** — cost-per-asset and risk ranking turn maintenance into a
   planned line item instead of a surprise.

## Novelty claim — supported by an existing-solution study

The gap is not "asset tracking" (solved, expensively, for enterprises) but
**predictive recurring-failure intelligence for community-scale infrastructure**, delivered
entirely through database technology — joins, nested queries, views, a scoring function and
triggers — rather than a licensed SaaS product.
