#-----------------------------------------------------------------------
# TITLE:
#   depstool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "deps" tool.  This tool reports on the state of the project
#   dependencies, and can update them.
#
# TODO: Support for teapot dependencies.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(deps) {
    arglist     {?option...?}
    package     kiteapp
    ensemble    depstool
    description "Manage project dependencies"
    usage       "?update? ?clean|<name>?"
    intree      yes
}

set ::khelp(deps) {
    The "deps" tool manages the project's external dependencies.  There 
    are two kinds of dependencies.  External "require" dependencies are 
    retrieved from teapot.activestate.com; "include" dependencies are 
    pulled into <project>/includes from local CM repositories and made 
    available for use by the project.

    To get the status of all external dependencies:

        $ kite deps

    To retrieve dependencies that are missing or clearly out-of-date:

        $ kite deps update

    To force the retrieval of a particular dependency,

        $ kite deps update <name>

    This will remove the dependency from the local teapot repository or
    from <project>/includes, and then retrieve a fresh copy.  This is
    generally only use for dependencies on unstable versions of 
    software (i.e., an include of a project head, or a require of
    beta software).

    Removing "include" statements from project.kite can leave you
    with obsolete includes in <project>/includes.  Use

        $ kite deps clean

    to remove them (or just delete them by hand).

    When Kite fails to install a required teapot package,
    see <project>/.kite/install_<package>.log for details.
}


#-----------------------------------------------------------------------
# depstool ensemble

snit::type depstool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        checkargs deps 0 2 $argv

        # FIRST, if there are no arguments then just dump the dependency
        # status.
        set subc [lshift argv]

        if {$subc eq ""} {
            DisplayStatus
        } elseif {$subc eq "update"} {
            UpdateDependencies [lshift argv]
        } elseif {$subc eq "clean"} {
            # Get rid of unneeded includes
            includer clean
        } else {
            throw FATAL "Unknown subcommand: \"$subc\""
        }

        puts ""
    }
    
    # DisplayStatus
    #
    # Displays the status of the project dependencies.

    proc DisplayStatus {} {
        # FIRST, show the status of local includes.
        includer status

        # NEXT, shows the status of required teapot packages.
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
            includer update
            teacup update
        } elseif {$name in [project include names]} {
            includer retrieve $name
        } elseif {$name in [project require names]} {
            teacup update $name
        } else {
            throw FATAL "Unknown dependency: \"$name\""
        }
    }


}






