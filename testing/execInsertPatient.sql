DECLARE @NewPatientID INT;

EXEC InsertPatient
    @EpFirstName = 'Oliver',
    @EpLastName = 'Smith',
    @EpWardID = 3,  -- Assigning to Paeds13 Ward
    @EpCovidStatus = 'Negative',
    @OpatientNum = @NewPatientID OUTPUT;

-- Check the new patient inserted
SELECT @NewPatientID AS NewPatientID;
