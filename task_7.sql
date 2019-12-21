/*
Source scripts

Task	Time, ms	URL
3		38.5		https://explain.depesz.com/s/SUkK
4		125.4		https://explain.depesz.com/s/O9a8
5		80.8		https://explain.depesz.com/s/F2sO
6		730.4		https://explain.depesz.com/s/lgPV
*/

create index resp_index on resume_spec(resume_id);

select pg_sleep(60);

--
--
--	Task 6 query with index
--
--
explain analyze select r_id, user_spec, mode() within group (order by spec_id desc) 
from 
	(
		(
			select r_id, user_spec, vacancy_id
			from 
				(
					(select resume_id as r_id, array_agg(spec_id) as user_spec 
						from resume_spec 
						join resume using (resume_id)
						where active = true
						group by resume_id
					) as all_resume
					left join 
						responses 
					on
					r_id = responses.resume_id
				)
		) as resume_with_vacancies
		left join 
			vacancy_body_spec
		on	
			resume_with_vacancies.vacancy_id = vacancy_body_spec.vacancy_body_id
	) as xx
group by r_id, user_spec;
