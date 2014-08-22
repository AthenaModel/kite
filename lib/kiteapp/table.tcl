#-----------------------------------------------------------------------
# TITLE:
#   table.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Support for outputting text tables to the console.
#
#   An input table is a list of dictionaries with identical keys.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# table ensemble.

snit::type table {
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
        }

        foroption opt args -all {
            -indent { set opts(-indent) [lshift args] }
        }

        # NEXT, get the column widths.
        set keys [dict keys [lindex $table 0]]

        array set wids [lzipper $keys [lrepeat [llength $keys] 0]]

        foreach dict $table {
            foreach key $keys {
                set val [dict get $dict $key]
                set wids($key) [expr {max($wids($key),[string length $val])}]
            }
        }

        # NEXT, format the rows
        set rows [list]

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






