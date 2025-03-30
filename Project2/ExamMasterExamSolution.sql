alter proc [dbo].[ExamMasterV1]
-- external variables
@EFname varchar(35),@ELname varchar(35), 
@EDOB date, @EWardID int, @ECareteamID int, @ECovidStatus varchar(20)
as
begin
set nocount on;
--retry loop
declare @RetryCount   int = 0;
declare @MaxRetries   int = 3;
-- loop for retries, there is 3 attempts
while (@RetryCount < @MaxRetries)
begin
begin try
-- isolation level set
set transaction isolation level repeatable read;
begin transaction;
-- internal variables
declare @IWardcapacity tinyint, @IWardspec varchar (25)
,@INoOfPatients tinyint, @INoofDoctors tinyint
,@INoOfNurses tinyint,@INoOfSpecNurses tinyint, @IDay varchar(12)
,@IAge tinyint, @IPatientID int, @ICareTeamFlag bit = 1
, @IName varchar(100), @msgtext varchar(1000), @msg varchar(1000)
, @IAddNurseN int, @IAddNurseP int
-- do the reads
-- blocking phantom inserts
--read the data from the ward table and new currentPatientCount
select @IWardcapacity=WardCapacity
, @IWardspec=WardSpeciality,
@INoOfPatients=currentPatientCount --read denormalised count
from dbo.WardTbl with (updlock, holdlock)
where WardID=@EWardID
-- how many nurses are there on this care team
select @INoOfNurses = COUNT(*)
from dbo.NurseCareTeamMembersTBL
where CareTeamID=@ECareteamID
and CurrentMember = 1
-- how many nurses are there on this care team who have the speciality
select @INoOfSpecNurses =count(*)
from dbo.NurseCareTeamMembersTBL as nc
join dbo.NurseTBL  as n on
nc.MemberID= n.NurseID
where CareTeamID=@ECareteamID
and
SUBSTRING(NurseSpeciality,(len(NurseSpeciality)-2),3) like SUBSTRING(@IWardspec,1,3)
and 
CurrentMember = 1
-- how many doctors are there on this care team 
--who have the speciality
select @INoofDoctors = COUNT(*)
from dbo.DoctorTbl as d
inner join dbo.DoctorCareTeamMembersTBL  as dc on
d.DoctorID=dc.MemberID
where CareTeamID=@ECareteamID
and
SUBSTRING(DoctorSpeciality,(len(DoctorSpeciality)-2),3) like SUBSTRING(@IWardspec,1,3)
and CurrentMember = 1
-- what day of the week is it
select @IDay=DATENAME(dw,getdate())
--now populate the temp tables with available nurses from the ward
-- who are not active on 3 care teams
select NurseID
into #t1
from dbo.NurseTBL as n
join dbo.NurseCareTeamMembersTBL as c on
n.NurseID=c.MemberID
where CurrentMember = 1
and NurseWard = @EWardID
AND NURSEID NOT IN
(SELECT MemberID
FROM DBO.NurseCareTeamMembersTBL
where  CurrentMember=@ECareteamID
)
group by NurseID
having count(*) <3
-- add in those not assinged to a care team 
-- and have not been assinged to a ward
-- and have not been vaccinated
union
select NurseID
from dbo.NurseTBL as n
left join dbo.NurseCareTeamMembersTBL as nc on
n.NurseID=nc.MemberID
where 
nc.MemberID is null
and NurseWard is null
and COVID19Vacinated = 0
-- randomly select a nurse from this table
select top 1 @IAddNurseN = NurseID
from #t1
order by newid()
-- now repeat this but this time 
-- get nurses that have been vaccinated
select NurseID
into #t2
from dbo.NurseTBL as n
join dbo.NurseCareTeamMembersTBL as c on
n.NurseID=c.MemberID
where CurrentMember = 1
and NurseWard = @EWardID
AND NURSEID NOT IN
(SELECT MemberID
FROM DBO.NurseCareTeamMembersTBL
where  CurrentMember=@ECareteamID
and CareTeamID=1)
group by NurseID
having count(*) <3
-- add in those not assinged to a care team 
-- and have not been assinged to a ward
-- and have  been vaccinated
union
select NurseID
from dbo.NurseTBL as n
left join dbo.NurseCareTeamMembersTBL as nc on
n.NurseID=nc.MemberID
where 
nc.MemberID is null
and NurseWard is null
and COVID19Vacinated = 1
-- now randomly select from this list
select top 1 @IAddNurseP = NurseID
from #t2
order by newid()
-- Do The Logic
-- get the patients age
if MONTH(@EDOB) <= MONTH(getdate()) 
and day(@EDOB) <= day(getdate())
begin
select @IAge = DATEDIFF(yy, @EDOB, getdate())
end
else 
begin
select @iage = (DATEDIFF(yy, @EDOB, getdate()))-1
end
--is the ward full and its not a weekend
if @IWardcapacity<=@INoOfPatients
begin
if @iday not like 'sunday' and @IDay not like 'saturday'
begin
select @IName= Upper(substring(@EFname,1,1)) + SUBSTRING(@EFname,2,len(@EFname))
+' '+Upper(substring(@ELname,1,1)) + SUBSTRING(@ELname,2,len(@ELname))
 select @msgtext =  N'This ward is overflowing – find a different ward for %s'
 select @msg = FORMATMESSAGE (@msgtext,  @IName);   
;throw 50001, @msg, 1
end
else 
--is the ward at 120% capacity and it is a weekend
if ceiling((@IWardcapacity*1.2))<=@INoOfPatients
begin
select @IName= Upper(substring(@EFname,1, 1)) + SUBSTRING(@EFname,2,len(@EFname))
+' '+Upper(substring(@ELname,1,1)) + SUBSTRING(@ELname,2,len(@ELname))
 select @msgtext = N'This ward is overflowing – find a different ward for %s'
 select @msg = FORMATMESSAGE (@msgtext,  @IName);   
;throw 50001, @msg, 1 
end
end
-- what about the age rules
select @msgtext =
case
-- less that or equal to 13
when @IAge <= 13 and 
(
@Iwardspec not like '%Paeds13%' 
and @IWardspec not like '%Paediatrics13%' 
)
then N'Patients in this ward must be 13 or younger'
 --age > 13 and M 15 ==> 14 years old check
when @IAge = 14 and
(
@Iwardspec not like '%Paeds15%' 
and @IWardspec not like '%Paediatrics15%' 
)
then N'Patients in this ward must be 14'
 --aged between 15 and 18 check
when @IAge between 15 and 18 
and 
(
@IWardspec not  like '%paeds%'
or (@Iwardspec like '%paeds13%' or @IWardspec like '%paeds15%'
or @Iwardspec   like '%paediatrics13%' 
or @IWardspec like '%paediatrics15%' 
)
)
then  N'Patients between 15 and 18 not allowed in this ward'
when @IAge >18
and 
(
@IWardspec  like '%paeds%'
or (@Iwardspec like '%paeds13%' or @IWardspec like '%paeds15%'
OR @Iwardspec   like '%paediatrics13%' 
OR @IWardspec like '%paediatrics15%' 
)
)
then  N'Adults are not allowed on Children''s ward'
else NUll
END
 --if one of the ages causes a fail finish here
if @msgtext is not null
begin
select @msg = FORMATMESSAGE (@msgtext);   
;throw 50001, @msg, 1 
end
--Now Do Care Team Rules
 --is there a nurse with the speciality
if @INoOfSpecNurses = 0
begin
select @ICareTeamFlag = 0
raiserror ('no nurse has the required speciality', 16,1)
end
-- is there a doctor with the speciality
if @INoofDoctors = 0
begin
select @ICareTeamFlag = 0
raiserror ('no doctor has the required speciality', 16,1)
end
 --enough current members for Covid Positive?
if (@INoOfNurses<3 or @INoofDoctors< 1) 
and @ECovidStatus not like 'Positive'
and @IAddNurseP is null
begin
select @ICareTeamFlag = 0
raiserror ('not enough members available for the team', 16,1)
end
-- enough current members for Covid Negative?
if (@INoOfNurses<3 or @INoofDoctors< 1) 
and @ECovidStatus  like 'Negative'
and @IAddNursen is null
begin
select @ICareTeamFlag = 0
raiserror ('not enough members available for the team', 16,1)
end
--OK Business Rules have been passed
-- wait to mimic processing 
waitfor delay '00:00:03';
 --Call other procs to do the inserts
-- if we can admit patient okay, we update currentpatientcount by 1
update dbo.WardTbl
set CurrentPatientCount = CurrentPatientCount + 1
where WardID = @EWardID;
 --insert the patient
begin try
exec test2000.InsertPatient @eFname, @ELname, @EWardID, @ECovidStatus
, @OPatientID=@IPatientID output
end try
begin catch
;throw
end catch
-- add the nurse to the care team if there is one available
If @IAddNurseN is not null
begin
begin try
exec test2000.InsertNurse @ECareTeamID, @IAddNurseN
end try
begin catch
;throw
end catch
end
If @IAddNurseP is not null
begin
begin try
exec test2000.InsertToCareTeam @ECareTeamID, @IAddNurseP
end try
begin catch
;throw
end catch
end
-- Assign the Patient to the Care Team if allowed 
if @ICareTeamFlag = 1
begin try
exec test2000.InsertToCareTeam @eCareteamID, @IPatientID
end try
begin catch
;throw
end catch
 --all ok do a cleanup of the table
DROP TABLE #t1;
DROP TABLE #t2;
-- if all executed with no errors then commit transaction and break the while loop
commit transaction;
print ('The Patient has been admitted succesfully with no errors')
break;
end TRY
begin catch
-- we rollback and check if we can retry
print 'in catch block. '
+ 'Error number: '   + TRY_CONVERT(varchar(10), ERROR_NUMBER())
+ ' Error message: ' + Error_Message()
+ ' Error severity: ' + TRY_CONVERT(varchar(10), ERROR_SEVERITY())
+ ' Error State: ' + TRY_CONVERT(varchar(10), ERROR_STATE())
+ ' XACT_STATE: '    + TRY_CONVERT(varchar(10), XACT_STATE());
-- if the session is currently inside a transaction
if XACT_STATE() <> 0
begin
rollback transaction;
end
-- Check for concurrency conflict
if (ERROR_NUMBER() = 1205 or ERROR_NUMBER() = 50001)
begin
-- We can retry
set @RetryCount = @RetryCount + 1;
if (@RetryCount >= @MaxRetries)
begin
declare @ErrorNumber int = ERROR_NUMBER();
declare @ErrorState  int  = ERROR_STATE();
;throw @ErrorNumber, 
N' Number of retries limit exceeded. Admission of patient failed due to concurrency issues.'
,@ErrorState;
end
else
begin
print 'Retrying... Attempt ' + CAST(@RetryCount as varchar(10));
waitfor delay '00:00:02';  
continue; 
end
end
else
begin
-- when Not concurrency, rethrow
;throw
end
end catch
END 
RETURN 0;
END;
GO



 

