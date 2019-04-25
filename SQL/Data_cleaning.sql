---------first code

select count(0) from raw_data;
--82,544,277
select count(distinct project) from raw_data;
--9144

select operation,count(0) from raw_data group by operation order by count(0) desc;

select distinct project from raw_data where operation =' Udi';

select count(0) from raw_data where operation in ('M','A','D') or operation like ('R0%') or operation like ('R1%') ;
--82480389
select 82480389.00/82544277
--0.99922601539
select count(0) from raw_data where operation in ('M','A','D') ;
--77157173
select 77157173.00/82480389;
--0.93546082814

select commiter_name,count(0) from raw_data where operation = 'A' group by commiter_name order by count(0) desc;


select 3000000.00/77157173