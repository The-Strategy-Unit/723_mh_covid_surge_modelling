/****** Script for variable - time in treatment  ******/ 
 
  ------# IAPT days/months in treatment and volumes of activity
  
  Select a.IAPT_PERSON_ID, REFERRAL_ID
  , IC_DATE_FIRST_ASSESSMENT, IC_DATE_LAST_Appointment
  , [IC_COUNT_TREATMENT_APPOINTMENTS]
  , cast(datediff(dd,IC_DATE_FIRST_ASSESSMENT,IC_DATE_LAST_Appointment)+1 as int) as [DaysinTreatment]
  , round(cast(datediff(dd,IC_DATE_FIRST_ASSESSMENT,IC_DATE_LAST_Appointment)+1 as int)/365.25*12,0) as [MonthsInTreatment]
  ,case when IC_DATE_FIRST_ASSESSMENT = IC_DATE_LAST_APPOINTMENT then [IC_COUNT_TREATMENT_APPOINTMENTS]/(365.25/12)
    else [IC_COUNT_TREATMENT_APPOINTMENTS]/(cast(datediff(dd,IC_DATE_FIRST_ASSESSMENT,IC_DATE_LAST_Appointment)+1 as int)/365.25*12)
    end as [AVG_appts_permonth]
into #iapt1
  from [NHSE_IAPT].[dbo].Referral_v15 a
  left outer join (
			select IAPT_PERSON_ID, PseudoNumber, [CCG_OF_RESIDENCE], [CCG_OF_GP_PRACTICE], GENDER, ETHNICITY, LSOA
			from [NHSE_IAPT].[dbo].[Person_V15]
			group by IAPT_PERSON_ID, PseudoNumber, [CCG_OF_RESIDENCE], [CCG_OF_GP_PRACTICE], GENDER, ETHNICITY, LSOA
			) b
			on a.IAPT_PERSON_ID = b.IAPT_PERSON_ID
  where IC_DATE_FIRST_ASSESSMENT between '2018-01-01' AND '2018-12-31'
  and ENDDATE is not NULL -- completed/abandoned treatments only
  and (left(endcode,1) = '4' OR endcode = '98') -- assessed and treated (proxy for caseness)

  Select avg([DaysinTreatment]) from #iapt1
  
  Select avg(AVG_appts_permonth) as IAPT_appts
  from #iapt1

Declare @total int
Select @total = count(*) from #iapt1

Select MonthsInTreatment, count(*) as [Pats], (count(*)*1.0/@total) as [perc]
,ROW_NUMBER () Over(order by MonthsInTreatment asc) as [Row]
into #iapt2
from #iapt1
group by MonthsInTreatment
order by MonthsInTreatment

Select a.*
, SUM(a.perc) over(order by [Row] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as perc_cum
into #iapt3
from #iapt2 a

Select cast(min(MonthsInTreatment) as int) as [MIT]
from #iapt3
where perc_cum >= 0.5


------# MHSDS days/months in treatment (completed referrals) by Team referred to
------# base table of 2018 referrals with valid completion/discharge
SELECT [MHS101UniqID]
      ,ref.[Person_ID]
      ,ref.[OrgIDProv]
      ,ref.[UniqSubmissionID]
      ,ref.[UniqMonthID]
      ,ref.[RecordNumber]
      ,ref.[RowNumber]
      ,ref.[ServiceRequestId]
      ,[OrgIDComm]
      ,[ReferralRequestReceivedDate]
      ,[SourceOfReferralMH]
      ,[PrimReasonReferralMH]
      ,[ServDischDate]
      ,ref.[UniqServReqID]
      ,[AgeServReferRecDate]
      ,ref.[RecordStartDate]
      ,ref.[RecordEndDate]
      ,[InactTimeRef]
      ,ref.[NHSEUniqSubmissionID]
      ,ref.[Der_Use_Submission_Flag]

	  ,serv.ServTeamTypeRefToMH
	  ,serv.ReferClosureDate
	  ,serv.ReferRejectionDate
	  
into #stage1
  FROM [NHSE_MHSDS].[dbo].[MHS101Referral] ref
  left outer join [NHSE_MHSDS].[dbo].[MHS102ServiceTypeReferredTo] serv
  on ref.ServiceRequestId = serv.ServiceRequestId
  and ref.RecordNumber = serv.RecordNumber

  where ref.ReferralRequestReceivedDate between '2018-01-01' AND '2018-12-31'
  and (ServDischDate is not NULL --discharged referrals
			OR ReferClosureDate is not NULL) --closed referrals
  and ServTeamTypeRefToMH is not NULL --exclude unknown team/service type
  and ServTeamTypeRefToMH not in ('CAM','CHA','EO1','N/A','UNK','XXX') -- exclude some dodgy team types
  order by ref.ServiceRequestId, ref.RecordNumber

------# adding/imputing missing date information to get LoS in service for most recent referrals
select a.*
,case
	when ServDischDate is not NULL then datediff(dd,ReferralRequestReceivedDate,ServDischDate)
	when ServDischDate is NULL and ReferClosureDate is not NULL then datediff(dd,ReferralRequestReceivedDate,ReferClosureDate)
	else NULL end as [DaysInService]
into #stage2
from #stage1 a
inner join (select ServiceRequestId, max(RowNumber) as [RowNumber]
			from #stage1
			group by ServiceRequestId) b
			on a.ServiceRequestId = b.ServiceRequestId
			and a.RowNumber = b.RowNumber

--Select ServTeamTypeRefToMH, avg([DaysInService]) as [AVGdays]
--from #stage2
--group by ServTeamTypeRefToMH
--order by ServTeamTypeRefToMH

Select *
, round([DaysInService]/365.25*12,0) as [MonthsInTreatment]
into #stage3
from #stage2
order by ServTeamTypeRefToMH, DaysInService

Select ServTeamTypeRefToMH, count(*) as [total]
into #teams
from #stage3
group by ServTeamTypeRefToMH

select * from #stage3

Select ServTeamTypeRefToMH, MonthsInTreatment, count(*) as [Pats]
into #stage4
from #stage3
group by ServTeamTypeRefToMH, MonthsInTreatment
order by ServTeamTypeRefToMH, MonthsInTreatment

------# add cumulative percentages to get cut-off months
Select a.*
, ([Pats]*1.0/b.total) as [perc]
,ROW_NUMBER () Over(partition by a.ServTeamTypeRefToMH order by a.MonthsInTreatment asc) as [Row]
into #stage5
from #stage4 a
join #teams b
on a.ServTeamTypeRefToMH = b.ServTeamTypeRefToMH
order by ServTeamTypeRefToMH, MonthsInTreatment

Select *
, SUM(perc) over(partition by ServTeamTypeRefToMH order by [Row] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as perc_cum
into #stage6
from #stage5

Select ServTeamTypeRefToMH, cast(min(MonthsInTreatment) as int) as [MIT]
into #stage7
from #stage6
where perc_cum >= 0.5
group by ServTeamTypeRefToMH

Select ServTeamTypeRefToMH
, case when [MIT] = 0 then 1 else [MIT] end as [months]
, case when [MIT] = 0 then 1 else 0.5 end as [decay]
from #stage7
order by ServTeamTypeRefToMH

--drop table #iapt1
--drop table #iapt2
--drop table #iapt3

--drop table #stage1
--drop table #stage2
--drop table #stage3
--drop table #stage4
--drop table #stage5
--drop table #stage6
--drop table #stage7

--drop table #teams



  