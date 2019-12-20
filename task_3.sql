/*

	Vacancies:
		Get average low for each area
		Get average high for each area
		Get average middle for each area

	https://explain.depesz.com/s/SUkK
*/

select area_id, t1.area_avg_low, t2.area_avg_high, (t2.area_avg_high + t1.area_avg_low)/2 as area_avg 
from 
	(
		select	
			avg(compensation_from * (1 - 0.3 * (compensation_gross = True)::int)) as area_avg_low, 
			area_id
		from	vacancy_body 
		where	compensation_from is not null and compensation_from > 0 
		group by area_id 
	) as t1
join
	(
		select	
			avg(compensation_to * (1 - 0.3 * (compensation_gross = True)::int)) as area_avg_high, 
			area_id
		from	vacancy_body 
		where	compensation_to is not null and compensation_to > 0
		group by area_id
	) as t2
using (area_id);
