#-----------------------------------------------------------------------
# TITLE:
#   cleantool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "clean" tool.  Deletes all build products, leaving a clean
#   project tree.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(clean) {
    usage       {0 0 -}
    ensemble    cleantool
    description "Clean up build artifacts."
    intree      yes
}

set ::khelp(clean) {
    The 'kite clean' tool simply removes the files created by 
    'kite compile', 'kite build', and 'kite docs', leaving a clean
    project tree. 
}

#-----------------------------------------------------------------------

snit::type cleantool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        compiletool clean
        docstool clean
        buildtool clean
    }

}






