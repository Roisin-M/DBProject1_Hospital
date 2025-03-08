ALTER PROC InsertToCareTeam
@EpPatientID INT,
@EpCareTeamID INT,
@EExistingCareTeamPatientID INT
AS
--CHECK THERE ISN'T ALREADY A PATIENT ASSIGNED TO THE CARETEAM
IF(@EExistingCareTeamPatientID IS NULL)
BEGIN
    BEGIN TRY
    INSERT into dbo.CareTeamTBL
    (CareTeamID, PatientID)
    VALUES
    (@EpCareTeamID, @EpPatientID)
    END TRY
    BEGIN CATCH
    ;THROW 50013, 'Failed To Assign Patient To Care Team', 1
    END CATCH
END
ELSE
BEGIN
;THROW 50014, 'This Care Team Already Has a Patient Assigned', 1;
END