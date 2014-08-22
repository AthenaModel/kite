#-----------------------------------------------------------------------
# TITLE:
#   tool_deps.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "deps" tool.  This tool reports on the state of the project
#   dependencies, and can update them.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::DEPS

tool define deps {
    usage       {0 2 "?update|clean? ?<name>?"}
    description "Manage project dependencies"
    needstree      yes
} {
    The 'kite deps' tool manages the project's external dependencies.  
    There are two kinds of dependencies.  External "require" dependencies 
    are retrieved from teapot.activestate.com; and placed in the local
    teapot repository; locally-built "require" dependencies are tracked
    but not retrieved.

    kite deps
        Get the status of all dependencies.

    kite deps update
        Retrieve dependencies are are missing or are clearly out of date.

    kite deps update <name>
        Forces a fresh retrieval of the named dependency.

    When Kite fails to install a required teapot package,
    see the <project>/.kite/install_<package>.log file for details.
} {
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        # FIRST, if there are no arguments then just dump the dependency
        # status.
        set subc [lshift argv]

        if {$subc eq ""} {
            DisplayStatus
        } elseif {$subc eq "update"} {
            UpdateDependencies [lshift argv]
        } else {
            throw FATAL "Unknown subcommand: \"$subc\""
        }

        puts ""
    }
    
    # DisplayStatus
    #
    # Displays the status of the project dependencies.

    proc DisplayStatus {} {
        # FIRST, show the status of required teapot packages.
        teacup status

        puts "\nTo retrieve out-of-date or missing dependencies, use"
        puts "\"kite deps update\".  To force an update of a particular"
        puts "dependency, use \"kite deps update <name>\"."
    }

    # UpdateDependencies name
    #
    # name - A dependency name, or ""
    #
    # Updates all out-of-date or missing dependencies, or updates a
    # specific dependency.

    proc UpdateDependencies {name} {
        if {$name eq ""} {
            teacup update
        } elseif {$name in [project require names]} {
            teacup update $name
        } else {
            throw FATAL "Unknown dependency: \"$name\""
        }
    }


}






