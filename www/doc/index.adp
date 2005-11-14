<master>
  <property name="title">@package_instance_name@</property>
 <p>
  Reference Data - GIFI provides templates of General Index of Financial Information (GIFI) for use with accounting packages.
 </p>
<h3>
 Features
</h3>
<h4>Converted:</h4>
<ul><li>
Data model for Postgresql. Also the *-gifi.sql files get pre-loaded into tables for easy importing templates.
</li></ul>
<h4>Planned:</h4>
 <p>
Adding oracle version. Shouldn't be too much work since the sql/common/*.dat files are already organized for optimal importing of data to oracle and postgresql
 </p>
<h3>
notes</h3>
<p>See accounts-ledger documentation for related information and overall project status.</p>
<p>
These tables are only represented as sql files in SL. Here the data is separate from the db used for consistency and ease of maintenance. At some point, the maintenance is planned to be integrated with acs-reference package.
</p>
<h3>
SQL
</h3><p>
The Oracle SQL will be added after the PG SQL has settled a bit.
</p><p>Some of the SQL has been changed to the OpenACS standards. See http://openacs.org/doc/current/eng-standards-plsql.html and http://openacs.org/wiki
</p><pre>
for Postgresql:

some of the TEXT types were changed to VARCHAR so that they get indexed
</pre>

