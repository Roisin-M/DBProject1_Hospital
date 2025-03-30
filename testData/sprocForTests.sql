CREATE PROCEDURE Test_ExamMaster_Combined
AS
BEGIN

    -- Test 1: Valid Case 
    EXEC ExamMaster 
        @EFirstName = 'Valid', 
        @ELastName = 'Test',
        @EDOB = '2011-05-15', 
        @EWardID = 9, 
        @ECareTeamID = 2, 
        @ECovidStatus = 'Negative';

    -- Test 2: Ward Capacity Full
    EXEC ExamMaster 
        @EFirstName = 'Capacity', 
        @ELastName = 'Test',
        @EDOB = '2015-01-01', 
        @EWardID = 10, 
        @ECareTeamID = 3, 
        @ECovidStatus = 'Positive';

    -- Test 3: Incompatible Speciality for Patient
    EXEC ExamMaster 
        @EFirstName = 'Speciality', 
        @ELastName = 'Mismatch',
        @EDOB = '2005-09-21', 
        @EWardID = 9, 
        @ECareTeamID = 4, 
        @ECovidStatus = 'Negative';

    -- Test 4: CareTeam Without a Doctor
    EXEC ExamMaster 
        @EFirstName = 'Missing', 
        @ELastName = 'Doctor',
        @EDOB = '2007-03-03', 
        @EWardID = 3, 
        @ECareTeamID = 3, 
        @ECovidStatus = 'Unknown';

    -- Test 5: COVID Positive Patient with Unvaccinated Doctor in Care Team
    EXEC ExamMaster 
        @EFirstName = 'CovidPos', 
        @ELastName = 'UnvaccinatedDoc',
        @EDOB = '2000-11-11', 
        @EWardID = 11, 
        @ECareTeamID = 2, 
        @ECovidStatus = 'Positive';
END
