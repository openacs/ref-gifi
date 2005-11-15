load data infile '[acs_root_dir]/packages/ref-gifi/sql/common/gifi_templates.dat'
into table gifi_templates
replace
fields terminated by "," optionally enclosed by "'"
(code,comments,title)
load data infile '[acs_root_dir]/packages/ref-gifi/sql/common/gifi_template_columns.dat'
into table gifi_template_columns
replace
fields terminated by "," optionally enclosed by "'"
(code,title,accno)
