# set the location of the accounts-ledger/catalog directory
# and the sql-ledger locale directory
# use full pathname
set gifi_dir "/var/lib/aolserver/openacs-4/packages/ref-gifi"
set gifi_cat_dir [file join $gifi_dir catalog]
set gifi_common_dir [file join $gifi_dir sql common]
set qal_cat_dir "/var/lib/aolserver/openacs-4/packages/accounts-ledger/catalog"

set sl_base_dir "/var/lib/aolserver/sql-ledger-2.6.2"
set sl_gifi_dir [file join $sl_base_dir sql]

# set the gifi file name  to gifi key mapping
set gifimap(Austria) "de_AT"
set gifimap(Belgium) "fr_BE"
set gifimap(Canada-English) "en_CA"
set gifimap(Canada-French) "fr_CA"
# set gifimap(Colombia-PUC) ""
set gifimap(Colombia-utf8-PUC) "es_CO"
set gifimap(German-Sample) "de_DE"
set gifimap(Germany-DATEV-SKR03) "de_DE_DATEV"
set gifimap(Germany-SKR03) "de_DE_SKR03"
set gifimap(Hungary) "hu_HU"
set gifimap(Italy) "it_IT"
set gifimap(Paraguay) "es_PY"
set gifimap(Swiss-German) "de_CH"

# we are converting different sources of text
# and am using some common routines

proc quote_xml_values { unquoted } {
    # xml standard requires certain characters to be
    # converted to entities when included in values:
    # &amp; &lt; &gt; &quot; &apos;

    # must be careful to not over quote any existing entities;    
    # expanding existing entities
    regsub -nocase -all -- {&lt;} $unquoted {<} unquoted
    regsub -nocase -all -- {&gt;} $unquoted {>} unquoted
    regsub -nocase -all -- {&quot;} $unquoted "\"" unquoted
    # following needs to be last
    regsub -all -- {&amp;} $unquoted {\&} unquoted

    # now make them again, amp needs to be first
    regsub -all -- {\&} $unquoted {\&amp;} quoted
    regsub -all -- "\"" $quoted {\&quot;} quoted
    regsub -all -- {>} $quoted {\&gt;} quoted
    regsub -all -- {<} $quoted {\&lt;} quoted
    return $quoted
}

# the 'all' phrases in the SL/locales directory
puts "converting the sql/*gifi* data"
source convert-SL-gifis.tcl

puts "done."
