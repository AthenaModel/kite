#-----------------------------------------------------------------------
# TITLE:
#   misc.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kiteapp(n) Miscellaneous Commands
#
# TODO: Some of these should be deleted once we can make Mars an
#       external dependency.
#
#-----------------------------------------------------------------------

namespace eval ::kiteapp:: {
    variable verbose 0

    namespace export \
        blockreplace \
        checkargs    \
        genfile      \
        gentree      \
        interdict    \
        prepare      \
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

proc ::kiteapp::vputs {args} {
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

proc ::kiteapp::checkargs {tool min max argspec argv} {
    set argc [llength $argv]
    if {($argc < $min) ||
        ($max ne "-" && $argc > $max)
    } {
        throw FATAL "Usage: kite $tool $argspec"
    }
}


# interdict keys values
#
# keys   - A list of keys
# values - A list of values
#
# Returns a dictionary of the keys and values

proc ::kiteapp::interdict {keys values} {
    set d [dict create]

    foreach k $keys v $values {
        dict set d $k $v
    }

    return $d
}

# blockreplace text tag content
#
# text    - A text string, usually the contents of a text file
# tag     - A replacement tag, e.g., "ifneeded"
# content - A text string
#
# Looks for the 'kite-start' and 'kite-end' lines for the given
# tag, and replaces the text between them with the given content.

proc ::kiteapp::blockreplace {text tag content} {
    # FIRST, prepare
    set inlines [split $text "\n"]
    set outlines [list]
    set inBlock 0

    # NEXT, find and replace the block
    foreach line $inlines {
        if {!$inBlock} {
            if {[string match "# -kite-start-$tag *" $line]} {
                lappend outlines $line $content
                set inBlock 1
            } else {
                lappend outlines $line
            }
        } else {
            # In Block.  Skip everything but end.
            if {[string match "# -kite-end-*" $line]} {
                lappend outlines $line
                set inBlock 0
            }
        }
    }

    # NEXT, return the new text.
    return [join $outlines "\n"]
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

proc kiteapp::prepare {varname args} {
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



# writefile filename content ?-ifchanged?
#
# filename - The file name
# content  - The content to write
#
# Writes the content to the file.  Throws the normal
# open/write errors.  If -ifchanged is given, reads the file first,
# and only writes the content if it's different than what was there.

proc ::kiteapp::writefile {filename content {opt ""}} {
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
# template   - The name of a kiteapp/*.template file, e.g., "pkgIndex"
# path       - Path of the file to be generated, relative to root.
# mapping    - A dict mapping from template parameters to generated code.
#
# Generates an output file given a template and a [string map]-style
# mapping dict.  The $root should be the complete pathname for the
# root directory.  The $path is the new file's path, relative to the
# root.  In $path directories should be joined with "/", and the
# $path can contain template parameters.

proc ::kiteapp::genfile {root template path mapping} {
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

proc ::kiteapp::gentree {root tlist args} {
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
