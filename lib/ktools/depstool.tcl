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
            ""       -
            info     {
                DisplayStatus
            }

            default {
                throw FATAL "Unknown subcommand: \"$subc\""
            }
        }
    }
    
    # DisplayStatus
    #
    # Displays the status of the project dependencies.

    proc DisplayStatus {} {
        # FIRST, show the status of local includes.
        includer status
    }

}



