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
        callwith        \
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

