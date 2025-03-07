ALTER PROC ExamMaster
--***DECLARE ALL EXTERNAL DATA***
@EFirstName VARCHAR(35), @ELastName VARCHAR(35), @EDOB DATE, @EWardID INT, @ECareTeamID INT
, @ECovidStatus CHAR(8) --NULL IS UNKNOWN
--TABLE TYPE CARE TEAMIDS
  --@ECareTeamIDS PCareTeams READONLY
AS
--***DECLARE ALL INTERNAL VARIABLES***
DECLARE 
@INewPatientID INT
--WARD INTERNAL VARIABLES
,@INumOfPatientsInTheWard TINYINT, @IPatientsAge TINYINT
,@ITodaysDate DATE = GETDATE(), @IDayOfWeek INT --sunday =1, saturday =7
,@IWardCapacity TINYINT, @IWardStatus CHAR(10), @IWardSpec CHAR(10)
--CARE TEAM INTERNAL VARIABLES
,@INumberOfDoctorsInCareTeam TINYINT, @INumberOfNursesInCareTeam TINYINT
,@INumberOfDoctorSpecialityMatches TINYINT, @INumberOfNursesSpecialityMatches TINYINT
,@INumberOfVaccinatedDoctors TINYINT, @INumberOfVaccinatedNurses TINYINT
--NURSE INTERNAL VARIABLES
,@IRandomSelectedNurseID INT, @IRandomSelectedVaccinatedNurseID INT, @IRandomSelectedUnvaccinatedNurseID INT
,@INumberOfAvailableWardNurses TINYINT, @INumberOfAvailableVaccinatedNurses TINYINT, @INumberOfAvailableUnvaccinatedNurses TINYINT
,@ITheSelectedNurseID INT;
--CREATE TEMPORARY TABLES
CREATE TABLE #ListOfWardNurses (NurseID INT);
CREATE TABLE #ListOfVaccinatedNurses (NurseID INT);
CREATE TABLE #ListOfUnvaccinatedNurses (NurseID INT);
--***READ DATA FROM THE TABLES/ SYSTEM INTO THE INTERNAL VARIABLES***
--READ DAY OF THE WEEK
SELECT @IDayOfWeek = DATENAME(WEEKDAY,@ITodaysDate)
-- READ NUMBER OF PATIENTS IN THE WARD
SELECT @INumOfPatientsInTheWard = COUNT(*)
FROM dbo.PatientTBL 
WHERE @EWardID = PatientWarD
-- READ WARD CAPACITY
SELECT @IWardCapacity = WardCapacity
FROM DBO.WarDTBL
WHERE @EWardID = WardID
--READ PATIENT AGE
SELECT @IPatientsAge = DATEDIFF(YEAR,@EDOB,@ITodaysDate)
--READ WARD SPECIALITY
SELECT @IWardSpec = WardSpeciality
FROM dbo.WarDTBL
WHERE @EWardID = WardID
-- READ NUMBER OF DOCTORS IN CARE TEAM ID
SELECT @INumberOfDoctorsInCareTeam = COUNT(*)
FROM DBO.DoctorCareTeamMembersTBL
WHERE @ECareTeamID = CareTeamID
AND CurrentMember != 0
-- READ NUMBER OF NURSES IN CARE TEAM ID
SELECT @INumberOfNursesInCareTeam = COUNT(*)
FROM DBO.NurseCareTeamMembersTBL
WHERE @ECareTeamID = CareTeamID
AND CurrentMember !=0
-- READ NUMBER OF VACCINATED DOCTORS IN CARE TEAM
SELECT @INumberOfVaccinatedDoctors = COUNT(*)
FROM DBO.DoctorTBL D
JOIN DBO.DoctorCareTeamMembersTBL DC ON D.DoctorID = DC.MemberID
WHERE @ECareTeamID = DC.CareTeamID
AND DC.CurrentMember != 0
AND D.COVID19Vacinated = 1; 
-- READ NUMBER OF VACCINATED NURSES IN CARE TEAM
SELECT @INumberOfVaccinatedNurses = COUNT(*)
FROM DBO.NurseTBL N
JOIN DBO.NurseCareTeamMembersTBL NC ON N.NurseID = NC.MemberID
WHERE @ECareTeamID = NC.CareTeamID
AND NC.CurrentMember != 0
AND N.COVID19Vacinated = 1; 
-- READ NUMBER OF DOCTORS WHOS SPECIALITY MATCHES THAT OF THE WARD
SELECT @INumberOfDoctorSpecialityMatches = COUNT(*)
FROM dbo.DoctorTBL D
JOIN dbo.DoctorCareTeamMembersTBL DC ON D.DoctorID = DC.MemberID
WHERE @ECareTeamID = DC.CareTeamID
AND DC.CurrentMember != 0
AND LEFT(@IWardSpec, 3) = RIGHT(D.DoctorSpeciality, 3);
-- READ NUMBER OF NURSES WHOS SPECIALITY MATCHES THAT OF THE WARD
SELECT @INumberOfNursesSpecialityMatches = COUNT(*)
FROM dbo.NurseTBL N
JOIN dbo.NurseCareTeamMembersTBL NC ON N.NurseID = nc.MemberID
WHERE @ECareTeamID = NC.CareTeamID
AND NC.CurrentMember != 0
AND LEFT(@IWardSpec, 3) = RIGHT(N.NurseSpeciality, 3);
-- INSERT WARD NURSES ON LESS THAN 3 CARE TEAMS INTO #LISTOFWARDNURSES TEMP TABLE
INSERT INTO #ListOfWardNurses (NurseID)
SELECT N.NurseID
FROM DBO.NurseTBL N
LEFT JOIN DBO.NurseCareTeamMembersTBL NC ON N.NurseID = NC.MemberID
WHERE @EWardID = N.NurseWarD
GROUP BY N.NurseID
HAVING COUNT(NC.CareTeamID) < 3
-- COUNT NUMBER OF WARD NURSES
SELECT @INumberOfAvailableWardNurses = COUNT(*)
FROM #ListOfWardNurses
-- INSERT VACCINATED NURSES ASSIGNED TO NO CARETEAMS INTO #LISTOFVACCINATEDNURSES TEMP TABLE
INSERT INTO #ListOfVaccinatedNurses (NurseID)
SELECT N.NurseID
FROM DBO.NurseTBL N
LEFT JOIN DBO.NurseCareTeamMembersTBL NC ON N.NurseID = NC.MemberID
WHERE N.NurseWarD IS NULL
AND N.COVID19Vacinated = 1
GROUP BY N.NurseID
HAVING COUNT(NC.CareTeamID) = 0
--COUNT NUMBER OF VACCINATED NURSES
SELECT @INumberOfAvailableVaccinatedNurses = COUNT(*)
FROM #ListOfVaccinatedNurses
-- INSERT UNVACCINATED NURSES ASSIGNED TO NO CARETEAMS INTO #LISTOFUNVACCINATEDNURSES TEMP TABLE
INSERT INTO #ListOfUnvaccinatedNurses (NurseID)
SELECT N.NurseID
FROM DBO.NurseTBL N
LEFT JOIN DBO.NurseCareTeamMembersTBL NC ON N.NurseID = NC.MemberID
WHERE N.NurseWarD IS NULL
AND N.COVID19Vacinated = 0
GROUP BY N.NurseID
HAVING COUNT(NC.CareTeamID) = 0
--COUNT NUMBER OF UNVACCINATED NURSES
SELECT @INumberOfAvailableUnvaccinatedNurses = COUNT(*)
FROM #ListOfUnvaccinatedNurses
--RANDOMELY SELECT WARDNURSE
SELECT TOP 1 @IRandomSelectedNurseID = NurseID
FROM #ListOfWardNurses
ORDER BY NEWID()
--RANDOMELY SELECT VACCINATED NURSE
SELECT TOP 1 @IRandomSelectedVaccinatedNurseID = NurseID
FROM #ListOfVaccinatedNurses
ORDER BY NEWID()
--RANDOMELY SELECT UNVACCINATED NURSE
SELECT TOP 1 @IRandomSelectedUnvaccinatedNurseID = NurseID
FROM #ListOfUnvaccinatedNurses
ORDER BY NEWID()
--***PERFORM ALL BUSINESS LOGIC OPERATIONS HERE***
--1. WARD CAPACITY RULES
-- DEFAULT VALUE FOR WARD STATUS
SET @IWardStatus = 'Available'
--IS IT A WEEKDAY
IF (@IDayOfWeek = 1 OR @IDayOfWeek = 7)
BEGIN
    -- IS THERE A WARD CAPACITY BREACH
    IF (@INumOfPatientsInTheWard >= ((@IWardCapacity * 1.2)-1))
    BEGIN
    SET @IWardStatus = 'Overflowing'
    ;THROW 50001, 'The Ward Capacity Is Overflowing', 1
    END
END
ELSE 
BEGIN
    -- IS THERE A WARD CAPACITY BREACH
    IF @INumOfPatientsInTheWard >= (@IWardCapacity - 1)
    BEGIN
    SET @IWardStatus = 'Full'
    ;THROW 50002, 'The Ward Capacity Is Full', 1
    END
END
--2. WARD AGE RULES
--CHECK MATCHES PAEDS 13
IF (ISNULL(@IPatientsAge,0) <=13 AND (@IWardSpec NOT LIKE 'Paediatric13' OR @IWardSpec NOT LIKE 'Paeds 13'))
BEGIN
;THROW 50003, 'Patient is less than 13 but not assigned to "Paediatric13" or "Paeds 13"',1
END
--CHECK MATCHES PAEDS15
ELSE IF (@IPatientsAge = 14 AND (@IWardSpec NOT LIKE 'Paediatric15' OR @IWardSpec NOT LIKE 'Paeds 15'))
BEGIN
;THROW 50004, 'Patient is greater than 13and less than 15 but not assigned to "Paediatric15" or "Paeds 15"',1
END
--CHECK MATCHES PAEDS
ELSE IF (@IPatientsAge >=15 AND ISNULL(@IPatientsAge,0) <18 AND (@IWardSpec NOT LIKE 'Paediatric' OR @IWardSpec NOT LIKE 'Paeds'))
BEGIN
;THROW 50005, 'Patient is greater than 14 and less than 18 but not assigned to "Paediatric" or "Paeds"',1
END
--3. CARE-TEAM RULES
 SET @ITheSelectedNurseID = NULL
--CHECK IF COVID STATUS IS POSITIVE /UNKNOWN
IF(@ECovidStatus LIKE 'positive' OR @ECovidStatus IS NULL )
BEGIN
    --CHECK IF ALL DOCTORS ARE VACCINATED IN THE CARE TEAM
    IF(@INumberOfVaccinatedDoctors < @INumberOfDoctorsInCareTeam)
    BEGIN
    ;THROW 50009, 'Patient covid status is positive or unknown and not all the doctors in the care team are vaccinated', 1;
    END
    --CHECK IF ALL NURSES ARE VACCINATED IN THE CARE TEAM
    ELSE IF(@INumberOfVaccinatedNurses < @INumberOfNursesInCareTeam)
    BEGIN
    ;THROW 50010, 'Patient covid status is positive or unknown and not all the nurses in the care team are vaccinated', 1;
    END
END
--CHECK IF THERE IS AT LEAST 1 DOCTOR AND AT LEAST 2 NURSES
ELSE IF(@INumberOfDoctorsInCareTeam = 0 AND ISNULL(@INumberOfNursesInCareTeam, 0) < 2)
BEGIN
    --CHECK IF THERE IS AT LEAST 1 DOCTOR 
    IF(@INumberOfDoctorsInCareTeam = 0 )
    BEGIN
    ;THROW 50006, 'care Team Does Not Have At Least 1 Active Doctor',1
    END
    -- CHECK IF THERE IS AT LEAST 1 NURSE
    ELSE IF(@INumberOfNursesInCareTeam = 0 )
    BEGIN
    ;THROW 50006, 'care Team Does Not Have At Least 1 Active Nurse',1
    END
    -- CHECK IF THERE IS AN AVAILABLE NURSE
    -- ASSIGN A NURSE TO CARE TEAM WHO IS ASSIGNED TO SAME WARD
    IF (@INumberOfAvailableWardNurses > 0)
    BEGIN
    SET @ITheSelectedNurseID = @IRandomSelectedNurseID
    END
    -- ASSIGN A VACCINATED NURSE TO CARE TEAM
    ELSE IF ((@ECovidStatus LIKE 'positive' OR @ECovidStatus IS NULL) AND @INumberOfAvailableVaccinatedNurses > 0)
    BEGIN
    SET @ITheSelectedNurseID = @IRandomSelectedVaccinatedNurseID
    END
    -- ASSIGN AN UNVACCINATED NURSE TO CARE TEAM
    ELSE IF (@ECovidStatus LIKE 'negative') AND @INumberOfAvailableUnvaccinatedNurses > 0
    BEGIN
    SET @ITheSelectedNurseID = @IRandomSelectedUnvaccinatedNurseID
    END
    ELSE
    BEGIN
    ;THROW 50011, 'No Available Nurse To Add To The Care Team', 1
    END
END
-- CHECK THAT AT LEAST 1 DOCTOR HAS SPECIALITY OF WARD
IF(@INumberOfDoctorSpecialityMatches = 0)
BEGIN
;THROW 50007, 'Care Team Does Not Have At Least One Active Doctor With The Ward Speciality', 1;
END
-- CHECK THAT AT LEAST 1 NURSE HAS SPECIALITY OF WARD
ELSE IF (@INumberOfNursesSpecialityMatches = 0)
BEGIN
;THROW 50008, 'Care Team Does Not Have At Least One Active Nurse With The Ward Speciality', 1;
END
--***EXECUTE SUBSPROCS***
--EXECUTE INSERT PATIENT SUBSPROC
BEGIN TRY
EXEC test2000.InsertPatient @EFirstName, @ELastName, @EWardID, @ECovidStatus, @OpatientNum = @INewPatientID OUTPUT
END TRY
BEGIN CATCH
;THROW
END CATCH
--EXECUTE INSERT PATIENT INTO CARE TEAM SUBSPROC

--***ALL WORKS, SEND OUT A SUCCESS MESSAGE***
