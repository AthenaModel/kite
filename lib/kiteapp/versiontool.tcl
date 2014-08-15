#-----------------------------------------------------------------------
# TITLE:
#   versiontool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "version" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(version) {
    arglist     {}
    package     kiteapp
    ensemble    versiontool
    description "Display Kite's version information."
    usage       ""
    intree      yes
}

set ::khelp(version) {
    The "version" tool displays Kite's own version information.
}


#-----------------------------------------------------------------------
# tool::version ensemble

snit::type versiontool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution

    # execute argv
    #
    # Displays version information about Kite itself.

    typemethod execute {argv} {
        checkargs version 0 0 $argv

        puts "Kite [kiteinfo version]\n"
    }    
}






