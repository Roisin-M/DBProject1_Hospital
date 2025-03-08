
ALTER TABLE dbo.CareTeamTBL
ADD CONSTRAINT UQ_CareTeam_Patient UNIQUE (CareTeamID, PatientID);
