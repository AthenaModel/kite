#-----------------------------------------------------------------------
# TITLE:
#    control.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    kiteutils(n): Control Structions
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Exported commands

namespace eval ::kiteutils:: {
    namespace export    \
        assert          \
        bgcatch         \
        callwith        \
        foroption       \
        require 
}

#-----------------------------------------------------------------------
# Control Structures

# assert expression
#
# If the expression is not true, an assertion failure error is thrown.
proc ::kiteutils::assert {expression} {
    if {[uplevel [list expr $expression]]} {
        return
    }

    return -code error -errorcode ASSERT "Assertion failed: $expression"
}

# bgcatch script
#
# script    An arbitrary Tcl script
#
# Evaluates script in the caller's context.  If the script throws
# an error, bgcatch passes the error to bgerror, and returns normally.
# bgcatch returns nothing.

proc ::kiteutils::bgcatch {script} {
    set code [catch [list uplevel 1 $script] result]

    if {$code} {
        bgerror $result
    }

    return
}


# callwith prefix args...
#
# prefix     A command prefix
# args       Addition arguments
#
# Concatenates the prefix and the arguments and calls the result in
# the global scope.  The prefix is assumed to be a proper list.
#
# If the prefix is the empty list, callwith does nothing.

proc ::kiteutils::callwith {prefix args} {
    if {[llength $prefix] > 0} {
        return [uplevel \#0 $prefix $args]
    }
}

# require expression message
#
# If the expression is not true, an assertion failure error is thrown
# with the specified message.
proc ::kiteutils::require {expression message} {
    if {[uplevel [list expr $expression]]} {
        return
    }

    return -code error -errorcode ASSERT $message
}

# foroption optvar argvar ?-all? body
#
# optvar   - A variable to receive an option, e.g., -myoption
# argvar   - An argument list
# body     - A body of switch cases for the options.
#
# Steps through the argument list in the argvar, extracting options
# and passing them to the relevant case in the body.  Continues
# until all arguments are consumed or it reaches an argument
# that's not an option.  If -all is given, it assumes that
# it should consume the entire argument list.
#
# The cases may freely refer to the optvar and the argvar.
#
# When an unexpected option is found, throws an error.
# On success, all data read will have been extracted from the argvar.

proc ::kiteutils::foroption {optvar argvar allopt {cases ""}} {
    upvar 1 $optvar opt
    upvar 1 $argvar argv

    set allflag 0

    if {$allopt eq "-all"} {
        set allflag 1
    } elseif {$cases ne ""} {
        error "Unexpected flag: \"$allopt\", should be -all"
    }

    if {$cases eq ""} {
        set cases $allopt
    }

    append cases [format {
        default {
            throw INVALID "Unknown option: \"$%s\""
        }
    } $optvar]

    while {
        [llength $argv] > 0 &&
        ($allflag || [string index [lindex $argv 0] 0] eq "-")
    } {
        set opt [lshift argv]

        set command [list switch -exact -- $opt $cases] 

        uplevel 1 $command
    }

    return
}
