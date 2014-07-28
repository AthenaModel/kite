#-----------------------------------------------------------------------
# TITLE:
#    stringx.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    kiteutils(n): String Utilities
#
#    Miscellaneous commands
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Exported commands

namespace eval ::kiteutils:: {
    namespace export    \
        codeblock       \
        normalize       \
        outdent
}

# normalize text
#
# text   - A block of text
#
# Strips leading and trailing whitespace, converts newlines to spaces,
# and replaces all multiple internal spaces with single spaces.

proc ::kiteutils::normalize {text} {
    set text [string trim $text]
    regsub -all "\n" $text " " text
    regsub -all { +} $text " " text
    
    return $text
}

# outdent block
#
# block - A block of text in curly braces, indented like the
#         body of a Tcl if or while command.
#
# Outdents the block as follows:
# 
# * Removes the first and last lines.
# * Finds the length of shortest whitespace leader over all remaining 
#   lines.
# * Deletes that many characters from the beginning of each line.
# * Returns the result.

proc ::kiteutils::outdent {block} {
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


# codeblock name arglist ?initbody? template
#
# name        The command name
# arglist     The macro's argument list
# initbody    Optionally, some code to execute before expanding
#             the macro.
# template    The template string.
#
# Defines a command called "name" in the caller's context.  The
# command that returns a block of text, replacing 
# "%<variable>" markers with the value of block's arguments and
# local variables.  The template takes the arguments listed in
# "arglist", which follows the normal Tcl proc rules.  When
# called, the command outdents the "template" string and does a
# [string map] substitution on it, returning the result.  If given, 
# "initbody" is executed before the substitution; it can define variables 
# to be used in the template string.
#
# The string map is automatically set up to replace double "\\" with
# "\"; this allows backslash continuation characters to be included in
# the generated code block.
#
# The template string may contain any number of "%<variable>" markers;
# each one will be replaced with the value of the named variable.
# Only block arguments and local variables defined within the 
# "initbody" may be used.
#
# codeblock is very similar to the template(n) template command, but
# is much better suited for creating large blocks of Tcl code.

proc ::kiteutils::codeblock {name arglist initbody {template ""}} {
    # FIRST, have we an initbody?
    if {"" == $template} {
        set template $initbody
        set initbody ""
    }

    # NEXT, define the body of the new proc so that the initbody, 
    # if any, is executed and then the substitution is 
    set body "$initbody\n    ::kiteutils::CodeBlockMap [list [outdent $template]]\n"

    # NEXT, define
    uplevel 1 [list proc $name $arglist $body]
}

# CodeBlockMap template
#
# template  - A template string with %<variable> markers.
#
# This command implements the codeblock command.  It builds a 
# [string map] mapping from local %<variable> names to values.
# Array variables are ignored.

proc ::kiteutils::CodeBlockMap {template} {
    # FIRST, get the local variables in the parent context.
    set mapping [dict create \\\\ \\]
    foreach var [uplevel 1 {info locals}] {
        if {[uplevel 1 [list array exists $var]]} {
            continue
        }
        dict set mapping %$var [uplevel 1 [list set $var]]
    }

    return [string map $mapping $template]
}



