#-----------------------------------------------------------------------
# TITLE:
#   dictab.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   kiteutils(n): dictab formatting utilities.
# 
#   A dictab, or dictionary table, is a list of dictionaries with 
#   identical keys.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Exported commands

namespace eval ::kiteutils:: {
    namespace export    \
        dictab
}

#-----------------------------------------------------------------------
# dictab ensemble.

snit::type ::kiteutils::dictab {
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Public Methods

    # format table ?options...?
    #
    # table   - A list of dictionaries with identical keys.
    #
    # Options:
    #
    #   -indent leader   - Specifies an indent leader for each line.
    #   -headers         - Include column headers.
    #
    # Formats the list of dictionaries as a text table, presuming
    # monospace text.  Returns the formatted table.

    typemethod format {table args} {
        # FIRST, do we have a table?
        if {[llength $table] == 0} {
            return ""
        }

        # NEXT, get the options
        array set opts {
            -indent ""
            -headers 0
        }

        foroption opt args -all {
            -indent  { set opts(-indent)  [lshift args] }
            -headers { set opts(-headers) 1             }
        }

        # NEXT, get the column widths.
        set keys [dict keys [lindex $table 0]]

        array set wids [lzipper $keys [lrepeat [llength $keys] 0]]

        if {$opts(-headers)} {
            foreach key $keys {
                set wids($key) [string length $key]
            }
        }

        foreach dict $table {
            foreach key $keys {
                set val [dict get $dict $key]
                set wids($key) [expr {max($wids($key),[string length $val])}]
            }
        }

        # NEXT, format the rows
        set rows [list]

        if {$opts(-headers)} {
            set keydict [lzipper $keys $keys]
            set linedict [dict create]
            foreach key $keys {
                dict set linedict $key [string repeat - $wids($key)]
            }

            set table [linsert $table 0 $keydict $linedict]
        }

        foreach dict $table {
            set row [list]
            foreach key $keys {
                lappend row [format "%-*s" $wids($key) [dict get $dict $key]]
            }

            lappend rows "$opts(-indent)[join $row {  }]"
        }

        return [join $rows \n]
    }

    # puts table ?options?
    #
    # Formats and puts the table.

    typemethod puts {table args} {
        puts [$type format $table {*}$args]
    }
    
}






