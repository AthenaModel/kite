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
        checkargs    \
        lshift       \
        readfile
}

#-----------------------------------------------------------------------
# Commands

# checkargs tool min max argspec argv
#
# tool     - The name of the tool
# min      - The minimum number of arguments.
# max      - The maximum number of arguments, or "-" for no max
# argspec  - An argument spec for display.
# argv     - The actual arguments to the tool
#
# Throws an error if there are the wrong number of arguments.

proc ::kutils::checkargs {tool min max argspec argv} {
    set argc [llength $argv]
    if {($argc < $min) ||
        ($max ne "-" && $argc > $max)
    } {
        throw FATAL "Usage: kite.kit $tool $argspec"
    }
}

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

# generate template mapping filename...
#
# template   - The name of a kutils/*.template file, e.g., "pkgIndex"
# mapping    - A dict mapping from template parameters to generated code.
# filename...   - Full path of a file to be generated, possibly as a
#                 series of tokens.
#
# Generates an output file given a template and a [string map]-style
# mapping dict.  If the filename is given as a sequence of tokens,
# they are joined appropriately for the platform.

proc ::kutils::generate {template mapping args} {
    variable library

    # FIRST, get the file name.
    set filename [file join {*}$args]

    # NEXT, get the template text
    set text [readfile [file join $library templates $template.template]]

    # NEXT, apply the mapping.
    set text [string map $mapping $text]

    # NEXT, make sure that the relevant directory exists.
    file mkdir [file dirname $filename]

    # NEXT, save the file.
    set f [open $filename w]
    puts $f $text
    close $f
}