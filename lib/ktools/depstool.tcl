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
    package     ktools
    ensemble    ::ktools::depstool
    description "Manage project dependencies"
    intree      yes
}

#-----------------------------------------------------------------------
# depstool ensemble

snit::type ::ktools::depstool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        checkargs deps 0 1 {?info|update|force?} $argv

        # FIRST, if there are no arguments then just dump the dependency
        # status.
        set subc [lindex $argv 0]

        switch -exact -- [lindex $argv 0] {
            ""   -
            info {
                DisplayStatus
            }

            update {
                UpdateDependencies
            }

            force {
                UpdateDependencies -force
            }

            default {
                throw FATAL "Unknown subcommand: \"$subc\""
            }
        }

        puts ""
    }
    
    # DisplayStatus
    #
    # Displays the status of the project dependencies.

    proc DisplayStatus {} {
        # FIRST, show the status of local includes.
        includer status
    }

    # UpdateDependencies ?-force?
    #
    # Updates the project dependencies.  If -force is given,
    # downloads them fresh.

    proc UpdateDependencies {{opt ""}} {
        if {$opt eq "-force"} {
            includer clean
        }

        includer update
    }

}



