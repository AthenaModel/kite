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
# TODO: Move generic commands to kiteutils(n) (e.g., writefile).
#
#-----------------------------------------------------------------------

namespace eval ::kiteapp:: {
    variable verbose 0

    namespace export \
        blockreplace \
        checkargs    \
        interdict    \
        prepare      \
        treefile     \
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
        return [puts -nonewline $f $content]
    } finally {
        close $f
    }
}

# treefile path content
#
# path    - Path of the file to be generated, relative to root, with
#           "/" as the path separator.
# content - The content to put there.
#
# Outputs the file with the given content.

proc ::kiteapp::treefile {path content} {
    # FIRST, get the filename.
    set filename [project root {*}[split $path /]]

    # NEXT, save the file.
    vputs "Generate file: $filename"
    writefile $filename $content -ifchanged
}

