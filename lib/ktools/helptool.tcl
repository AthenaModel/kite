#-----------------------------------------------------------------------
# TITLE:
#   helptool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "help" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::help ensemble

# FIRST, register the tool

set ::tools(help) {
    arglist     {}
    package     ktools
    ensemble    ::tool::help
    description "Display this help, or help for a given tool."
}

# NEXT, define it.

snit::type ::tool::help {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Type variables

    # TBD

    #-------------------------------------------------------------------
    # Execution

    # execute ?args?
    #
    # Displays the Kite help.
    #
    # TODO: provide help for individual tools.

    typemethod execute {argv} {
        puts "Kite is a tool for working with Tcl projects.\n"

        puts "Several tools are available:\n"

        foreach tool [lsort [array names ::tools]] {
            array set tdata $::tools($tool)

            puts [format "%-15s %s" $tool $tdata(description)]
        }
    }    
}



