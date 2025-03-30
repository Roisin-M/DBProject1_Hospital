ALTER PROC InsertToCareTeam
@EpCareTeamID INT,
@EpPatientID INT
AS
BEGIN TRY
INSERT into dbo.CareTeamTBL
(CareTeamID, PatientID)
VALUES
(@EpCareTeamID, @EpPatientID)
END TRY
BEGIN CATCH
;THROW 
END CATCH