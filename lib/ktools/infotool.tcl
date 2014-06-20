#-----------------------------------------------------------------------
# TITLE:
#   infotool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "help" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(info) {
    arglist     {}
    package     ktools
    ensemble    ::ktools::infotool
    description "Display information about Kite and this project."
}

#-----------------------------------------------------------------------
# tool::help ensemble

snit::type ::ktools::infotool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Type variables

    # TBD

    #-------------------------------------------------------------------
    # Execution

    # execute argv
    #
    # Displays information about Kite and the current project
    # given the command line.
    #
    # TODO: Need a mechanism for accessing kite's own project info.

    typemethod execute {argv} {
        checkargs info 0 0 {} $argv

        puts "Kite vTBD\n"

        project dumpinfo

        puts ""
    }    
}



