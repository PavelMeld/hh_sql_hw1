/*
	Generate 10_000 vacancies
	Generate 100_000 resume
	Generate 50_000 responses
*/

--
--
-- Create Vacancy bodies
--
--
INSERT INTO vacancy_body(
    company_name, name, text, area_id, address_id, 
    compensation_from, compensation_to, compensation_gross
)
SELECT 
    (SELECT string_agg(
				substr( '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
					(random() * 77)::integer + 1, 1), 
				''
			) 
    FROM generate_series(1, 10 + (random() * 130 + i % 10)::integer)) AS company_name,

    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 10 + (random() * 200 + i % 10)::integer)) AS name,

    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 50 + i % 10)::integer)) AS text,

    (random() * 1000)::int AS area_id,
    (random() * 50000)::int AS address_id,
    (random()> 0.1) :: int * (25000 + (random() * 15000)::int) AS compensation_from,
    (random()> 0.1) :: int * (60000 + (random() * 100000)::int) AS compensation_to,
    (random() > 0.5) AS compensation_gross
FROM generate_series(1, 10000) AS g(i);

--
--
-- Create 10_000 Vacancies
--
--
INSERT INTO vacancy (creation_time, employer_id, disabled, visible, area_id, expire_time)
SELECT *, creation_time + random()*'5 years'::interval as expire_time
FROM
	(SELECT
		-- Creation from [-5 .. -2.6] 
		now()-random() * '5 years'::interval AS creation_time,
		(random() * 1000000)::int AS employer_id,
		(random() > 0.5) AS disabled,
		(random() > 0.5) AS visible,
		(random() * 1000)::int AS area_id
	FROM generate_series(1, 10000)) as base;

--
-- 
-- Create vacancy specializations (up to 5 specializations)
--
--
insert into vacancy_body_spec(vacancy_body_id, spec_id)
select 
	case 
		when (i/5)%5 = i%5 or random()<0.5 
		then i/5 + 1
		else -1 
	end as vacancy_body_id, i%5 as spec_id	
FROM generate_series(1, (10000 - 1) *5) as i;

delete from vacancy_body_spec where vacancy_body_id = -1;


--
--
-- Create 100 users
--
--
INSERT INTO users(first_name, second_name, email)
select 
    (SELECT string_agg(
				substr( 'abcdefghijklmnopqrstuvwxyz', 
					(random() * 25)::integer + 1, 1), 
				''
			) 
    FROM generate_series(1, 10 + (random() * 39 + uidx % 2)::integer)) AS first_name,
    (SELECT string_agg(
				substr( 'abcdefghijklmnopqrstuvwxyz', 
					(random() * 26)::integer + 1, 1), 
				''
			) 
    FROM generate_series(1, 10 + (random() * 39 + uidx % 2)::integer)) AS second_name,
    (SELECT concat(string_agg(
				substr( 'abcdefghijklmnopqrstuvwxyz', 
					(random() * (51-26+1))::integer + 1, 1), 
				''
			), concat('@domain',concat(uidx,'.com'))) 
    FROM generate_series(1, 5 + (random() * 5 )::integer)) AS email

from generate_series(1, 100) as uidx;

--
--
-- Create 100 000 resume
--
--
INSERT INTO resume(user_id, area_id, text, created)
select
    (random() * 99 + 1)::int AS user_id,
    (random() * 1000)::int AS area_id,
    (
		select string_agg(
			substr( '    abcdefghijklmnopqrstuvwxyz', (random() * 30)::integer + 1, 1), 
			''
		) 
		FROM generate_series(1, 150 + (random() * 50 + ridx %2)::integer)
	) AS text,
	now()-random() * '5 years'::interval AS created
FROM generate_series(1, 100000) as ridx;


--
--
-- Create resume specializations
--
--
insert into resume_spec(resume_id, spec_id)
select 
	case 
		when (i/5)%5 = i%5 or random()<0.5 
		then i/5 + 1
		else -1 
	end as resume_id, i%5 as spec_id	
FROM generate_series(1, (100000-1 )*5) as i;

delete from resume_spec where resume_id = -1;


--
--
--	50 000 responses, creation time is >= vacancy creation time
--
--
INSERT INTO responses(resume_id, vacancy_id, response_time)
select 
	new_resume_id as resume_id, 
	new_vacancy_id as vacancy_id,
	(
		select	vacancy.creation_time + random()*'5 weeks'::interval 
		from	vacancy 
		where	vacancy.vacancy_id = new_vacancy_id
	) as response_time
from 
	-- Create random pairs table (resume, vacancy) as data source
	(select
		(random() * (100000-2) + 1 + i%2) :: integer as new_resume_id,
		(random() * (10000-2) + 1 + i%2) :: integer as new_vacancy_id
	FROM generate_series(1, 50000) as i) new_requests;
