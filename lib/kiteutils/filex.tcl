#-----------------------------------------------------------------------
# TITLE:
#    filex.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    kiteutils(n): File utilities
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Exported commands

namespace eval ::kiteutils:: {
    namespace export    \
        readfile
}

#-------------------------------------------------------------------
# File Handling Utilities


# readfile filename
#
# filename    The file name
#
# Reads the file and returns the text.  Throws the normal
# open/read errors.

proc ::kiteutils::readfile {filename} {
    set f [open $filename r]

    try {
        return [read $f]
    } finally {
        close $f
    }
}

