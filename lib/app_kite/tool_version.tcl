#-----------------------------------------------------------------------
# TITLE:
#   tool_version.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "version" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::VERSION

tool define version {
    usage       {0 0 ""}
    description "Display Kite's version information."
    needstree      no
} {
    The "version" tool displays Kite's own version information.
} {
    #-------------------------------------------------------------------
    # Execution

    # execute argv
    #
    # Displays version information about Kite itself.

    typemethod execute {argv} {
        puts "Kite [kiteinfo version]\n"
    }    
}






