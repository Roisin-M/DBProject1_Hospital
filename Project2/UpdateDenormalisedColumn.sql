UPDATE w
SET CurrentPatientCount =
(
    SELECT COUNT(*)
    FROM dbo.PatientTbl AS p
    WHERE p.PatientWard = w.WardID
)
FROM dbo.WardTbl AS w;
