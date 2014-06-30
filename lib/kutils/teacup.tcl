#-----------------------------------------------------------------------
# TITLE:
#   teacup.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kutils(n) teacup module; commands for interfacing with 
#   the teacup executable.
#
#   TODO: Make it work with ~/.kite/teapot so that we don't need to use
#   sudo on other platforms.
#
#-----------------------------------------------------------------------

namespace eval ::kutils:: {
    namespace export teacup
}

#-----------------------------------------------------------------------
# teacup ensemble

snit::type ::kutils::teacup {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Teapot Commands

    # status
    #
    # Queries the presence of each required package in the local
    # teapot

    typemethod status {} {
        if {[llength [project require names]] == 0} {
            puts "The project has no required packages.\n"
            return
        }

        puts "Required Package Status:\n"

        foreach name [project require names] {
            set version [project require version $name]

            if {[$type has $name $version]} {
                puts "  require \"$name $version\" appears to be up-to-date."
            } else {
                puts "  require \"$name $version\" needs to be retrieved."
            }
        }
    }

    # has package version
    #
    # package - A package name
    # version - A version requirement, as for [package vsatisfies]

    typemethod has {package version} {
        set rows [teacup list --at-default $package]

        foreach row $rows {
            set v [dict get $row version]

            if {[package vsatisfies $v $version]} {
                return 1
            }
        }

        return 0
    }

    # list args
    #
    # args -- teacup command-line arguments
    #
    # Calls "teacup list --as cvs"; returns the result as a list of
    # dictionaries.

    typemethod list {args} {
        # FIRST, get the CSV
        set command [list teacup list --as csv {*}$args]

        try {
            vputs "Executing: $command"
            set output [eval exec $command]
        } on error {result} {
            throw FATAL "Error querying teapot: $result"
        }

        # NEXT, get the list of keys
        set rows [split $output \n]
        set keys [split [lshift rows] ","]

        # NEXT, save the rows as dictionaries
        set dicts [list]

        foreach row $rows {
            lappend dicts [interdict $keys [split $row ","]]
        }

        return $dicts
    }

    # interdict keys values
    #
    # keys   - A list of keys
    # values - A list of values
    #
    # Returns a dictionary of the keys and values

    proc interdict {keys values} {
        set d [dict create]

        foreach k $keys v $values {
            dict set d $k $v
        }

        return $d
    }
}