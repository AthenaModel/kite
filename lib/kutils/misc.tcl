#-----------------------------------------------------------------------
# TITLE:
#   misc.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kutils(n) Miscellaneous Commands
#
# TODO: Some of these should be deleted once we can make Mars an
#       external dependency.
#
#-----------------------------------------------------------------------

namespace eval ::kutils:: {
    namespace export \
        lshift       \
        readfile
}

#-----------------------------------------------------------------------
# Commands

# lshift listvar
#
# Removes the first element from the list held in listvar, updates
# listvar, and returns the element.

proc ::kutils::lshift {listvar} {
    upvar $listvar list

    set value [lindex $list 0]
    set list [lrange $list 1 end]
    return $value
}


# readfile filename
#
# filename - The file name
#
# Reads the file and returns the text.  Throws the normal
# open/read errors.

proc ::kutils::readfile {filename} {
    set f [open $filename r]

    try {
        return [read $f]
    } finally {
        close $f
    }
}
