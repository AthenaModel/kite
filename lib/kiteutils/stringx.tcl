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
        normalize       \
        outdent
}

# outdent block
#
# block - A block of text in curly braces, indented like the
#	      body of a Tcl if or while command.
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


