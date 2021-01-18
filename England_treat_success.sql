/****** Script for variable - % 'success' after discharge  ******/
------# Distinct patients discharged during 2018 that re-referred within 12 months

SELECT ref.[Person_ID]
      ,ref.[OrgIDProv]
      ,ref.[RecordNumber]
      ,ref.[RowNumber]
      ,ref.[ServiceRequestId]
	  ,serv.ServTeamTypeRefToMH
      ,[ServDischDate]
	  ,dateadd(dd,365,[ServDischDate]) as [1yrPostDischarge] --to use for future referral cut-off
	  
into #stage1 --use fixed table or view if preferred
  FROM [NHSE_MHSDS].[dbo].[MHS101Referral] ref
  left outer join [NHSE_MHSDS].[dbo].[MHS102ServiceTypeReferredTo] serv
  on ref.ServiceRequestId = serv.ServiceRequestId
  and ref.RecordNumber = serv.RecordNumber

  where ref.ServDischDate between '2018-01-01' AND '2018-12-31'
  and serv.ReferRejectionDate is NULL --exclude patients not receiving treatment
  and ServTeamTypeRefToMH is not NULL --unknown team/service type
  and ServTeamTypeRefToMH not in ('CAM','CHA','EO1','N/A','UNK','XXX') -- exclude some dodgy team types
  order by ref.Person_ID, ref.ServiceRequestId, ref.RecordNumber

------# most recent record for each patient&referral
select a.*
into #stage2
from #stage1 a
inner join (select ServiceRequestId, max(RowNumber) as [RowNumber]
			from #stage1
			group by ServiceRequestId) b
			on a.ServiceRequestId = b.ServiceRequestId
			and a.RowNumber = b.RowNumber

------# list of patient id to screen for future referrals
Select distinct(Person_ID) as [Distinct_Pat]
into #pats
from #stage1

------# all distinct referral records for above patients
Select a.Distinct_Pat, b.ServiceRequestId, b.ReferralRequestReceivedDate
into #allrefs
from #pats a
join [NHSE_MHSDS].[dbo].[MHS101Referral] b
on a.Distinct_Pat = b.Person_ID
and b.ReferralRequestReceivedDate between '2018-01-01' AND '2019-12-31'

group by a.Distinct_Pat, b.ServiceRequestId, b.ReferralRequestReceivedDate

------# Case statement to get referrals within 1yr of discharge
Select a.Person_ID, a.ServTeamTypeRefToMH, a.ServDischDate, a.[1yrPostDischarge]
,sum(case when b.ReferralRequestReceivedDate between a.servdischdate and a.[1yrPostDischarge] then 1 else 0 end) as [RepeatReferred]
into #stage3
from #stage2 a
join #allrefs b
on a.Person_ID = b.Distinct_Pat

group by a.Person_ID, a.ServTeamTypeRefToMH, a.ServDischDate, a.[1yrPostDischarge]

------# final calcs
Select ServTeamTypeRefToMH, count(*) as [AllDischarge]
, sum(case when repeatreferred = 0 then 1 else 0 end) as [No Repeat]
, sum(case when repeatreferred > 0 then 1 else 0 end) as [Repeat referral]
into #final
from #stage3
where ServTeamTypeRefToMH is not NULL
group by ServTeamTypeRefToMH
order by ServTeamTypeRefToMH

Select *
, cast([No repeat] as float)/[Alldischarge] as [success]
from #final
order by ServTeamTypeRefToMH

--drop table #stage1
--drop table #stage2
--drop table #stage3
--drop table #final
--drop table #allrefs
--drop table #pats

