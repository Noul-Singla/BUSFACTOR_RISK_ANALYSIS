/****** Script for SelectTopNRows command from SSMS  ******/
SELECT substring(filename,LEN(filename)-5,5), count(0)
  FROM [Capstone].[dbo].[rdc_15_18]
  group by substring(filename,LEN(filename)-5,5)
  order by count(0) desc;

SELECT substring(filename,CHARINDEX('.',filename),5) as file_end,count(0) as occurences
  INTO FILE_LIST_COUNT
  FROM [Capstone].[dbo].[rdc_15_18]
  group by substring(filename,CHARINDEX('.',filename),5)
    order by count(0) desc;

select sum(occurences) from FILE_LIST_COUNT

select .01*37968198

select file_end,occurences from FILE_LIST_COUNT
order by occurences desc

select * INTO FILETERED_FILE_LIST from FILE_LIST_COUNT where occurences >= 31193
and file_end not in('.txt','.png','.md','.com/','.rst','.org/','.ufo/','.svg','.jpg','gcc/','.0.0/','.Web/')



select * into [rdc_15_18_fc] from [rdc_15_18] where substring(filename,CHARINDEX('.',filename),5) in 
(select distinct file_end from FILETERED_FILE_LIST) 
select count(0) from [rdc_15_18_fc]
select count(0) from [rdc_15_18]
select 26890047*100.00/37968198
--70.82%


select count(distinct project) from [rdc_15_18_fc]
--8130


select project,filename,operation,min(create_date) create_date into file_create_info from [rdc_15_18_fc]
 group by project,filename,operation;


select distinct a.project,a.filename,a.file_owner f_owner INTO file_owner_info from [rdc_15_18_fc] a, file_create_info b where
a.project = b.project and a.operation=b.operation and a.filename = b.filename and a.create_date = a.create_date


select project,filename,commit_yr,count(0) total_commits Into file_commit from [rdc_15_18_fc] where operation in ('M','D')
group by project,filename,commit_yr

select project,filename,commiter_name,commit_yr,count(0) total_commits 
Into file_user_commit from [rdc_15_18_fc] 
where operation in ('M','D')
group by project,filename,commiter_name,commit_yr


select top 10 * from file_user_commit
select top 10 * from file_commit
select top 10 * from file_owner_info

select Fu.*,fc.total_commits file_commits,case when foi.f_owner is null then 0 else 1 end as f_owner 
INTO doa_factors from file_user_commit fu
inner join file_commit fc 
ON fu.project = fc.project and fu.filename = fc.filename and fu.commit_yr = fc.commit_yr
left outer join file_owner_info foi on
fu.project = foi.project and fu.filename = foi.filename and fu.commiter_name = foi.f_owner


select *,(3.293 + 1.098 * f_owner + 0.164 * total_commits -0.321 *LOG(1+file_commits,EXP(1))) doa
into DOA from doa_factors 

select project,filename,commit_yr,sum(doa) total_doa INTO DOA_norm_factor FROM DOA group by project,filename,commit_yr


select doa.*,doa/total_doa norm_doa INTO DOA_norm from DOA, DOA_norm_factor 
where DOA.project = DOA_norm_factor.project and DOA.filename = DOA_norm_factor.filename and DOA.commit_yr = DOA_norm_factor.commit_yr

select project,sum(total_commits) project_commits into Project_commits from DOA_NORM group by project order by sum(total_commits),project

select project,commiter_name,commit_yr,count(0) ownerships INTO USER_OWNERSHIP from DOA_norm where norm_doa >= 0.75 --and total_commits >=10
group by project,commiter_name,commit_yr

select project,commit_yr,count(0) ownerships INTO PROJECT_OWNERSHIP from DOA_norm where norm_doa >= 0.75 --and total_commits >=10
group by project,commit_yr


select * , row_number() over(partition by project,commit_yr order by prct_ownership desc) rank,
sum(prct_ownership) over(partition by project,commit_yr order by prct_ownership desc) cumulative_prct_ownership,
case when (sum(prct_ownership) over(partition by project,commit_yr order by prct_ownership desc)) <50 then 1 else 0 end author
into interim_author
from(
select UO.*,UO.ownerships*100.00/PO.ownerships prct_ownership from USER_OWNERSHIP UO, PROJECT_OWNERSHIP PO where UO.project = PO.project and UO.commit_yr = po.commit_yr
) interim1



select a.project, a.commiter_name,a.commit_yr,a.rank,a.cumulative_prct_ownership, a.prct_ownership,
case when a.author =1 then 1 
when a.rank = 1 then 1
when a.cumulative_prct_ownership > 50 and b.cumulative_prct_ownership <50 then 1 else 0 end author
INTO Authorship
 from interim_author a left outer join interim_author  b on a.project = b.project and
a.commit_yr=b.commit_yr and a.rank-1 = b.rank;


select project,commit_yr,sum(author) TF
INTO TRUCK_FACTOR
from Authorship where author =1 group by  project,commit_yr
order by project,commit_yr;


select project,commiter_name,commit_yr
into #temp
from Authorship where author =1



select a.project,a.commiter_name,
case when b.commiter_name is null then 0 else 1 end name_2015,
case when c.commiter_name is null then 0 else 1 end name_2016,
case when d.commiter_name is null then 0 else 1 end name_2017,
case when e.commiter_name is null then 0 else 1 end name_2018
into author_history from (select distinct project,commiter_name from #temp) a
left outer join #temp b on a.project = b.project and a.commiter_name = b.commiter_name and b.commit_yr= 2015
left outer join #temp c on a.project = c.project and a.commiter_name = c.commiter_name and c.commit_yr= 2016
left outer join #temp d on a.project = d.project and a.commiter_name = d.commiter_name and d.commit_yr= 2017
left outer join #temp e on a.project = e.project and a.commiter_name = e.commiter_name and e.commit_yr= 2018


select  * from author_history

