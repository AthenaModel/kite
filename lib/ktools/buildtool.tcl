#-----------------------------------------------------------------------
# TITLE:
#   buildtool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "build" tool.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(build) {
    arglist     {}
    package     ktools
    ensemble    ::ktools::buildtool
    description "Build the entire project."
}

#-----------------------------------------------------------------------
# buildtool ensemble

snit::type ::ktools::buildtool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        puts "Building: <$argv>!"
    }
    

}



