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

    # update ?name?
    #
    # name   - The package to update, or "".
    #
    # Called with no arguments, this routine looks through the list of
    # "requires" and attempts to install all packages that are required
    # but not present in the local teapot repository.  It reports 
    # success or failure for each.
    # 
    # Called with a name, this routine attempts to update that particular
    # package.

    typemethod update {{name ""}} {
        # FIRST, handle individual packages.
        if {$name ne ""} {
            set ver [project require version $name]

            if {[$type has $name $ver]} {
                try {
                    RemovePackage $name
                } on error {result} {
                    throw FATAL \
                        "Could not remove package $name from the local teapot: $result"
                }
            }

            try {
                InstallPackage $name
            } on error {result} {
                throw FATAL \
                    "Could not install $name $ver into the local teapot: $result"
            }
            return
        }

        # NEXT, update all that need it.
        set errCount 0
        set updateCount 0

        foreach rname [project require names] {
            set ver [project require version $rname]

            if {[$type has $rname $ver]} {
                continue
            }

            try {
                InstallPackage $rname
                incr updateCount
            } on error {result} {
                incr errCount
                puts "Could not install $rname $ver: $result"
            }
        }

        puts "Updated $updateCount required package(s)."

        if {$errCount} {
            throw FATAL "Some required packages could not be installed."
        }
    }

    # InstallPackage name
    #
    # name  - A required package name
    #
    # Attempts to install the given package into the repository.
    # Throws any error.

    proc InstallPackage {name} {
        set ver [project require version $name]
        puts "Installing required package: $name $ver..."

        lappend command \
            teacup install --with-recommends $name $ver

        eval exec $command
    }

    # RemovePackage name
    #
    # name  - A required package name
    #
    # Attempts to remove the given package from the repository.
    # Throws any error.

    proc RemovePackage {name} {
        set ver [project require version $name]
        puts "Removing required package: $name $ver..."

        lappend command \
            teacup remove $name $ver

        eval exec $command
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

    #-------------------------------------------------------------------
    # Commands for managing the local teapot.
    

    # teapot state
    #
    # Verifies whether we have a Kite teapot or not.  Returns one 
    # of the following:
    #
    # ok          - Project teapot exists and is linked to tclsh
    # non-default - Project teapot isn't the default teapot.
    # unlinked    - Project teapot exists but is not linked to tclsh
    # missing     - Project teapot does not exist

    typemethod {teapot state} {} {
        if {![file exists [project teapot]]} {
            return "missing"
        }

        if {[project teapot] ni [LinkedTeapots]} {
            return "unlinked"
        }

        if {[project teapot] ne [DefaultTeapot]} {
            return "non-default"
        }

        return "ok"
    }

    # LinkedTeapots
    #
    # Retrieves the teapots linked to the current tclsh.

    proc LinkedTeapots {} {
        set links [eval exec teacup link info [info nameofexecutable]]
        set links [string map {\\ /} $links] 

        foreach {dummy path} $links {
            set newpath [file normalize $path]
            lappend result $newpath
        }

        return $result
    }

    # DefaultTeapot
    #
    # Retrieves the default teapot.

    proc DefaultTeapot {} {
        set def [eval exec teacup default]
        set def [string map {\\ /} $def] 

        return [file normalize $def]
    }



    # teapot create
    #
    # Creates the Kite teapot, if need be, and links it to the
    # current tclsh.

    typemethod {teapot create} {} {
        # FIRST, create the teapot
        if {[$type teapot state] eq "missing"} {
            puts "Creating teapot at [project teapot]..."
            file mkdir [file dirname [project teapot]]
            lappend command \
                teacup create [project teapot]

            eval exec $command
        }

        # NEXT, link it to the tclsh
        puts "Linking Kite teapot to [info nameofexecutable]..."
        exec teacup link make [project teapot] [info nameofexecutable]

        # NEXT, make it the default teapot.
        puts "Making Kite teapot the default installation teapot"
        exec teacup default [project teapot] 

    }

    # teapot status
    #
    # Displays information about the local teapot.

    typemethod {teapot status} {} {
        set state [$type teapot state]

        puts "Local teapot: [project teapot]\n"

        switch -exact -- $state {
            missing {
                puts "Kite hasn't yet created its local teapot. Please use"
                puts "'kite teapot create' to do so.  See 'kite help teapot'"
                puts "for details."
            }

            unlinked {
                puts "Kite's local teapot isn't linked to the development"
                puts "tclsh.  Please use 'kite teapot create' to do so."
                puts "See 'kite help teapot' for details."
            }

            non-default {
                puts "Kite's local teapot isn't the default installation"
                puts "teapot.  Please use 'kite teapot create' to make it"
                puts "so.  See 'kite help teapot' for details."
            }

            ok {
                puts "Kite's local teapot is ready for use."
            }

            default {
                error "Unknown teapot state: \"$state\""
            }
        }
    }

    #-------------------------------------------------------------------
    # Helpers 



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