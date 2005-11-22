

#!/usr/bin/tclsh8.0
# \
exec tclsh "$0" ${1+"$@"}
#


# this program converts sql-ledger gifi files to openacs catalog il8n xml files
#  and to openacs/common/gifi* files

# both kinds of files are made from the same program since we have to generate locale.message keys
# we need to be certain that the correct key gets used in the common/chart tables

# first, manufally cd to the sql-ledger/locale folder. copy all of the specific_locale/all files to the 
# locale folder with new filenames, each set to an OpenACS qualified locale aa_BB.txt
# To help identify the correct language and/or region, look at an SL's locale/LANGUAGE file
# Once the files are renamed and relocated, run this program from the same directory. 


# we add the following long csv parser to handle cases where string data includes commas and/or single quotes
# because tcl treats a \' like a single quote, making ignoring single quotes for parsing difficult
source long-parse-lib.tcl

# puts -nonewline "file to convert: "
# flush stdout
# set slfilenam [gets stdin]
# set working_dir [pwd]

if [catch {open [file join $gifi_common_dir gifi_template_accounts.dat] w} gifi_fid] {
    puts stderr "Cannot open gifi_template_accounts: $gifi_fid for write."
} else {
    # open output file to add gifi specific data to ref-gifi/sql/common for importing
    puts $errorInfo
}

if [catch {open [file join $gifi_common_dir gifi_templates.dat] w} gifi_list_fid] {
    puts stderr "Cannot open gifi_templates: $gifi_list_fid for write."
} else {
    # open output file to add gifi specific data to ref-gifi/sql/common for importing
    puts $errorInfo
}

set sl_file_list [glob [file join $sl_gifi_dir "*-gifi.sql"]]
set qal_xml_file_list [glob -nocomplain -- [file join $qal_cat_dir {*.xml}]]
set gifi_xml_file_list [glob -nocomplain -- [file join $gifi_cat_dir {*.xml}]]

foreach slfilepathnam $sl_file_list {
#    set slfilenam [string range $slfilepathnam 4 end]
    set slfilenam [string range [file tail $slfilepathnam] 0 end-9]
    set gifi_version ""
    if { [info exists gifimap($slfilenam)] } {
        set locale [string range $gifimap($slfilenam) 0 4]
        set gifi_version [string range $gifimap($slfilenam) 5 end]

        set file_exists_in_qal [lsearch $qal_xml_file_list "*${locale}*"]
        # get the charset by cross referencing with info from accounts-ledger package 
        if { $file_exists_in_qal > -1 } {
            regexp -nocase -- {\.([^\.]*)\.xml} [lindex $qal_xml_file_list $file_exists_in_qal] scratch charset
        } else {
            set charset "ISO-8859-1"
        } 
        regsub -nocase -- {utf8} $charset {UTF-8} charset
 

        # open sql-ledger gifi file
        if [catch {open $slfilepathnam r} sl_fid] {
            puts stderr "Cannot open $slfilenam: $sl_fid for read."
        } else {
            puts "reading: $slfilepathnam"

            set locale [string range $gifimap($slfilenam) 0 4]
            set country [string range $locale 3 4]

            # unfortunately, the French and English versions of the Canadian gifi are not matched
            # so we are unable to use the same key for two locales at this point.
            if { [string equal $country "CA"] } {
                set gifi_key "${locale}${gifi_version}"
            } else {
                set gifi_key "${country}${gifi_version}"
            }

            set file_exists [lsearch $gifi_xml_file_list "*${locale}*"]
            if { $file_exists == -1 } {
                set newFile [file join $gifi_cat_dir "ref-gifi.$locale.[string toupper $charset].xml"]
                set write_type "w"
            } else {
                set write_type "a"
                set newFile [lindex $gifi_xml_file_list $file_exists]
            }
#            puts "writing ${write_type} $newFile"
            regexp {ref-gifi.[a-z][a-z]_[A-Z][A-Z]\.([^\.]*)\.xml} $newFile scratch charset
            

#            while { [file exists $newFile] } {
#                append newFile "i"
#            }

            # parse the SL gifi file for key-phrase and translation
            # write the translation to the locale file and then
            # carry forward the key-phrase and phrase for building the 
            # ref-gifi/common/db-import-files

#            changing open from write to append any existing file info
            if [catch {open $newFile a} xml_fid] {
                puts stderr "Cannot open $newFile: $xml_fid for write/append."
            } else {
                # open output file to add gifi specific translations to locale
                # empty accumaltive comments for gifi descriptions
                set comments ""
                set gifi_title_set 0
                set gifi_title "General Index of Financial Information "
                if { $file_exists == -1 } {
                    puts $xml_fid "<?xml version=\"1.0\" encoding=\"$charset\"?>
<message_catalog package_key=\"ref-gifi\" package_version=\"0.1d\" locale=\"$locale\" charset=\"$charset\">

"
                }

                while {[gets $sl_fid line] >= 0} {
                    if { [regexp { *--(.*)} $line scratch comment ] } {
                        # delimiter needs to be escaped for Postgresql: http://www.postgresql.org/docs/7.4/interactive/libpq-exec.html
                        regsub -all -- {,} $comment {\,} sl_comment
                        if { !${gifi_title_set} && ( [string match -nocase "*gifi of account*" $sl_comment] || [string match -nocase "*GIFI*" $sl_comment] ) } {
                            set gifi_title_set 1
                            set gifi_title [string trim $sl_comment]
                        } else {
                            append comments "<br>${sl_comment}"
                        }
                    } elseif { [regexp -nocase -- { *into *gifi *} $line scratch] } { 

                            # line is not a complete sql statement, load 1 or more lines to complete it
                            if { ![regexp {\) *;} $line scratch ]} {
                                while {![regexp {\) *;} $line scratch ]} {
                                    if {[gets $sl_fid nextline] >= 0 } {
                                        append line $nextline
                                        puts "combining multilpe lines for gifitype. now:\n$line"
                                    } else {
                                        puts "ERROR: end of file, incomplete sql statement: $line"
                                        exit
                                    }
                                }
                            }

                       set columns ""
                       set col_values "" 
                       set parsed [regexp {^[^\)\(]*\(([^\)]*)\)[^\(]*\(([^\)]*)\)[^\)\(]*$} $line scratch columns col_values]
                        if { !$parsed } {
                            regexp {^[^\)\(]*\(([^\)]*)\)[^\(]*\(.*$} $line scratch columns
                        }
                       set columns_list [split $columns ,]
                       set columns_count [llength $columns_list]

                       set col_values_list [split $col_values ,]

                       if { [llength $col_values_list] != ${columns_count} } {
                           # manually create col_values here..so that it skips embedded parenthesis ()
                           set start_values [string first "(" $line [string first "values" [string tolower $line] [expr [string first "(" $line] + [string length $columns] + 2]]]
                           incr start_values
                           set last_values [string first ")" $line $start_values]
                           set last_p [string first ")" $line [expr ${last_values} + 1]]
                           while { $last_p > $start_values } {
                               set last_values $last_p
                               set last_p [string first ")" $line [expr ${last_values} + 1]]
                           }
                           set last_values [expr ${last_values} - 1]
                           set col_values [string range $line $start_values $last_values]

                           regsub -all -- {\' *, *\'} $col_values {','} col_values2
                           set col_values_list [long_csv_parse $col_values2 "'"]
#                           puts "long parsed '$col_values' to '$col_values_list'"
#                          verify results
                           if { [llength $col_values_list] != ${columns_count} } {
                               puts "ref(gifitype) parsing error for '$col_values' to '$col_values_list'"
                               puts "line: $line"
                               puts "columns: $columns"
                               puts "columns_list: $columns_list"
                               puts "parsed: $parsed"
                               puts "start_values: ${start_values}"
                               puts "last_values: ${last_values}"
                               exit
                           }
                       }
                       
                       set ii 0
                       array unset sl_value_array
                       foreach column ${columns_list} {
                           set sl_value_array([string trim $column]) [string trim [lindex $col_values_list $ii] " ',"]
                           incr ii
                       }

#                       # parse SL accno
#                        set begin_quote1 [expr 1 + [string first "'" $line ] ]
#                        set end_quote1 [expr [string first "'" $line $begin_quote1 ] - 1 ]
#                        set phrase [string range $line $begin_quote1 $end_quote1 ]
                        set phrase $sl_value_array(accno)
                        set sl_accno $phrase
                        regsub -all -- {[^a-zA-Z0-9]} $phrase "_" full_phrase 
                        set key_phrase [string trimright $full_phrase "_"]

                        # parse SL description
#                        set begin_quote2 [expr 1 + [string first "'" $line [expr $end_quote1 + 2]] ]
#                        set end_quote2 [expr [string first "'" $line $begin_quote2 ] - 1 ]
#                        set translation [string range $line $begin_quote2 $end_quote2 ]
                        set translation $sl_value_array(description)
                        set sl_description $translation

                        # parsing the rest of the fields now, but not used until later on.

                        # parse SL gifitype
#                        set begin_quote3 [expr 1 + [string first "'" $line [expr $end_quote2 + 2]] ]
#                        set end_quote3 [expr [string first "'" $line $begin_quote3 ] - 1 ]
#                        set sl_gifitype [string range $line $begin_quote3 $end_quote3 ]
#                        set sl_gifitype $sl_value_array(gifitype)

                        # parse SL gifi_accno
#                        set begin_quote4 [expr 1 + [string first "'" $line [expr $end_quote3 + 2]] ]
#                        set end_quote4 [expr [string first "'" $line $begin_quote4 ] - 1 ]
#                        set sl_gifi_accno [string range $line $begin_quote4 $end_quote4 ]
#                        set sl_gifi_accno $sl_value_array(gifi_accno)

                        # parse SL category
#                        set begin_quote5 [expr 1 + [string first "'" $line [expr $end_quote4 + 2]] ]
#                        set end_quote5 [expr [string first "'" $line $begin_quote5 ] - 1 ]
#                        set sl_category [string range $line $begin_quote5 $end_quote5 ]
#                        set sl_category $sl_value_array(category)

                        # parse SL link
 #                       set begin_quote6 [expr 1 + [string first "'" $line [expr $end_quote5 + 2]] ]
 #                       set end_quote6 [expr [string first "'" $line $begin_quote6 ] - 1 ]
 #                       set sl_link [string range $line $begin_quote6 $end_quote6 ]
#                       set sl_link $sl_value_array(link)

                        if { [string length $translation] > 0 } {  

                            set key_phrase "${gifi_key}_${key_phrase}"

                            # check if key is already used for a different phrase
                            if { [info exists key_array(${locale}-${key_phrase}) ] && ![string equal $key_array(${locale}-${key_phrase}) $phrase ] } {
                                set old_phrase $key_phrase
                                while { [info exists key_array(${locale}-${key_phrase}) ] } {
                                    # modify the key for a different translation key
                                    append key_phrase "_" 
                                }
                                if { ![info exists key_array(${locale}-${key_phrase}) ] } {
                                    puts "new key ${key_phrase} given 'key_array($old_phrase)' <> '$phrase'(EN), here to: '$translation'"
                                }
                            }
                            # check if key has already been set for this locale
                            if { [info exists translation_array($locale-${key_phrase}) ] && [string equal $translation_array($locale-${key_phrase}) $translation] } {
                                set skip 1
                            } elseif { [info exists translation_array($locale-${key_phrase}) ] && ![string equal $translation_array($locale-${key_phrase}) $translation] } {
                                # just in case
                                puts "Two different phrases for same key in one locale for '$phrase' ('$translation_array($locale-${key_phrase})' <> '$translation'."
                                while { [info exists key_array($locale-${key_phrase}) ]} {
                                    append key_phrase "_"
                                }
                                puts "    creating new key_phrase '${key_phrase}'"
                                set skip 0
                            } else {
                                set skip 0
                            }

                            if { !$skip } {
                                set translation [quote_xml_values $translation]
                                puts $xml_fid "<msg key=\"${key_phrase}\">$translation</msg>"
                                # remember key to check for duplications
                                set key_array(${locale}-${key_phrase}) $phrase
#                                set gifi_key_accno(${locale}-$phrase) ${key_phrase}
                                set translation_array($locale-${key_phrase}) $translation
                            } else {
                                puts "duplicate: ${key_phrase} for $phrase skipping.." 
                            }
                        } else {
                            puts "empty message for key '$phrase'. skipping.."
                        }

                        # put the data into the common/db-import-files.dat area
                        # the common data needs to be parsed with not-null values in first and last fields
                        # because oracle errors when parsing empty fields that are not between commas
                        puts $gifi_fid "${gifi_key},#ref-gifi.${key_phrase}#,${sl_accno}"

                    # if not a gifi table line, 
                    } else {
                        puts "ignoring line: $line"
                    }

                }
                close $xml_fid
                if { ![regexp -nocase -- {[^a-z0-9]${country}[^a-z0-9]} " $gifi_title " ] } {
                    append gifi_title " (${country})"
                }
                if { [string length $comments] > 0 } {
                    if {![string equal "ISO-8859-1" $charset]} {
                        if {![catch {exec iconv -c -f $charset -t ISO-8859-1 <<$comments} result]} {
                            set comments $result
                        } else {
                            puts "iconv errored with: '$result' for $slfilepathnam"
                        }
                    }
                } else {
                    set comments "no comments from sql-ledger gifi.sql file."
                    puts "no comments for this file. Adding a generic one: \n$comments"
                }
                puts ${gifi_list_fid} "${gifi_key},'$comments','${gifi_title}'"
            }
            close $sl_fid
        }

    }

}
# end foreach loop
close $gifi_list_fid
close $gifi_fid



# almost done... sql-ledger uses en_US for the system locale defaults, and so does not have 
# a translation file for it.. 
# create the en_US catalog file by expanding key_array

set charset "ISO-8859-1"
set locale "en_US"
set newFile [file join $gifi_cat_dir "ref-gifi.$locale.$charset.xml"]

if [catch {open $newFile a} newId] {
    puts stderr "Cannot open $newFile: $newId for write."
} else {
    set index_value_list [array get key_array]

    puts $newId "<?xml version=\"1.0\" encoding=\"$charset\"?>
<message_catalog package_key=\"accounts-ledger\" package_version=\"0.1d\" locale=\"$locale\" charset=\"$charset\">
"
    foreach {keyphrase phrase} $index_value_list {
        set key_locale [string range $keyphrase 0 4]
        # fifth character should be a '-'
        set key_phrase [string range $keyphrase 6 end]
        if { [info exists translation_array($locale-${key_phrase})] } {
            set translation $translation_array($locale-${key_phrase})
        } elseif { [string equal [string range $key_locale 0 1] "en"] } {
            # if its English, and there is no en_US translation, then use what is there
            set translation $translation_array(${key_locale}-${key_phrase})
        } else {
            set translation $phrase
        }
 
        set translation [quote_xml_values $translation]
        puts $newId "<msg key=\"${key_phrase}\">$translation</msg>"
    }
    close $newId
}



# add the closing tag to the catalog xml files

# refresh the xml file list
set gifi_xml_file_list [glob [file join $gifi_cat_dir {*.xml}]]

foreach xmlfilenam ${gifi_xml_file_list} {
    if [catch {open $xmlfilenam a} xmlID] {
        puts stderr "Cannot open $xmlfilenam: $xmlID for append."
    } else {
        puts $xmlID "</message_catalog>"
        close $xmlID
    }
}
