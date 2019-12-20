--
-- On DELETE and UPDATE mark existing row as active = false
--
CREATE OR REPLACE FUNCTION delete_update_handler() RETURNS TRIGGER as $$
BEGIN
	-- If record is already inactive - do nothing
	if (OLD.active = false) THEN
		return NULL;
	END IF;
	
	-- On DELETE active -> set active = false, skip deletion
	IF (TG_OP = 'DELETE') THEN
		-- Set current record as inactive
		UPDATE resume
		SET	active = false, changed = NOW()
		WHERE	resume_id = OLD.resume_id;
	ELSIF (TG_OP = 'UPDATE') THEN
		-- Don't update inactive records
		IF (OLD.active = FALSE) THEN 
			return NULL;
		END IF;

		-- Update current record
		UPDATE resume
		SET 
			user_id=NEW.user_id, 
			area_id = NEW.area_id,
			text = NEW.text,
			created = NEW.created
		WHERE
			resume_id = NEW.resume_id;
			
		-- Archive OLD record with active = false, changed = now and root_id = resume_id
		INSERT into resume(user_id, area_id, text, created, changed, active, root_id)
		VALUES (
			OLD.user_id, 
			OLD.area_id, 
			OLD.text, 
			OLD.created, 
			NOW(),
			false,
			NEW.resume_id
		);

	END IF;

	-- Stop propagation
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER if EXISTS delete_update_hook ON resume;

CREATE  TRIGGER delete_update_hook 
BEFORE DELETE OR UPDATE ON resume
FOR EACH ROW 
WHEN (pg_trigger_depth() = 0)
EXECUTE PROCEDURE delete_update_handler();


--
--
--	Example, make 2 changes, show current and previous
--
--
update resume set text='a5' where resume_id=5;
update resume set text='a55' where resume_id=5;
update resume set text='a555' where resume_id=5;

select 
	actual.resume_id, 
	archive.changed as last_change_time,
	archive.text as old_title,
	actual.text as new_title
from 
	(
		select 
			resume_id, text
		from resume 
		where 
			resume_id = 5
	) as actual,
	(	
		select changed, text
		from resume 
		where root_id = 5
		order by changed desc
		limit 1
	) as archive;
