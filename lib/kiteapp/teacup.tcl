#-----------------------------------------------------------------------
# TITLE:
#   teacup.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kiteapp(n) teacup proxy.  This module provides a proxy interface
#   to the teacup executable, translating data formats and handling other
#   low-level matters.
#
#   The deps.tcl module handles the project's external dependencies; and
#   the teapot.tcl module manages the local teapot.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# teacup ensemble

snit::type teacup {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # teacup commands

    # create dirname
    #
    # dirname   - The directory name of a teapot to be created.
    #
    # Creates a new local teapot at the desired location.  Creates the
    # parent directory if necessary.

    typemethod create {dirname} {
        # FIRST, create the parent directory if necessary.
        file mkdir [file dirname $dirname]

        # NEXT, create the teapot.
        Call create $dirname
    }

    # default ?teapot?
    #
    # teapot   - The name of the new default depot.
    #
    # With no arguments, returns the name of the default teapot.
    # If teapot is given, sets it to be the default teapot.

    typemethod default {{teapot ""}} {
        if {$teapot ne ""} {
            Call default $teapot
        }

        return [file normalize [string map {\\ /} [Call default]]]
    }

    # install name version
    #
    # name    - A package name
    # version - A version number
    #
    # Attempts to install the given package from the remote repository
    # into the local teapot.  Throws any error.

    typemethod install {name version} {
        Call install --with-recommends $name $version
    }

    # installfile filename
    #
    # filename - Name of a locally produced teapot package
    #
    # Attempts to install the package in the local teapot repository.
    # Throws any error.

    typemethod installfile {filename} {
        Call install $filename >@ stdout 2>@ stderr
    }

    # link args
    #
    # Calls teacup link with the arguments; replaces backslashes
    # in the output.

    typemethod link {args} {
        return [string map {\\ /} [Call link {*}$args]]
    }

    # list args
    #
    # args -- teacup command-line arguments
    #
    # Calls "teacup list --as cvs"; returns the result as a list of
    # dictionaries.

    typemethod list {args} {
        # FIRST, get the CSV
        try {
            set output [Call list --as csv {*}$args]
        } on error {result} {
            throw FATAL "Error querying teapot: $result"
        }

        # NEXT, get the list of keys
        set rows [split $output \n]
        set keys [split [lshift rows] ","]

        # NEXT, save the rows as dictionaries
        set dicts [list]

        foreach row $rows {
            lappend dicts [lzipper $keys [split $row ","]]
        }

        return $dicts
    }

    # remove name version
    #
    # name    - A package name
    # version - A version number
    #
    # Attempts to remove the given package from the repository.
    # Throws any error.

    typemethod remove {name version} {
        Call remove $name $version
    }

    # Call args
    #
    # Calls the teacup executable with the args, throwing a fatal
    # error if teacup cannot be found.

    proc Call {args} {
        return [exec [plat pathto teacup -required] {*}$args]
    }
}

