DECLARE @NewCareTeamID INT;

EXEC InsertToCareTeam
    @EpPatientID = 6,
    @EcDateFormed = '2025-03-07',
    @EcDateFinished = NULL,
    @OCareTeamID = @NewCareTeamID OUTPUT;

-- Check the generated CareTeamID
SELECT @NewCareTeamID AS NewCareTeamID;