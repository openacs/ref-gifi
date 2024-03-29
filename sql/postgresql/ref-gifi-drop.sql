-- Drop the ACS Reference GIFI data
--
-- @author torben@kappacorp.com
-- @cvs-id $Id: 

-- drop all associated tables and packages
-- I am not sure this is a good idea since we have no way to register
-- if any other packages are using this data.

-- This will probably fail if their is a child table using this.


create or replace function inline_0() returns integer as '
declare
    rec        acs_reference_repositories%ROWTYPE;
begin
    for rec in select * from acs_reference_repositories where upper(table_name) like ''GIFI%'' loop
	 execute ''drop table '' || rec.table_name || '' cascade'';
         perform acs_reference__delete(rec.repository_id);
    end loop;
    return 0;
end;' language 'plpgsql';

select inline_0();
drop function inline_0();

