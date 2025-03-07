INSERT INTO dbo.DoctorTBL (DoctorName, DoctorSpeciality, DoctorBleepID, COVID19Vacinated)
VALUES
('Dr. Henry Adams', 'NeoPaeds13', 'B001', 1),   -- Matches "Paeds13" Ward
('Dr. Olivia Taylor', 'NeoPaeds15', 'B002', 1), -- Matches "Paeds15" Ward
('Dr. Ethan Carter', 'NeoPaediatric', 'B003', 0), -- Matches "Paediatric" Ward
('Dr. Daniel King', 'EndCardio', 'B004', 1),  -- Matches "Cardiology" Ward
('Dr. Ava Mitchell', 'EndNeuro', 'B005', NULL); -- Matches "Neurology" Ward
