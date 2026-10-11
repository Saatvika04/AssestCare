-- ============================================================================
-- AssetCare — Sample / reference data (Oracle 11g+)
-- Run AFTER schema.sql. Uses explicit IDs so foreign keys are deterministic.
-- The dataset is designed to exercise all three workflows, including a
-- recurring-failure asset (Lift A fails 3x, same motor part twice) and a
-- long-duration repair, so the analytics reports return meaningful results.
-- ============================================================================

-- ---------------------------------------------------------------- AssetType
INSERT INTO AssetType (asset_type_id, type_name, category, expected_life_years, inspection_interval_days) VALUES
 (1, 'Lift',                'Vertical Transport', 20, 90);
INSERT INTO AssetType (asset_type_id, type_name, category, expected_life_years, inspection_interval_days) VALUES
 (2, 'Water Dispenser',     'Water',               8, 30);
INSERT INTO AssetType (asset_type_id, type_name, category, expected_life_years, inspection_interval_days) VALUES
 (3, 'Streetlight',         'Electrical',         15, 90);
INSERT INTO AssetType (asset_type_id, type_name, category, expected_life_years, inspection_interval_days) VALUES
 (4, 'Accessibility Ramp',  'Accessibility',      25, 120);
INSERT INTO AssetType (asset_type_id, type_name, category, expected_life_years, inspection_interval_days) VALUES
 (5, 'Generator',           'Electrical',         15, 60);
INSERT INTO AssetType (asset_type_id, type_name, category, expected_life_years, inspection_interval_days) VALUES
 (6, 'HVAC',                'Mechanical',         10, 60);

-- ---------------------------------------------------------------- Location
INSERT INTO Location (location_id, building, floor_level, area, city) VALUES
 (1, 'Block A',         'GF', 'Main Lobby',      'Vellore');
INSERT INTO Location (location_id, building, floor_level, area, city) VALUES
 (2, 'Block B',         'GF', 'Main Lobby',      'Vellore');
INSERT INTO Location (location_id, building, floor_level, area, city) VALUES
 (3, 'Central Library', 'GF', 'Entrance',        'Vellore');
INSERT INTO Location (location_id, building, floor_level, area, city) VALUES
 (4, 'Sports Complex',  'GF', 'Gymnasium',       'Vellore');
INSERT INTO Location (location_id, building, floor_level, area, city) VALUES
 (5, 'Main Gate',       NULL, 'Entrance Plaza',  'Vellore');
INSERT INTO Location (location_id, building, floor_level, area, city) VALUES
 (6, 'Community Park',  NULL, 'East Walkway',    'Vellore');
INSERT INTO Location (location_id, building, floor_level, area, city) VALUES
 (7, 'Community Hall',  'GF', 'Main Hall',       'Vellore');

-- ---------------------------------------------------------------- Custodian
INSERT INTO Custodian (custodian_id, full_name, department, phone, email) VALUES
 (1, 'Ramesh Kumar',   'Facilities',  '9000011111', 'ramesh.k@vit.ac.in');
INSERT INTO Custodian (custodian_id, full_name, department, phone, email) VALUES
 (2, 'Priya Nair',     'Facilities',  '9000022222', 'priya.n@vit.ac.in');
INSERT INTO Custodian (custodian_id, full_name, department, phone, email) VALUES
 (3, 'Arjun Menon',    'Estate Office','9000033333', 'arjun.m@vit.ac.in');
INSERT INTO Custodian (custodian_id, full_name, department, phone, email) VALUES
 (4, 'Lakshmi Rao',    'Admin',       '9000044444', 'lakshmi.r@vit.ac.in');
INSERT INTO Custodian (custodian_id, full_name, department, phone, email) VALUES
 (5, 'Facilities Desk','Facilities',  '9000055555', 'helpdesk@vit.ac.in');

-- ---------------------------------------------------------------- AssetStatus
INSERT INTO AssetStatus (status_id, status_name, description) VALUES
 (1, 'Active',            'In normal service');
INSERT INTO AssetStatus (status_id, status_name, description) VALUES
 (2, 'Under Repair',      'Fault logged, repair in progress');
INSERT INTO AssetStatus (status_id, status_name, description) VALUES
 (3, 'Out of Service',    'Unavailable, pending major repair');
INSERT INTO AssetStatus (status_id, status_name, description) VALUES
 (4, 'Retired',           'Decommissioned');
INSERT INTO AssetStatus (status_id, status_name, description) VALUES
 (5, 'Pending Inspection','Awaiting scheduled inspection');

-- ---------------------------------------------------------------- Technician
INSERT INTO Technician (technician_id, full_name, specialization, phone, email, is_available) VALUES
 (1, 'Suresh Babu',   'Electrical',  '9001010101', 'suresh.b@vit.ac.in', 1);
INSERT INTO Technician (technician_id, full_name, specialization, phone, email, is_available) VALUES
 (2, 'Manoj Kumar',   'Mechanical',  '9001020202', 'manoj.k@vit.ac.in',  1);
INSERT INTO Technician (technician_id, full_name, specialization, phone, email, is_available) VALUES
 (3, 'Karthik Raja',  'Plumbing',    '9001030303', 'karthik.r@vit.ac.in', 1);
INSERT INTO Technician (technician_id, full_name, specialization, phone, email, is_available) VALUES
 (4, 'Vinod Pillai',  'Electrical',  '9001040404', 'vinod.p@vit.ac.in',  1);
INSERT INTO Technician (technician_id, full_name, specialization, phone, email, is_available) VALUES
 (5, 'Anand Krishnan','General',     '9001050505', 'anand.k@vit.ac.in',  1);
INSERT INTO Technician (technician_id, full_name, specialization, phone, email, is_available) VALUES
 (6, 'Rafiq Ahmed',   'Mechanical',  '9001060606', 'rafiq.a@vit.ac.in',  0);

-- ---------------------------------------------------------------- SparePart
INSERT INTO SparePart (part_id, part_name, category, unit_cost, stock_qty, reorder_level, supplier) VALUES
 (1, 'Lift Motor 15kW',          'Mechanical', 45000.00,  3,  1, 'Otis Spares');
INSERT INTO SparePart (part_id, part_name, category, unit_cost, stock_qty, reorder_level, supplier) VALUES
 (2, 'Water Filter Cartridge',   'Water',       1500.00, 40, 10, 'AquaPure');
INSERT INTO SparePart (part_id, part_name, category, unit_cost, stock_qty, reorder_level, supplier) VALUES
 (3, 'LED Streetlight Bulb 60W', 'Electrical',   800.00, 60, 15, 'Philips');
INSERT INTO SparePart (part_id, part_name, category, unit_cost, stock_qty, reorder_level, supplier) VALUES
 (4, 'LED Driver / Ballast',     'Electrical',  1200.00, 25,  8, 'Philips');
INSERT INTO SparePart (part_id, part_name, category, unit_cost, stock_qty, reorder_level, supplier) VALUES
 (5, 'Ramp Anchor Bolt Kit',     'Accessibility',950.00, 20,  5, 'SteelCo');
INSERT INTO SparePart (part_id, part_name, category, unit_cost, stock_qty, reorder_level, supplier) VALUES
 (6, 'Generator Battery 12V',    'Electrical',  6500.00,  4,  1, 'Exide');
INSERT INTO SparePart (part_id, part_name, category, unit_cost, stock_qty, reorder_level, supplier) VALUES
 (7, 'HVAC Compressor',          'Mechanical', 28000.00,  2,  1, 'BlueStar');
INSERT INTO SparePart (part_id, part_name, category, unit_cost, stock_qty, reorder_level, supplier) VALUES
 (8, 'Lift Door Sensor',         'Electrical',  5200.00,  5,  2, 'Otis Spares');

-- ---------------------------------------------------------------- Asset
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (1,  'LIFT-BLK-A-01', 'Block A Passenger Lift',      1, 1, 1, 1, 'L-A-2018-01',   DATE '2018-06-15', 850000.00);
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (2,  'LIFT-BLK-B-01', 'Block B Passenger Lift',      1, 2, 2, 1, 'L-B-2019-02',   DATE '2019-03-10', 850000.00);
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (3,  'WD-LIB-01',     'Library Water Dispenser',     2, 3, 1, 1, 'WD-2021-11',    DATE '2021-01-20',  45000.00);
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (4,  'WD-GYM-01',     'Gym Water Dispenser',         2, 4, 3, 2, 'WD-2020-07',    DATE '2020-08-05',  42000.00);
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (5,  'SL-MG-01',      'Main Gate Streetlight',       3, 5, 2, 1, 'SL-2017-31',    DATE '2017-02-14',  18000.00);
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (6,  'SL-PARK-01',    'Park Pathway Streetlight',    3, 6, 2, 1, 'SL-2017-42',    DATE '2017-05-22',  18000.00);
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (7,  'RAMP-LIB-01',   'Library Accessibility Ramp',  4, 3, 1, 1, 'RM-2019-03',    DATE '2019-09-01', 120000.00);
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (8,  'RAMP-COM-01',   'Community Hall Ramp',         4, 7, 3, 3, 'RM-2016-08',    DATE '2016-11-12', 120000.00);
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (9,  'GEN-CH-01',     'Community Hall Generator',    5, 7, 3, 1, 'GN-2015-05',    DATE '2015-04-30', 350000.00);
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (10, 'AC-LIB-01',     'Library HVAC',                6, 3, 1, 2, 'AC-2019-17',    DATE '2019-07-18', 200000.00);
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (11, 'LIFT-LIB-01',   'Library Service Lift',        1, 3, 1, 1, 'L-L-2020-04',   DATE '2020-02-25', 700000.00);
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (12, 'WD-CH-01',      'Community Hall Water Disp',   2, 7, 3, 1, 'WD-2022-02',    DATE '2022-03-08',  40000.00);
INSERT INTO Asset (asset_id, asset_code, asset_name, asset_type_id, location_id, custodian_id, status_id, serial_number, install_date, purchase_cost) VALUES
 (13, 'LIFT-BLK-C-01', 'Block C Retired Lift',        1, 1, 4, 4, 'L-C-2005-01',   DATE '2005-01-01', 600000.00);

-- ---------------------------------------------------------------- Inspection
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (1,  1,  DATE '2026-01-15', 'Deepak James', 'Routine',          2, 'Door mechanism worn, slow closing',     DATE '2026-04-15');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (2,  3,  DATE '2026-01-10', 'Deepak James', 'Routine',          4, 'Clean, filter fine',                    DATE '2026-02-10');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (3,  5,  DATE '2026-03-12', 'Deepak James', 'Complaint-driven', 3, 'Bulb blown at main gate',               DATE '2026-06-12');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (4,  1,  DATE '2026-04-20', 'Deepak James', 'Scheduled',        2, 'Jerky movement between floors',         DATE '2026-07-20');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (5,  2,  DATE '2026-04-25', 'Deepak James', 'Routine',          5, 'No issues',                             DATE '2026-07-25');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (6,  6,  DATE '2026-02-05', 'Deepak James', 'Routine',          3, 'Light flickering intermittently',       DATE '2026-05-05');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (7,  1,  DATE '2026-08-10', 'Deepak James', 'Complaint-driven', 1, 'Lift stuck at 2nd floor, alarm active', DATE '2026-11-10');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (8,  6,  DATE '2026-06-18', 'Deepak James', 'Complaint-driven', 2, 'Light out at night',                    DATE '2026-09-18');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (9,  8,  DATE '2026-05-10', 'Deepak James', 'Routine',          1, 'Handrail broken, unsafe for use',       DATE '2026-08-10');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (10, 9,  DATE '2026-02-25', 'Deepak James', 'Scheduled',        2, 'Fails to start on battery',             DATE '2026-05-25');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (11, 11, DATE '2026-08-22', 'Deepak James', 'Complaint-driven', 2, 'Door sensor intermittent',              DATE '2026-11-22');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (12, 4,  DATE '2026-09-01', 'Deepak James', 'Complaint-driven', 2, 'No cold water, compressor humming',     DATE '2026-10-01');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (13, 10, DATE '2026-09-20', 'Deepak James', 'Complaint-driven', 2, 'Not cooling, compressor suspected',     DATE '2026-10-20');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (14, 3,  DATE '2026-07-05', 'Deepak James', 'Routine',          3, 'Filter due for replacement',            DATE '2026-08-05');
INSERT INTO Inspection (inspection_id, asset_id, inspection_date, inspector_name, inspection_type, condition_rating, findings, next_due_date) VALUES
 (15, 7,  DATE '2026-06-01', 'Deepak James', 'Routine',          5, 'No issues',                             DATE '2026-09-01');

-- ---------------------------------------------------------------- Fault
INSERT INTO Fault (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status) VALUES
 (1,  1,  1,  DATE '2026-01-15', 'Inspector', 'Lift doors not closing fully',                        'High',     'Resolved');
INSERT INTO Fault (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status) VALUES
 (2,  1,  4,  DATE '2026-04-20', 'Inspector', 'Lift jerks violently between floors',                'High',     'Resolved');
INSERT INTO Fault (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status) VALUES
 (3,  1,  7,  DATE '2026-08-10', 'Resident',  'Lift stuck at 2nd floor, passengers alarmed',        'Critical', 'Resolved');
INSERT INTO Fault (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status) VALUES
 (4,  6,  6,  DATE '2026-02-05', 'Inspector', 'Park streetlight flickering',                        'Medium',   'Resolved');
INSERT INTO Fault (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status) VALUES
 (5,  6,  NULL, DATE '2026-06-18', 'Resident', 'Park streetlight not working at night',             'Medium',   'Resolved');
INSERT INTO Fault (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status) VALUES
 (6,  4,  NULL, DATE '2026-09-01', 'Resident', 'Gym water dispenser gives no cold water',           'Medium',   'In Progress');
INSERT INTO Fault (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status) VALUES
 (7,  8,  9,  DATE '2026-05-10', 'Inspector', 'Community Hall ramp handrail broken, unsafe',       'Critical', 'In Progress');
INSERT INTO Fault (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status) VALUES
 (8,  10, 13, DATE '2026-09-20', 'Inspector', 'Library HVAC not cooling, compressor failure',       'High',     'In Progress');
INSERT INTO Fault (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status) VALUES
 (9,  5,  3,  DATE '2026-03-12', 'Inspector', 'Main gate streetlight bulb blown',                   'Low',      'Resolved');
INSERT INTO Fault (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status) VALUES
 (10, 3,  14, DATE '2026-07-05', 'Inspector', 'Library dispenser filter needs replacement',         'Low',      'Resolved');
INSERT INTO Fault (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status) VALUES
 (11, 9,  10, DATE '2026-02-25', 'Inspector', 'Generator fails to start on battery',                'High',     'Resolved');
INSERT INTO Fault (fault_id, asset_id, inspection_id, reported_date, reported_by, description, severity, fault_status) VALUES
 (12, 11, 11, DATE '2026-08-22', 'Inspector', 'Library service lift door sensor intermittent',      'Medium',   'Open');

-- ---------------------------------------------------------------- MaintenanceRequest
INSERT INTO MaintenanceRequest (request_id, fault_id, technician_id, request_date, priority, request_status) VALUES
 (1,  1,  2, DATE '2026-01-15', 'High',     'Completed');
INSERT INTO MaintenanceRequest (request_id, fault_id, technician_id, request_date, priority, request_status) VALUES
 (2,  2,  2, DATE '2026-04-20', 'High',     'Completed');
INSERT INTO MaintenanceRequest (request_id, fault_id, technician_id, request_date, priority, request_status) VALUES
 (3,  3,  2, DATE '2026-08-10', 'Urgent',   'Completed');
INSERT INTO MaintenanceRequest (request_id, fault_id, technician_id, request_date, priority, request_status) VALUES
 (4,  4,  1, DATE '2026-02-05', 'Medium',   'Completed');
INSERT INTO MaintenanceRequest (request_id, fault_id, technician_id, request_date, priority, request_status) VALUES
 (5,  5,  1, DATE '2026-06-18', 'Medium',   'Completed');
INSERT INTO MaintenanceRequest (request_id, fault_id, technician_id, request_date, priority, request_status) VALUES
 (6,  6,  3, DATE '2026-09-01', 'Medium',   'In Progress');
INSERT INTO MaintenanceRequest (request_id, fault_id, technician_id, request_date, priority, request_status) VALUES
 (7,  7,  5, DATE '2026-05-10', 'Urgent',   'Completed');
INSERT INTO MaintenanceRequest (request_id, fault_id, technician_id, request_date, priority, request_status) VALUES
 (8,  8,  6, DATE '2026-09-20', 'High',     'In Progress');
INSERT INTO MaintenanceRequest (request_id, fault_id, technician_id, request_date, priority, request_status) VALUES
 (9,  9,  1, DATE '2026-03-12', 'Low',      'Completed');
INSERT INTO MaintenanceRequest (request_id, fault_id, technician_id, request_date, priority, request_status) VALUES
 (10, 10, 3, DATE '2026-07-05', 'Low',      'Completed');
INSERT INTO MaintenanceRequest (request_id, fault_id, technician_id, request_date, priority, request_status) VALUES
 (11, 11, 4, DATE '2026-02-25', 'High',     'Completed');
INSERT INTO MaintenanceRequest (request_id, fault_id, technician_id, request_date, priority, request_status) VALUES
 (12, 12, NULL, DATE '2026-08-22', 'Medium', 'Pending');

-- ---------------------------------------------------------------- Repair
INSERT INTO Repair (repair_id, request_id, technician_id, start_date, end_date, labour_cost, outcome, notes) VALUES
 (1,  1,  2, DATE '2026-01-16', DATE '2026-01-18',  2500.00, 'Completed',           'Adjusted door mechanism, replaced sensor');
INSERT INTO Repair (repair_id, request_id, technician_id, start_date, end_date, labour_cost, outcome, notes) VALUES
 (2,  2,  2, DATE '2026-04-21', DATE '2026-04-25',  6000.00, 'Partially Completed', 'Motor replaced but jerk persists');
INSERT INTO Repair (repair_id, request_id, technician_id, start_date, end_date, labour_cost, outcome, notes) VALUES
 (3,  3,  2, DATE '2026-08-11', DATE '2026-08-20', 12000.00, 'Completed',           'Full motor + sensor replacement, 9-day job');
INSERT INTO Repair (repair_id, request_id, technician_id, start_date, end_date, labour_cost, outcome, notes) VALUES
 (4,  4,  1, DATE '2026-02-06', DATE '2026-02-06',   400.00, 'Completed',           'Replaced LED driver/ballast');
INSERT INTO Repair (repair_id, request_id, technician_id, start_date, end_date, labour_cost, outcome, notes) VALUES
 (5,  5,  1, DATE '2026-06-19', DATE '2026-06-19',   400.00, 'Completed',           'Replaced LED bulb');
INSERT INTO Repair (repair_id, request_id, technician_id, start_date, end_date, labour_cost, outcome, notes) VALUES
 (6,  7,  5, DATE '2026-05-11', DATE '2026-05-15',  3500.00, 'Partially Completed', 'Bolts replaced, structure still unsafe');
INSERT INTO Repair (repair_id, request_id, technician_id, start_date, end_date, labour_cost, outcome, notes) VALUES
 (7,  9,  1, DATE '2026-03-12', DATE '2026-03-12',   300.00, 'Completed',           'Replaced LED bulb');
INSERT INTO Repair (repair_id, request_id, technician_id, start_date, end_date, labour_cost, outcome, notes) VALUES
 (8,  10, 3, DATE '2026-07-05', DATE '2026-07-05',   600.00, 'Completed',           'Replaced water filter cartridge');
INSERT INTO Repair (repair_id, request_id, technician_id, start_date, end_date, labour_cost, outcome, notes) VALUES
 (9,  11, 4, DATE '2026-02-26', DATE '2026-02-28',  4500.00, 'Replaced',            'Battery replaced');

-- ---------------------------------------------------------------- RepairHistory (parts used per repair)
INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair) VALUES
 (1,  1, 8, 1, 5200.00);
INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair) VALUES
 (2,  2, 1, 1, 45000.00);
INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair) VALUES
 (3,  3, 1, 1, 45000.00);
INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair) VALUES
 (4,  3, 8, 1, 5200.00);
INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair) VALUES
 (5,  4, 4, 1, 1200.00);
INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair) VALUES
 (6,  5, 3, 1,  800.00);
INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair) VALUES
 (7,  6, 5, 2,  950.00);
INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair) VALUES
 (8,  7, 3, 1,  800.00);
INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair) VALUES
 (9,  8, 2, 1, 1500.00);
INSERT INTO RepairHistory (repair_history_id, repair_id, part_id, quantity_used, unit_cost_at_repair) VALUES
 (10, 9, 6, 1, 6500.00);
