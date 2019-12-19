/*
	List vacansies alphabetically-ordered, with less than 5 responses (even without responses) during
	first week after publication
*/

select responded_vacancies.name
from 	(
		select name, count(responses) as frequency
		from 
			-- Get the full table [vacancy columns] [vacancy_body columns] [responses columns ] (26 seconds)
			(vacancy join vacancy_body on vacancy.vacancy_id = vacancy_body.vacancy_body_id)
			left join responses using (vacancy_id) 
		where 
			(response_time - creation_time) < '1 week'::interval
		or
			responses is NULL
		group by
			vacancy_id, name
	) as responded_vacancies
where
	frequency < 5
order by 
	name;






	
