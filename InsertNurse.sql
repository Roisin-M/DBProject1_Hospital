CREATE PROC InsertNurse
@EncDateJoined SMALLDATETIME,
@EncCurrentMember BIT,
@OCareTeamID INT OUTPUT,
@OMemberID INT OUTPUT
AS
--insert values into Nurse Care Team Members
BEGIN TRY
INSERT into dbo.NurseCareTeamMembersTBL
(DateJoineD, CurrentMember)
VALUES
(@EncDateJoined, @EncCurrentMember)
-- output the newly generated careteam ID and member ID
SELECT @OCareTeamID = SCOPE_IDENTITY(), @OMemberID = SCOPE_IDENTITY()
END TRY
BEGIN CATCH
;THROW
END CATCH