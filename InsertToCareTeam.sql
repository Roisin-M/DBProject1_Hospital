CREATE PROC InsertToCareTeam
@EpPatientID INT,
@EcDateFormed DATE,
@EcDateFinished DATE,
@OCareTeamID INT OUTPUT
AS
--insert values into Care Team Table
BEGIN TRY
INSERT into dbo.CareTeamTBL
(PatientID, DateFormed, DateFinished)
VALUES
(@EpPatientID, @EcDateFormed, @EcDateFinished)
-- output the newly generated careteam ID
SELECT @OCareTeamID = SCOPE_IDENTITY()
END TRY
BEGIN CATCH
;THROW
END CATCH