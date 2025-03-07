INSERT INTO dbo.NurseCareTeamMembersTBL (CareTeamID, MemberID, DateJoineD, CurrentMember)
VALUES
(1, 100000, '2024-03-01', 1),  -- Nurse Alice Green (NeoPaeds13) → Ward Paeds13
(1, 100001, '2024-03-01', 1),  -- Nurse Noah Black (NeoPaeds15) → Extra Nurse
(2, 100001, '2024-03-02', 1),  -- Nurse Noah Black (NeoPaeds15) → Ward Paeds15
(2, 100002, '2024-03-02', 1),  -- Nurse Mia Clark (NeoPaediatric) → Extra Nurse
(3, 100002, '2024-03-03', 1),  -- Nurse Mia Clark (NeoPaediatric) → Ward Paediatric
(3, 100003, '2024-03-03', 1),  -- Nurse James Hill (EndCardio) → Extra Nurse
(4, 100003, '2024-03-04', 1),  -- Nurse James Hill (EndCardio) → Ward Cardiology
(4, 100004, '2024-03-04', 1),  -- Nurse Emily Roberts (EndNeuro) → Extra Nurse
(5, 100004, '2024-03-05', 1),  -- Nurse Emily Roberts (EndNeuro) → Ward Neurology
(5, 100000, '2024-03-05', 1);  -- Nurse Alice Green (NeoPaeds13) → Extra Nurse
