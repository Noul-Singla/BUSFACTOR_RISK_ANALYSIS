select count(distinct project) from raw_data


select [project]
      ,[file_owner]
      ,dateadd(s,cast(Create_date as int),'1970-01-01') as Create_date
	  ,[commiter_name]
      ,dateadd(s,cast(commit_date as int),'1970-01-01') as commit_date
      ,datepart(yy,dateadd(s,cast(commit_date as int),'1970-01-01')) as commit_yr
	  ,[operation]
      ,[filename]
	 into raw_data_cleaned  from raw_data 
where operation in ('M','A','D')

select count(0) from raw_data_cleaned
--77157173

select count(0) from raw_data_cleaned where commit_yr in (2015,2016,2017,2018)
--28052001

select count(distinct project) from raw_data_cleaned where commit_yr in (2016,2017,2018)
--8119

select count(distinct project) from raw_data_cleaned where commit_yr in (2015,2016,2017,2018)
--8645
select Count(0) from rdc_15_18;

select * into  rdc_15_18  from raw_data_cleaned where commit_yr in (2015,2016,2017,2018)

--drop table project_years
select distinct project,commit_yr into project_years from rdc_15_18;

select * from project_years  order by project, commit_yr;

select project,file_owner,commit_yr,filename,count(distinct commiter_name) from raw_data_cleaned where project ='chromium' 
group by project,file_owner,commit_yr,filename