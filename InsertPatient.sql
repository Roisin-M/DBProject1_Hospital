ALTER PROC InsertPatient
@EpFirstName VARCHAR(35),
@EpLastName VARCHAR(35),
@EpWardID INT,
@EpCovidStatus CHAR(8),
@OpatientNum INT OUTPUT
AS
--insert values into Patient TBL
BEGIN TRY
INSERT into dbo.PatientTBL
(PatientFname, PatientLname, PatientWarD, PatientCOVIDStatus)
VALUES
(@EpFirstName, @EpLastName, @EpWardID, @EpCovidStatus)
-- output the newly generated patient ID
SELECT @OpatientNum = SCOPE_IDENTITY()
END TRY
BEGIN CATCH
;THROW
END CATCH