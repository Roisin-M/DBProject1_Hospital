ALTER PROC InsertNurse
@ENurseID INT,
@EpCareTeamID INT
AS
--INSERT VALUES INTO NURSECARETEAM TBL
BEGIN TRY
INSERT into dbo.NurseCareTeamMembersTBL
(MemberID, CareTeamID)
VALUES
(@ENurseID, @EpCareTeamID)
END TRY
BEGIN CATCH
;THROW 50016, 'Failed to Assign Nurse to Care Team', 1;
END CATCH