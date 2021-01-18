/****** Script for variables - for IAPT  ******/
USE NHSE_IAPT
GO

------# % treatment 'success'
Select IAPT_PERSON_ID, REFERRAL_ID
,1 as [Active_flag]
,case when IC_FIRST_PHQ9 >=10 OR IC_FIRST_GAD >=8 then 1 else 0 end as [Caseness]
,case when IC_LAST_PHQ9 <10 And IC_LAST_GAD <8 then 1 else 0 end as [Recovered]
into #1
from [NHSE_IAPT].[dbo].[Referral_v15]
where REFRECDATE between '2018-01-01' AND '2018-12-31' 
and ENDDATE is not NULL --completed treatments only
and (IC_FIRST_PHQ9 is not NULL AND IC_LAST_PHQ9 is not NULL AND IC_FIRST_GAD is not NULL AND IC_LAST_GAD is not NULL) --records with initial and final anxiety and depression values

Select sum(Active_flag) as [All], sum(Caseness) as [Caseness], sum(Recovered) as [Recovered]
into #2
from #1

Select 'IAPT' as ServTeamType
, cast([Recovered] as float)/[All] as [success]
from #2

--drop table #1
--drop table #2


------# referrals that were taken into service
Select count(*) as [AllReferrals]
, sum(case when ENDCODE in ('50','10','11','12','13','14','16') then 1 else 0 end) as [NotTreated]
, 1-(sum(case when ENDCODE in ('50','10','11','12','13','14','16') then 1 else 0 end) / cast(count(*) as float)) as [treat_pcnt]
from [NHSE_IAPT].[dbo].[Referral_v15]
where REFRECDATE between '2018-01-01' AND '2018-12-31'
and ENDCODE is not NULL --only valid coded discharges

------# average demand per month per referral
Select a.IAPT_PERSON_ID, a.IAPT_RECORD_NUMBER, datediff(dd,refrecdate,ENDDATE)*1.0/cast(12 as float) as [Months]
, case when IC_COUNT_APPOINTMENTS is NULL then 0 else IC_COUNT_APPOINTMENTS end as IC_COUNT_APPOINTMENTS
into #temp1
from [NHSE_IAPT].[dbo].[Referral_v15] a
left join [NHSE_IAPT].[dbo].[Appointment_v15] b
on a.IAPT_PERSON_ID = b.IAPT_PERSON_ID
and a.IAPT_RECORD_NUMBER = b.IAPT_RECORD_NUMBER
where ENDDATE between '2019-01-01' and '2019-12-31'
and ENDCODE not in ('50','10','11','12','13','14','16') --exclude referral rejected or not received treatment

select 'IAPT' as ServTeamType
, sum([Months]) as TotalMonths
, sum(IC_COUNT_APPOINTMENTS) as TotalAppts_IC
, sum(IC_COUNT_APPOINTMENTS) / sum([Months]) as [demand]
from #temp1

------# referral demand counts by month
SELECT datepart(yyyy,[REFRECDATE]) as [year]
	  ,datepart(mm,[REFRECDATE]) as [month]
	  ,count(distinct [REFERRAL_ID]) as [referrals]
      ,count(distinct a.[IAPT_RECORD_NUMBER]) as [records]
      ,count(distinct a.[IAPT_PERSON_ID]) as [patients]
FROM [NHSE_IAPT].[dbo].[Referral_v15] a
left outer join (
			select IAPT_PERSON_ID, PseudoNumber, [CCG_OF_RESIDENCE], [CCG_OF_GP_PRACTICE], GENDER, ETHNICITY, LSOA
			from [NHSE_IAPT].[dbo].[Person_V15]
			group by IAPT_PERSON_ID, PseudoNumber, [CCG_OF_RESIDENCE], [CCG_OF_GP_PRACTICE], GENDER, ETHNICITY, LSOA
			) b
			on a.IAPT_PERSON_ID = b.IAPT_PERSON_ID

where [REFRECDATE] >= '2018-01-01'

group by datepart(yyyy,[REFRECDATE])
	  ,datepart(mm,[REFRECDATE])

	  order by datepart(yyyy,[REFRECDATE])
	  ,datepart(mm,[REFRECDATE])