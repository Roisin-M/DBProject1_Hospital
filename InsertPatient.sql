ALTER PROC InsertPatient
@eFname VARCHAR(35),
@ELname VARCHAR(35),
@EWardID INT,
@ECovidStatus CHAR(8),
@OPatientID INT OUTPUT
AS
--insert values into Patient TBL
BEGIN TRY
INSERT into dbo.PatientTBL
(PatientFname, PatientLname, PatientWarD, PatientCOVIDStatus)
VALUES
(@eFname, @ELname, @EWardID, @ECovidStatus)
-- output the newly generated patient ID
SELECT @OpatientID = SCOPE_IDENTITY()
END TRY
BEGIN CATCH
;THROW
END CATCH