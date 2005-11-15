-- packages/ref-gifi/sql/oracle/ref-gifi-create.sql
--
-- @author torben@kappacorp.com
-- @creation-date 2005-09-27
-- @cvs-id $Id: 

-- gifi_registry contains GIFIs available through ref-gifi package

create table gifi_templates (
    -- gifi abbreviation or code, a reference which is used to match key in gifi_template_columns               
    code char(30)
        constraint gifi_template_pk primary key,

    -- contains comments, description, vendor of this gifi etc.
    comments varchar(4000)
        not null,

    -- gifi title, should contain a two letter reference to entity/country published
    title varchar(200)
        not null,
);

comment on table gifi_templates is '
    This table contains the gifis available from ref-gifi package
';

-- add this table into the reference repository
declare
    v_id integer;
begin
    v_id := acs_reference.new(
        table_name     => 'GIFI_TEMPLATES',
        source         => 'GIFI PUBLISHERS',
        source_url     => 'http://openacs.org/doc/current/ref-gifi',
        last_update    => to_date('2005-09-28','YYYY-MM-DD'),
        effective_date => sysdate
    );
commit;
end;
/

create table gifi_template_columns (
    -- gifi abbreviation or code, a reference which is used to match key in gifi_templates               
    -- there should be a constraint added here that points to gifi_templates.code
    code char(30),

    -- gifi title, should contain a two letter reference to entity/country published
    title varchar(300) not null,

    -- accno, account number for one column/item in the gifi
    accno varchar(100) not null

);

comment on table gifi_template_columns is '
    This table contains the gifis available from ref-gifi package
';

-- add this table into the reference repository
declare
    v_id integer;
begin
    v_id := acs_reference.new(
        table_name     => 'GIFI_TEMPLATE_COLUMNS',
        source         => 'GIFI PUBLISHERS',
        source_url     => 'http://openacs.org/doc/current/ref-gifi',
        last_update    => to_date('2005-09-28','YYYY-MM-DD'),
        effective_date => sysdate
    );
commit;
end;
/

