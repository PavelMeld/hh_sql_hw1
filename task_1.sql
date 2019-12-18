DROP TABLE if exists resume CASCADE;
DROP TABLE if exists resume_spec CASCADE;
DROP TABLE if exists users;
DROP TABLE if exists vacancy CASCADE;
DROP TABLE if exists vacancy_body;
DROP TABLE if exists vacancy_body_spec;
DROP TABLE if exists responses;

CREATE TABLE vacancy_body (
	vacancy_body_id		serial PRIMARY KEY,
	company_name		varchar(150) DEFAULT ''::varchar NOT NULL,
	name				varchar(220) DEFAULT ''::varchar NOT NULL,
	text				text,
	area_id				integer,
	address_id			integer,
	compensation_from	bigint DEFAULT 0,
	compensation_to		bigint DEFAULT 0,
	compensation_gross	boolean
);

CREATE TABLE vacancy_body_spec(
    vacancy_body_id integer DEFAULT 0 NOT NULL,
    spec_id integer DEFAULT 0 NOT NULL
);

CREATE TABLE vacancy (
	vacancy_id		serial PRIMARY KEY,
	creation_time	timestamp NOT NULL,
	expire_time		timestamp NOT NULL,
	employer_id		integer DEFAULT 0 NOT NULL,    
	disabled		boolean DEFAULT false NOT NULL,
	visible			boolean DEFAULT true NOT NULL,
	vacancy_body_id	serial REFERENCES vacancy_body(vacancy_body_id),
	area_id			integer
);



CREATE TABLE users(
	user_id		serial PRIMARY KEY,
	first_name	varchar(50),
	second_name	varchar(50),
	email		varchar(256) NOT NULL UNIQUE
);


CREATE TABLE resume(
	resume_id	serial PRIMARY KEY,
	user_id		integer	REFERENCES users(user_id),
	area_id		integer,
	text		text,
	created		timestamp NOT NULL,
	active		boolean DEFAULT true not NULL
);

CREATE TABLE resume_spec (
    resume_id	integer DEFAULT 0 not NULL,
    spec_id		integer DEFAULT 0 not NULL
);

CREATE TABLE responses (
	resume_id integer REFERENCES resume(resume_id),
	vacancy_id integer REFERENCES vacancy(vacancy_id),
	response_time	timestamp NOT NULL
);

