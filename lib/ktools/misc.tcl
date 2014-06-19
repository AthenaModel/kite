#-----------------------------------------------------------------------
# TITLE:
#   misc.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: ktools(n) Miscellaneous Commands
#
# TODO: Some of these should be deleted once we can make Mars an
#       external dependency.
#
#-----------------------------------------------------------------------

namespace eval ::ktools:: {
    namespace export \
        readfile
}

#-----------------------------------------------------------------------
# Commands

# readfile filename
#
# filename - The file name
#
# Reads the file and returns the text.  Throws the normal
# open/read errors.

proc ::ktools::readfile {filename} {
    set f [open $filename r]

    try {
        return [read $f]
    } finally {
        close $f
    }
}
