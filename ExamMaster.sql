CREATE PROC ExamMaster
--declare all extrenal variables here
@EFirstName VARCHAR(35), @ELastName VARCHAR(35), @EDOB DATE, @ECovidStatus BIT, @EWardID INT
--table type CareTeamIDS
, @ECareTeamIDS PCareTeams READONLY
AS
--declare all internal variables
DECLARE 
@INumOfPatientsInTheWard INT, @IPatientsAge INT, 
@ITodaysDate DATE = GETDATE(), @IDayOfWeek INT --sunday =1, saturday =7
--READ DATA FROM THE TABLES/ SYSTEM INTO THE INTERNAL VARIABLES
--READ DAY OF THE WEEK
SELECT @IDayOfWeek = DATENAME(DW,@ITodaysDate)
-- READ NUMBER OF PATIENTS IN THE WARD
SELECT @INumOfPatientsInTheWard = COUNT(PatientWarD)
FROM dbo.PatientTBL 
WHERE @EWardID = PatientWarD

--perform all logic operations here
--IS IT A WEEKDAY
IF  

--execute all output sub procs here
--wrap each execute in a TRY/CATCH block

--all works send out a success message