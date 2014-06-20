#-----------------------------------------------------------------------
# TITLE:
#   infotool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "info" tool
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
# tool::info ensemble

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

    typemethod execute {argv} {
        checkargs info 0 0 {} $argv

        puts "Kite [kiteinfo get version]\n"

        project dumpinfo

        puts ""
    }    
}



