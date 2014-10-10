#-----------------------------------------------------------------------
# TITLE:
#   tool_clean.tcl
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
# tool::CLEAN

tool define clean {
    usage       {0 0 -}
    description "Clean up build artifacts."
    needstree      yes
} {
    The 'kite clean' tool simply removes the files created by 
    'kite compile', 'kite build', and 'kite docs', leaving a clean
    project tree. 
} {
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.
    # TODO: Consider adding a "clean" flag to tool metadata.  If true,
    # call clean.  

    typemethod execute {argv} {
        tool::COMPILE clean
        tool::DOCS    clean
        tool::BUILD   clean
    }

}






