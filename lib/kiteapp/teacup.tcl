#-----------------------------------------------------------------------
# TITLE:
#   teacup.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kiteapp(n) teacup module; commands for using "teacup" to query
#   the default local teapot repository, and to install packages in it.
#   To adminstrate the local teapot repository as a whole, see 
#   teapot.tcl.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# teacup ensemble

snit::type teacup {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # teacup commands

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
            lappend dicts [lzipper $keys [split $row ","]]
        }

        return $dicts
    }

    # install name version
    #
    # name    - A package name
    # version - A version number
    #
    # Attempts to install the given package from the remote repository
    # into the local teapot.  Throws any error.

    typemethod install {name version} {
        exec [plat pathto teacup -required] install --with-recommends \
            $name $version
    }

    # remove name version
    #
    # name    - A package name
    # version - A version number
    #
    # Attempts to remove the given package from the repository.
    # Throws any error.

    typemethod remove {name version} {
        exec [plat pathto teacup -required] remove $name $version
    }

    # installfile filename
    #
    # filename - Name of a locally produced teapot package
    #
    # Attempts to install the package in the local teapot repository.
    # Throws any error.

    typemethod installfile {filename} {
        exec [plat pathto teacup -required] install $filename \
            >@ stdout 2>@ stderr
    }
}

