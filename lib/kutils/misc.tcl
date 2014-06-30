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
    variable verbose 0

    namespace export \
        checkargs    \
        genfile      \
        gentree      \
        ladd         \
        lshift       \
        prepare      \
        readfile     \
        outdent      \
        vputs        \
        writefile
}

#-----------------------------------------------------------------------
# Commands

# vputs text...
#
# text...  - One or more text strings
#
# Joins its arguments together and prints them to stdout, only if
# -verbose is on.

proc ::kutils::vputs {args} {
    variable verbose

    if {$verbose} {
        puts [join $args]
    }
}

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
        throw FATAL "Usage: kite $tool $argspec"
    }
}

# ladd listvar value
#
# listvar    A list variable
# value      A value
#
# If the value does not exist in listvar, it is appended.
# The new list is returned.

proc ::kutils::ladd {listvar value} {
    upvar $listvar list1

    if {[info exists list1]} {
        set ndx [lsearch -exact $list1 $value]
        if {$ndx == -1} {
            lappend list1 $value
        }
    } else {
        set list1 [list $value]
    }

    return $list1
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

# outdent block
#
# block  - A block of text in curly braces, indented like the
#          body of a Tcl if or while command.
#
# Outdents the block as follows:
# 
# * Removes the first and last lines.
# * Finds the length of shortest whitespace leader over all remaining 
#   lines.
# * Deletes that many characters from the beginning of each line.
# * Returns the result.

proc ::kutils::outdent {block} {
    # FIRST, delete the leading and trailing lines.
    regsub {^ *\n} $block {} block
    regsub {\n *$} $block {} block

    # NEXT, get the length of the minimum whitespace leader.
    set minLen 100

    foreach line [split $block \n] {
        if {[regexp {^\b*$} $line]} {
            continue
        }

        regexp {^ *} $line leader

        set len [string length $leader]

        if {$len < $minLen} {
            set minLen $len
        }
    }

    # NEXT, delete that length at the beginning of each line.
    set pattern "^ {$minLen}"

    regsub -all -line $pattern $block {} block

    # Return the updated block.
    return $block
}

# prepare varname ?options?
#
# varname - The name of the parameter variable
#
# Options:
#
#   -required         - Value must not be ""
#   -toupper          - Convert to upper case
#   -tolower          - Convert to lower case
#
# Does a string trim on the named var's value, applies
# any options, and puts the result back in the var.

proc kutils::prepare {varname args} {
    upvar 1 $varname var

    set var [string trim $var]

    while {[llength $args] > 0} {
        set opt [lshift args] 

        switch -exact -- $opt {
            -tolower { 
                set var [string tolower $var] 
            }
            
            -toupper { 
                set var [string toupper $var] 
            }

            -required {
                if {$var eq ""} {
                    throw SYNTAX "Missing $varname value"
                }
            }

            default  { error "Unknown option: \"$opt\""}
        }
    }

    return
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

# writefile filename content ?-ifchanged?
#
# filename - The file name
# content  - The content to write
#
# Writes the content to the file.  Throws the normal
# open/write errors.  If -ifchanged is given, reads the file first,
# and only writes the content if it's different than what was there.

proc ::kutils::writefile {filename content {opt ""}} {
    # FIRST, If we care, has the file's content changed?
    if {$opt eq "-ifchanged" && [file exists $filename]} {
        set oldContent [readfile $filename]

        if {$oldContent eq $content} {
            return
        }
    }

    # NEXT, write the file, first making sure the directory exists.
    file mkdir [file dirname $filename]

    set f [open $filename w]

    try {
        vputs "writefile <$filename>"
        return [puts -nonewline $f $content]
    } finally {
        close $f
    }
}

# genfile root template path mapping
#
# root       - The directory in which the file path is rooted.
# template   - The name of a kutils/*.template file, e.g., "pkgIndex"
# path       - Path of the file to be generated, relative to root.
# mapping    - A dict mapping from template parameters to generated code.
#
# Generates an output file given a template and a [string map]-style
# mapping dict.  The $root should be the complete pathname for the
# root directory.  The $path is the new file's path, relative to the
# root.  In $path directories should be joined with "/", and the
# $path can contain template parameters.

proc ::kutils::genfile {root template path mapping} {
    variable library

    # FIRST, get the file name.
    set filename [file join $root {*}[split [string map $mapping $path] /]]

    # NEXT, get the template text
    set text [readfile [file join $library templates $template.template]]

    # NEXT, apply the mapping, first adding the template
    dict set mapping %template $template.template
    set text [string map $mapping $text]

    # NEXT, save the file.
    vputs "Generate file: $filename from $template"
    writefile $filename $text -ifchanged
}

# gentree root tdict mapping...
#
# root    - Root directory of the tree to generate.
# tlist   - List of template names and paths.  The paths
#           should be relative to $root, use "/" as the separator,
#           and may contain mapping parameters.
# mapping - The mapping dict, expressed as a single argument or as
#           parameters and values on the command line.
#
# Generates an entire tree, rooted at $root.

proc ::kutils::gentree {root tlist args} {
    # FIRST, get the mapping
    if {[llength $args] == 1} {
        set mapping [lindex $args 1]
    } else {
        set mapping $args
    }

    # NEXT, generate each file in the tlist
    foreach {template path} $tlist {
        genfile $root $template $path $mapping
    }
}