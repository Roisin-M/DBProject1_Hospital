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
, @IWardCapacity TINYINT
--READ DATA FROM THE TABLES/ SYSTEM INTO THE INTERNAL VARIABLES
--READ DAY OF THE WEEK
SELECT @IDayOfWeek = DATENAME(DW,@ITodaysDate)
-- READ NUMBER OF PATIENTS IN THE WARD
SELECT @INumOfPatientsInTheWard = COUNT(PatientWarD)
FROM dbo.PatientTBL 
WHERE @EWardID = PatientWarD
-- READ WARD CAPACITY
SELECT @IWardCapacity = WardCapacity
FROM DBO.WarDTBL
WHERE @EWardID = WardID

--PERFORM ALL BUSINESS LOGIC OPERATIONS HERE
--IS IT A WEEKDAY
IF  (@IDayOfWeek = 1 OR @IDayOfWeek = 7)
BEGIN
    -- IS THERE A WARD CAPACITY BREACH
    IF @INumOfPatientsInTheWard >= ((@IWardCapacity * 1.2)-1)
    BEGIN
    ;THROW 50001, 'The Ward Capacity Is Overflowing', 1
    END
END
ELSE 
BEGIN
    -- IS THERE A WARD CAPACITY BREACH
    IF @INumOfPatientsInTheWard >= (@IWardCapacity - 1)
    BEGIN
    ;THROW 50002, 'The Ward Capacity Is Full', 1
    END
END

--execute all output sub procs here
--wrap each execute in a TRY/CATCH block

--all works send out a success message