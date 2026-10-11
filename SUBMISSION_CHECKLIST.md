# AssetCare — Final Submission Checklist

This maps everything to the single-PDF requirement and tells you exactly what to
capture, record, and compile.

---

## 1. The 8 deliverables → your files

| # | Required section | Source |
|---|---|---|
| 1 | Problem Discovery Report | `docs/01_problem_discovery.md` |
| 2 | Innovation Proposal | `docs/02_innovation_proposal.md` |
| 3 | Software Requirements | `docs/05_software_requirements.md` |
| 4 | Database Design (ER/EER, schema, normalization, constraints) | `docs/ER_diagram.md` + `docs/04_normalization.md` + `schema.sql` |
| 5 | Application Prototype | `docs/07_application_prototype.md` + `dashboard.html` |
| 6 | Testing & Validation | `docs/06_testing_validation.md` |
| 7 | Impact & TRL Report | `docs/03_impact_TRL.md` |
| 8 | Screenshots of the Demo | see below |

## 2. Screenshots to capture (Deliverable 8)

Take these, in order, and drop them into the PDF:

1. **Dashboard full page** — open `dashboard.html` in Chrome → full-page screenshot
   (F12 → Ctrl+Shift+P → "Capture full size screenshot").
2. **Risk ranking table** — zoomed crop of the "Predicted Failure Risk" table.
3. **Charts** — severity doughnut + spend-by-asset bar (crop the two chart cards).
4. **Schema run** — SQL*Plus showing `@schema.sql` → "Table created" × 12 + "Index created" × 16.
5. **A complex query** — e.g. the 8-table lifecycle join or the recurring-failure query output.
6. **The predictive view** — `SELECT * FROM v_asset_health ORDER BY risk_score DESC;`
7. **Transaction demo** — the ROLLBACK showing stock unchanged before/after.
8. **Role-based access** — log in as `demo_resident` and show the `ORA-01031` rejection.

## 3. Video demonstration (recorded link)

- 2–3 minutes, screen-record (OBS / Xbox Game Bar Win+G / phone).
- Script: (1) problem in one line, (2) open `dashboard.html` and point at the risk
  ranking, (3) run 2–3 SQL queries in SQL*Plus (recurring-failure, risk view, rollback),
  (4) show the audit trigger or role rejection, (5) one-line impact.
- Upload to YouTube/Drive (unlisted) → paste the link into the PDF.

## 4. GitHub repository (optional — only if time)

```bash
cd /mnt/c/Users/Saatvika/Desktop/PROJECTS/AssestCare
git init && git add . && git commit -m "AssetCare DBMS project"
# create an empty repo on github.com, then:
git remote add origin https://github.com/<your-user>/assetcare.git
git push -u origin main
```
Not required. The document says "if available" — skip it if it risks your deadline.

## 5. Compile to a single PDF

Fastest path (Word/Google Docs):
1. Paste the 8 sections above, in order, into one Google Doc or Word file.
2. Insert the screenshots at the matching places.
3. Add a title page: project name, team members + reg. numbers, course, date.
4. Add the video link (and GitHub link) on the title page.
5. Export → PDF.

Alternative: build a single `report.html` and use browser "Print → Save as PDF".

## 6. Final consistency check (the rubric asks for this)

- [ ] The formula in `02_innovation_proposal.md` matches `fn_asset_risk_score` (it does — includes the unresolved-fault penalty).
- [ ] Dashboard numbers match your SQL*Plus output (risk ranking, spend, open requests).
- [ ] ER diagram matches `schema.sql` (13 entities incl. `Asset_Audit`).
- [ ] Test results in `06_testing_validation.md` match what actually ran.
- [ ] All links open (video, GitHub).
- [ ] Team member contributions are stated (Deepak — Asset Management; Saatvika — Maintenance Workflow; Sharan — DB Design & Analytics).
