-- packages/ref-unspsc/sql/oracle/ref-unspsc-create.sql
--
-- @author torben@kappacorp.com
-- @creation-date 2005-09-27
-- @cvs-id $Id: 

-- This table version reference so mapping handles multiple versions
-- since unspsc has multiple versions actively published and revisions are regularly released

create table unspsc_library (
    -- unspsc key, effective_id (or changed_id if the key is no longer used)
    unique_id integer
        constraint unspsc_library_pk
        primary key,
    -- from unspsc.org FAQ:  The UNSPSC is a hierarchical classification with five levels.
    -- These levels allow analysis by drilling down or rolling up to analyze expenditures.
    -- Each level in the hierarchy has its own unique number.

    -- UNSPSC number code is 8 or 10 digits, a 'magic numbering system' in form AABBCCDD(EE) where
    -- AA are 2 digits that represent segment type
    --   where 'segment' is the logical aggregation of families for analytical purposes 
    -- BB are 2 digits that represent family type, 00 is unspecific
    --   where 'family' is a commonly recognized group of inter-related commodity categories 
    -- CC are 2 digits that represent class type, 00 is unspecific
    --   where 'class' is a group of commodities sharing common characteristics 
    -- DD are 2 digits that represent commodity type, 00 is unspecific
    --   where 'commodity' is a group of substitutable products or services 
    -- (EE) optional, are 2 digits that represent business_function type, 00 is unspecific, default is no digits included 
    --   where business_function is the function performed by an organization in support of the commodity
    -- extra digits added to the field definition for site variations
    code char(20),

    -- unspsc number code type: segment, family, class, commodity, business_function
    -- of increasing specificity (uniqueness)
    code_type char(20),

    -- contains package keys for internationalization #package-key.unspsc_key#
    -- making this longer just in case someone wants to populate it with actual titles
    title char(200)
        not null,

    -- contains last version used in.
    latest_version number
        not null,

    -- when unspsc expires a key, sometimes a reference is made to use another key 'effective_id'
    expired_use_key integer
);

comment on table unspsc_library is '
    This is the combined library table from various versions of UNDP UNSPSC published codes.
';

-- add this table into the reference repository
declare
    v_id integer;
begin
    v_id := acs_reference.new(
        table_name     => 'UNSPSC_LIBRARY',
        source         => 'UNSPSC CODE',
        source_url     => 'http://www.unspsc.org',
        last_update    => to_date('2005-09-28','YYYY-MM-DD'),
        effective_date => sysdate
    );
commit;
end;
/

