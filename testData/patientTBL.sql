INSERT INTO dbo.PatientTBL (PatientFname, PatientLname, PatientWarD, PatientDependency, PatientCOVIDStatus)
VALUES
('John', 'Doe', 3, 'None', 'Negative'),    -- Age <13 (Paeds13)
('Emma', 'White', 4, 'None', 'Positive'),  -- Age 14 (Paeds15)
('Liam', 'Brown', 5, 'None', NULL),   -- Age 16 (Paediatric)
('Sophia', 'Johnson', 6, 'None', 'Negative'), -- General ward (Cardiology)
('Mason', 'Davis', 7, 'None', 'Negative');  -- General ward (Neurology)
