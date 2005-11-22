-- packages/ref-gifi/sql/postgresql/ref-gifi-create.sql
--
-- @author torben@kappacorp.com
-- @creation-date 2005-09-27
-- @cvs-id $Id: 


-- gifi_registry contains GIFIs available through ref-gifi package


create table gifi_templates (
    -- gifi abbreviation or code, a reference which is used to match key in gifi_sets
       code varchar(30)  
        constraint code_pk primary key,

    -- contains comments, description, vendor of this gifi etc.
    comments text not null,

    -- gifi title, should contain a two letter reference to entity/country published
    title varchar(200) not null
   
);

comment on table gifi_templates is '
    This table contains the gifis available from ref-gifi package
';

-- add this table into the reference repository
select acs_reference__new (
    'GIFI_TEMPLATES', -- table_name
    '2005-09-27',
    'GIFI PUBLISHERS', -- source
    'http://openacs.org/doc/current/ref-gifi', -- source_url
    now() -- effective_date
);



-- This is the account details for the gifis.
-- Each account represents two columns
-- debit column is represented as positive values
-- credit column is represented as negative values

create table gifi_template_accounts (
    -- gifi abbreviation or code, a reference which is used to match key in gifi_registry
    code varchar(30) references gifi_templates (code) on delete cascade,

    -- title (or short description), should contain #package-key.gifi_code_title#
    title varchar(300) not null,

    -- accno, account reference or number
    accno varchar(100) not null
   
);

comment on table gifi_template_accounts is '
    This table contains the gifi data available from ref-gifi package
';

-- add this table into the reference repository
select acs_reference__new (
    'GIFI_TEMPLATE_ACCOUNTS', -- table_name
    '2005-09-27',
    'GIFI PUBLISHERS', -- source
    'http://openacs.org/doc/current/ref-gifi', -- source_url
    now() -- effective_date
);

create index gifi_accno_key on gifi_template_accounts (accno);
--

