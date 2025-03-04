CREATE PROC ExamMaster
--declare all extrenal variables here
@EFirstName VARCHAR(35), @ELastName VARCHAR(35), @EDOB DATE, @ECovidStatus BIT, @EWardID INT
--table type CareTeamIDS
, @ECareTeamIDS PCareTeams READONLY
AS
--declare all internal variables
DECLARE 
@INumOfPatientsInTheWard TINYINT, @IPatientsAge INT, 
@ITodaysDate DATE = GETDATE(), @IDayOfWeek INT --sunday =1, saturday =7
, @IWardCapacity TINYINT, @IWardStatus CHAR(10), @IWardSpec CHAR(10)
--READ DATA FROM THE TABLES/ SYSTEM INTO THE INTERNAL VARIABLES
--READ DAY OF THE WEEK
SELECT @IDayOfWeek = DATENAME(WEEKDAY,@ITodaysDate)
-- READ NUMBER OF PATIENTS IN THE WARD
SELECT @INumOfPatientsInTheWard = COUNT(PatientWarD)
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

--PERFORM ALL BUSINESS LOGIC OPERATIONS HERE
--1. WARD CAPACITY RULES
-- DEFAULT VALUE FOR WARD STATUS
SET @IWardStatus = 'Available'
--IS IT A WEEKDAY
IF  (@IDayOfWeek = 1 OR @IDayOfWeek = 7)
BEGIN
    -- IS THERE A WARD CAPACITY BREACH
    IF @INumOfPatientsInTheWard >= ((@IWardCapacity * 1.2)-1)
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
IF (@IPatientsAge <=13 AND (@IWardSpec NOT LIKE '%Paediatric13%' OR @IWardSpec NOT LIKE '%Paeds 13%'))
    BEGIN
    ;THROW 50003, 'Patient is less than 13 but not assigned to "Paediatric13" or "Paeds 13"',1
    END
--CHECK MATCHES PAEDS15
ELSE IF (@IPatientsAge = 14 AND (@IWardSpec NOT LIKE '%Paediatric15%' OR @IWardSpec NOT LIKE '%Paeds 15%'))
    BEGIN
    ;THROW 50004, 'Patient is greater than 13and less than 15 but not assigned to "Paediatric15" or "Paeds 15"',1
    END
--CHECK MATCHES PAEDS
ELSE IF (@IPatientsAge >=15 AND @IPatientsAge <18 AND (@IWardSpec NOT LIKE '%Paediatric%' OR @IWardSpec NOT LIKE '%Paeds%'))
    BEGIN
    ;THROW 50005, 'Patient is greater than 14 and less than 18 but not assigned to "Paediatric" or "Paeds"',1
    END

--execute all output sub procs here
--wrap each execute in a TRY/CATCH block

--all works send out a success message