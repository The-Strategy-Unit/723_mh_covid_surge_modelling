/****** Script for variable - treatment 'success' for inpatients  ******/
 
------# patient discharges from inpatient services 2018
Select a.[Person_ID], ServiceRequestId, HospProvSpellNum, DischDateHospProvSpell
, case
	when b.AgeRepPeriodEnd < 25 then 'CYP'
	when b.AgeRepPeriodEnd between 25 and 64 then 'Adult'
	when b.AgeRepPeriodEnd >= 65 then 'OlderAdult'
	else NULL end as [AgeGroup]
,dateadd(dd,365,DischDateHospProvSpell) as [YrPostDischarge] --to get cutoff date for future admissions
into #disch
from [NHSE_MHSDS].[dbo].[MHS501HospProvSpell] a
left join [dbo].[MHS001MPI] b
on a.Person_ID = b.Person_ID
where DischDateHospProvSpell between '2018-01-01' AND '2018-12-31' --stays completed in 2018
  and a.Der_Use_Submission_Flag = 'Y'

group by a.[Person_ID], ServiceRequestId, HospProvSpellNum, DischDateHospProvSpell
, case
	when b.AgeRepPeriodEnd < 25 then 'CYP'
	when b.AgeRepPeriodEnd between 25 and 64 then 'Adult'
	when b.AgeRepPeriodEnd >= 65 then 'OlderAdult'
	else NULL end
,dateadd(dd,365,DischDateHospProvSpell)

------# All referrals during 2018 and 2019
select [Person_ID], ServiceRequestId, ReferralRequestReceivedDate
into #refs
from [NHSE_MHSDS].[dbo].[MHS101Referral]
where ReferralRequestReceivedDate between '2018-01-01' AND '2019-12-31'
group by [Person_ID], ServiceRequestId, ReferralRequestReceivedDate

------# All inpatient service admissions during 2018 and 2019
Select [Person_ID], ServiceRequestId, HospProvSpellNum, StartDateHospProvSpell
into #adm
from [NHSE_MHSDS].[dbo].[MHS501HospProvSpell]
where StartDateHospProvSpell between '2018-01-01' AND '2019-12-31'
  and Der_Use_Submission_Flag = 'Y'


------# Combined query of referral or admission
Select a.[Person_ID], AgeGroup, a.ServiceRequestId, a.HospProvSpellNum, DischDateHospProvSpell,[YrPostDischarge]
,sum(case when b.ReferralRequestReceivedDate between a.DischDateHospProvSpell and a.[YrPostDischarge] then 1 else 0 end) as [RefsPostDischarge]
,sum(case when c.StartDateHospProvSpell between a.DischDateHospProvSpell and a.[YrPostDischarge] then 1 else 0 end) as [AdmPostDischarge]
into #final
from #disch a
join #refs b
	on a.Person_ID = b.Person_ID
join #adm c
	on a.Person_ID = c.Person_ID

	group by a.[Person_ID], AgeGroup, a.ServiceRequestId, a.HospProvSpellNum, DischDateHospProvSpell,[YrPostDischarge]

Select AgeGroup, count(*) as [Discharges]
, sum(case when AdmPostDischarge > 0 OR [RefsPostDischarge] > 0 then 1 else 0 end) as [readmissionORreferral]
, 1-(sum(case when AdmPostDischarge > 0 OR [RefsPostDischarge] > 0 then 1 else 0 end)*1.0/count(*)) as [success]
from #final
group by AgeGroup

drop table #adm
drop table #disch
drop table #final
drop table #refs