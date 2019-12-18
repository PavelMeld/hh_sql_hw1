/*

	Find month with maximum vacancies & maximum resume

*/

select *
from  (
	select  extract(month from creation_time) as vacancy_month 
	from	vacancy 
	group by (extract(month from creation_time)) 
	order by count(*) desc  limit 1
 ) as t1
union all (
	select  extract(month from created) as resume_month 
	from	resume 
	group by (extract(month from created)) 
	order by count(*) desc  limit 1
);
