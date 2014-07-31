#-----------------------------------------------------------------------
# TITLE:
#    dictx.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    kiteutils(n): Dictionary utilities
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Exported commands

namespace eval ::kiteutils:: {
    namespace export    \
        dictglob
}

#-------------------------------------------------------------------
# File Handling Utilities


# dictglob dict key pattern ?key pattern...?
#
# dict     A dictionary
# key      A key
# pattern  A pattern to match
#
# Returns one if the dictionary has the specified keys and values.
# Matching is by [string match].  If a key isn't in the dictionary,
# the match fails.

proc ::kiteutils::dictglob {dict args} {
    foreach {key pattern} $args {
        if {![dict exists $dict $key]} {
            return 0
        }

        if {![string match $pattern [dict get $dict $key]]} {
            return 0
        } 
    }

    return 1
}


