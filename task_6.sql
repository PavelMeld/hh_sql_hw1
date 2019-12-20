/*

	List resume id, array of it's specializations and most popular
	specialization of the vacansies it responded to

	https://explain.depesz.com/s/kykH
*/
select r_id, user_spec, mode() within group (order by spec_id desc) from 
	((select r_id, user_spec, vacancy_id
		from 
			((select resume_id as r_id, array_agg(spec_id) as user_spec from resume_spec group by resume_id) as all_resume
		left join 
			responses 
		on
			r_id = responses.resume_id)) as resume_with_vacancies
	left join 
		vacancy_body_spec
	on	
		resume_with_vacancies.vacancy_id = vacancy_body_spec.vacancy_body_id) as xx
group by r_id, user_spec;
