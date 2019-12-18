/*
	List vacansies alphabetically-ordered, with less than 5 responses (even without responses) during
	first week after publication
*/

select less_than_five.name
from (
	select responded_vacancies.name
	from 	(
			select full_table.name, count(*) as frequency
			from 
				-- Get the full table [vacancy columns] [vacancy_body columns] [responses columns ] (26 seconds)
				((vacancy join vacancy_body on vacancy.vacancy_id = vacancy_body.vacancy_body_id)
				left join responses using (vacancy_id)) as full_table
			where 
				(full_table.response_time - full_table.creation_time) < '1 week'::interval
			group by
				vacancy_id, name
		) as responded_vacancies
	where
		frequency < 5
) as less_than_five
union all (
	select	name
	from	vacancy_body 
	where not exists 
		(
			select from 
				responses 
			where 
				responses.vacancy_id = vacancy_body.vacancy_body_id
		)
)
order by 
	name;






	
