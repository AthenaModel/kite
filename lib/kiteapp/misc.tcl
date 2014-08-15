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

}

#-----------------------------------------------------------------------
# Commands

# vputs text...
#
# text...  - One or more text strings
#
# Joins its arguments together and prints them to stdout, only if
# -verbose is on.

proc vputs {args} {
    if {$::kiteapp::verbose} {
        puts [join $args]
    }
}

# checkargs tool min max argv
#
# tool     - The name of the tool
# min      - The minimum number of arguments.
# max      - The maximum number of arguments, or "-" for no max
# argv     - The actual arguments to the tool
#
# Throws an error if there are the wrong number of arguments.

proc checkargs {tool min max argv} {
    set argc [llength $argv]
    if {($argc < $min) ||
        ($max ne "-" && $argc > $max)
    } {
        set argspec [dict get $::ktools($tool) usage]
        throw FATAL "Usage: kite $tool $argspec"
    }
}



# blockreplace text tag content
#
# text    - A text string, usually the contents of a text file
# tag     - A replacement tag, e.g., "ifneeded"
# content - A text string
#
# Looks for the '-kite-$tag-start' and '-kite-$tag-end' lines for the given
# tag, and replaces the text between them with the given content.

proc blockreplace {text tag content} {
    # FIRST, prepare
    set inlines [split $text "\n"]
    set outlines [list]
    set inBlock 0

    # NEXT, find and replace the block
    foreach line $inlines {
        if {!$inBlock} {
            if {[string match "# -kite-$tag-start*" $line]} {
                lappend outlines $line $content
                set inBlock 1
            } else {
                lappend outlines $line
            }
        } else {
            # In Block.  Skip everything but end.
            if {[string match "# -kite-$tag-end*" $line]} {
                lappend outlines $line
                set inBlock 0
            }
        }
    }

    # NEXT, return the new text.
    return [join $outlines "\n"]
}

# blocklines text tag
#
# text    - A text string, usually the contents of a text file
# tag     - A replacement tag, e.g., "ifneeded"
#
# Looks for the 'kite-$tag-start' and 'kite-$tag-end' lines for the given
# tag, and returns a list of the lines in the block of text between them, 
# the empty list if none.

proc blocklines {text tag} {
    # FIRST, prepare
    set inlines [split $text "\n"]
    set outlines [list]
    set inBlock 0

    # NEXT, find and replace the block
    foreach line $inlines {
        if {!$inBlock} {
            if {[string match "# -kite-$tag-start*" $line]} {
                set inBlock 1
            }
        } else {
            # In Block.  Get everything but the end.
            if {[string match "# -kite-$tag-end*" $line]} {
                break
            } else {
                lappend outlines $line
            }
        }
    }

    # NEXT, return the new text.
    return $outlines
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

proc prepare {varname args} {
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

# treefile path content
#
# path    - Path of the file to be generated, relative to root, with
#           "/" as the path separator.
# content - The content to put there.
#
# Outputs the file with the given content.

proc treefile {path content} {
    # FIRST, get the filename.
    set filename [project root {*}[split $path /]]

    # NEXT, save the file.
    vputs "Generate file: $filename"
    writefile $filename $content -ifchanged
}


