#-----------------------------------------------------------------------
# TITLE:
#    listx.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    kiteutils(n): List utilities
#
#    Miscellaneous commands
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Exported commands

namespace eval ::kiteutils:: {
    namespace export    \
        ladd            \
        ldelete         \
        lmaxlen         \
        lmerge          \
        lshift
}


#-----------------------------------------------------------------------
# List functions

# ladd listvar value
#
# listvar    A list variable
# value      A value
#
# If the value does not exist in listvar, it is appended.
# The new list is returned.

proc ::kiteutils::ladd {listvar value} {
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

# ldelete listvar value
#
# listvar    A list variable
# value      A value
#
# If value exists in listvar, it is removed.  The new list is returned.
# If the list doesn't exist, that's OK.

proc ::kiteutils::ldelete {listvar value} {
    upvar $listvar list1

    # Remove the value from the list.
    if {[info exists list1]} {
        set ndx [lsearch -exact $list1 $value]

        if {$ndx >= 0} {
            set list1 [lreplace $list1 $ndx $ndx]
        }

        return $list1
    }

    return
}

# lmaxlen list 
#
# Return the length of the longest string in list.

proc ::kiteutils::lmaxlen {list} {
    set maxlen 0

    foreach val $list {
        set maxlen [expr {max($maxlen,[string length $val])}]
    }

    return $maxlen
}

# lmerge listvar list
#
# listvar    A list variable
# list       A list
#
# Appends the elements of the list into the listvar, only if they
# aren't already present.

proc ::kiteutils::lmerge {listvar list} {
    upvar $listvar dest

    if {![info exists dest]} {
        set dest [list]
    }

    foreach item [concat $dest $list] {
        set items($item) 1
    }

    set dest [array names items]

    return $dest
}

# lshift listvar
#
# Removes the first element from the list held in listvar, updates
# listvar, and returns the element.

proc ::kiteutils::lshift {listvar} {
    upvar $listvar list

    set value [lindex $list 0]
    set list [lrange $list 1 end]
    return $value
}
