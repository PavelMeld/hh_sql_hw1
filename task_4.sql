/*

	Find month with maximum vacancies & maximum resume

	https://explain.depesz.com/s/O9a8
*/

select *
from  (
	select  extract(month from creation_time) as most_popular_vacancy_month 
	from	vacancy 
	group by (extract(month from creation_time)) 
	order by count(*) desc  limit 1
 ) as t1,
(
	select  extract(month from created) as most_popular_resume_month 
	from	resume 
	where	active = true
	group by (extract(month from created)) 
	order by count(*) desc  limit 1
) as t2;
