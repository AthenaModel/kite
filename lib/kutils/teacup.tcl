#-----------------------------------------------------------------------
# TITLE:
#   teacup.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kutils(n) teacup module; commands for using "teacup" to query
#   the default local teapot repository, and to install packages in it.
#   To adminstrate the local teapot repository as a whole, see 
#   teapot.tcl.
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

    # uptodate
    #
    # Returns 1 if all required packages are up-to-date.

    typemethod uptodate {} {
        foreach name [project require names] {
            set version [project require version $name]

            if {![$type has $name $version]} {
                return 0
            }
        }

        return 1
    }

    # status
    #
    # Queries the presence of each required package in the local
    # teapot and outputs the status to the console.

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
}